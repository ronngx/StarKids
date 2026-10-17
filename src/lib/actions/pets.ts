"use server"

import { auth } from "@/auth"
import { prisma } from "@/lib/db"
import { revalidatePath } from "next/cache"
import { formatPoints, normalizePoints } from "@/lib/points"
import type { PetInteractionType, PetSpecies, PetStage } from "@prisma/client"
import { STAGE_CONFIG } from "@/lib/constants"
import {
  PET_INTERACTION_CONFIG,
  parsePetInteractionCosts,
  type PublicPetInteraction,
  advancePetState,
  applyInteraction,
  getRemainingCooldown,
} from "@/lib/pet-care"

const PUBLIC_INTERACTIONS = ["FEED", "DRINK", "BATH", "PLAY"] as const
type PublicInteraction = (typeof PUBLIC_INTERACTIONS)[number]

function isPublicInteraction(value: string): value is PublicInteraction {
  return PUBLIC_INTERACTIONS.includes(value as PublicInteraction)
}

async function getCurrentMember() {
  const session = await auth()
  if (!session?.user?.id) throw new Error("请先登录")

  const member = await prisma.familyMember.findFirst({
    where: { userId: session.user.id },
  })
  if (!member) throw new Error("你还未加入家庭")
  return member
}

function careUpdate(result: ReturnType<typeof advancePetState>) {
  return {
    hunger: result.hunger,
    thirst: result.thirst,
    hygiene: result.hygiene,
    energy: result.energy,
    mood: result.mood,
    status: result.status as any,
    deathAt: result.deathAt,
    deathReason: result.deathReason,
    criticalSince: result.criticalSince,
    lastSimulatedAt: result.lastSimulatedAt ? new Date(result.lastSimulatedAt) : new Date(),
  }
}

export async function createPet(formData: FormData) {
  const member = await getCurrentMember()
  const existing = await prisma.pet.findUnique({ where: { memberId: member.id } })
  if (existing) throw new Error("你已经有一只宠物了！")

  const name = ((formData.get("name") as string) || "小宝贝").trim().slice(0, 20)
  const pet = await prisma.pet.create({
    data: {
      memberId: member.id,
      species: ((formData.get("species") as string) || "CAT") as PetSpecies,
      name: name || "小宝贝",
    },
  })

  revalidatePath("/kids/pet")
  return pet
}

export async function syncPetState(memberId: string) {
  const now = new Date()
  return prisma.$transaction(async (tx) => {
    const pet = await tx.pet.findUnique({ where: { memberId } })
    if (!pet) return null

    const next = advancePetState(pet, now)
    if (!next.changed) return pet
    return tx.pet.update({ where: { id: pet.id }, data: careUpdate(next) })
  })
}

export async function interactWithPet(type: string, idempotencyKey?: string) {
  const member = await getCurrentMember()
  if (!isPublicInteraction(type)) throw new Error("不支持的宠物互动")

  const interactionType = type as PetInteractionType
  const now = new Date()
  const result = await prisma.$transaction(async (tx) => {
    const pet = await tx.pet.findUnique({ where: { memberId: member.id } })
    if (!pet) throw new Error("你还没有宠物！")

    if (idempotencyKey) {
      const duplicate = await tx.petInteraction.findFirst({ where: { petId: pet.id, idempotencyKey } })
      if (duplicate) {
        return {
          pet,
          applied: false,
          duplicate: true,
          justDied: false,
          pointsCost: 0,
          balanceAfter: normalizePoints(member.currentPoints),
        }
      }
    }

    const advanced = advancePetState(pet, now)
    const syncedPet = advanced.changed
      ? await tx.pet.update({ where: { id: pet.id }, data: careUpdate(advanced) })
      : pet

    if (advanced.justDied) {
      return {
        pet: syncedPet,
        applied: false,
        duplicate: false,
        justDied: true,
        pointsCost: 0,
        balanceAfter: normalizePoints(member.currentPoints),
      }
    }
    if (syncedPet.status === "DEAD") throw new Error("宠物已经睡着了，请联系家长帮忙恢复。")

    const config = PET_INTERACTION_CONFIG[interactionType]
    const lastAt = config.timestampField ? syncedPet[config.timestampField] : null
    const remaining = getRemainingCooldown(lastAt, interactionType, now)
    if (remaining > 0) throw new Error(`${config.label}还需要等待约 ${Math.ceil(remaining / 60000)} 分钟。`)
    if (interactionType === "PLAY" && syncedPet.energy < 20) {
      throw new Error("宠物太累了，先让它休息一会儿吧。")
    }

    const pointConfig = await tx.pointConfig.findUnique({ where: { familyId: member.familyId } })
    const interactionCost = parsePetInteractionCosts(pointConfig?.petInteractionCosts)[interactionType as PublicPetInteraction]
    let balanceAfter = normalizePoints(member.currentPoints)
    if (interactionCost > 0) {
      const deducted = await tx.familyMember.updateMany({
        where: { id: member.id, currentPoints: { gte: interactionCost } },
        data: { currentPoints: { decrement: interactionCost } },
      })
      if (deducted.count !== 1) {
        const current = await tx.familyMember.findUnique({
          where: { id: member.id },
          select: { currentPoints: true },
        })
        const balance = normalizePoints(current?.currentPoints)
        throw new Error(`积分不足！需要 ${formatPoints(interactionCost)}⭐，当前 ${formatPoints(balance)}⭐`)
      }
      const updatedMember = await tx.familyMember.findUnique({
        where: { id: member.id },
        select: { currentPoints: true },
      })
      balanceAfter = normalizePoints(updatedMember?.currentPoints)
    }

    const next = applyInteraction(syncedPet, interactionType, now)
    const timestamps = config.timestampField ? { [config.timestampField]: now } : {}
    const updated = await tx.pet.update({
      where: { id: pet.id },
      data: {
        ...careUpdate(next),
        ...timestamps,
        ...(interactionType === "FEED" ? { lastFeedDate: now } : {}),
        lastMoodUpdate: now,
      },
    })

    await tx.petInteraction.create({
      data: {
        petId: pet.id,
        memberId: member.id,
        type: interactionType,
        idempotencyKey: idempotencyKey || null,
        effects: JSON.stringify({ ...config.effects, pointsCost: interactionCost, balanceAfter }),
      },
    })

    return {
      pet: updated,
      applied: true,
      duplicate: false,
      justDied: false,
      pointsCost: interactionCost,
      balanceAfter,
    }
  })

  revalidatePath("/kids/pet")
  return result
}

/** Kept as a compatibility wrapper for existing callers. */
export async function feedPet() {
  return interactWithPet("FEED")
}

export async function revivePet(memberId: string) {
  const current = await getCurrentMember()
  if (current.role !== "PARENT") throw new Error("只有家长可以恢复宠物")

  const target = await prisma.familyMember.findFirst({
    where: { id: memberId, familyId: current.familyId, role: "KID" },
  })
  if (!target) throw new Error("找不到这个小朋友")

  const now = new Date()
  const pet = await prisma.$transaction(async (tx) => {
    const existing = await tx.pet.findUnique({ where: { memberId: target.id } })
    if (!existing) throw new Error("这个小朋友还没有宠物")

    const next = applyInteraction(existing, "REVIVE", now)
    const updated = await tx.pet.update({ where: { id: existing.id }, data: careUpdate(next) })
    await tx.petInteraction.create({
      data: {
        petId: existing.id,
        memberId: target.id,
        type: "REVIVE",
        effects: JSON.stringify(PET_INTERACTION_CONFIG.REVIVE.effects),
      },
    })
    return updated
  })

  revalidatePath("/kids/pet")
  revalidatePath("/admin/pets")
  return pet
}

export async function dressPet(outfitId: string) {
  const member = await getCurrentMember()
  const pet = await prisma.pet.findUnique({ where: { memberId: member.id } })
  if (!pet) throw new Error("你还没有宠物！")

  const outfit = await prisma.petOutfit.findUnique({ where: { id: outfitId } })
  if (!outfit) throw new Error("装扮不存在")
  if (outfit.species && outfit.species !== pet.species) throw new Error("这个装扮不适合你的宠物")

  const grant = await prisma.petOutfitGrant.findFirst({ where: { outfitId, memberId: member.id } })
  if (!grant && !outfit.isDefault) throw new Error("你还未解锁这个装扮！")

  await prisma.pet.update({ where: { id: pet.id }, data: { currentOutfit: outfitId } })
  revalidatePath("/kids/pet")
}

export async function getPetDetails(memberId: string) {
  const [pet, outfits, grants] = await Promise.all([
    prisma.pet.findUnique({ where: { memberId } }),
    prisma.petOutfit.findMany({ where: {} }),
    prisma.petOutfitGrant.findMany({ where: { memberId }, select: { outfitId: true } }),
  ])

  return { pet, outfits, unlockedIds: new Set(grants.map((g) => g.outfitId)) }
}

export async function getPetGrowthStage(memberId: string) {
  const totalEarned = await prisma.taskCompletion.aggregate({
    where: { memberId, status: "APPROVED" },
    _sum: { pointsEarned: true },
  })
  const totalPoints = normalizePoints(totalEarned._sum.pointsEarned)
  let currentStage: PetStage = "EGG"
  for (const [stage, config] of Object.entries(STAGE_CONFIG)) {
    if (totalPoints >= config.threshold) currentStage = stage as PetStage
  }
  return { totalPoints, currentStage }
}

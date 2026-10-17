import { auth } from "@/auth"
import { prisma } from "@/lib/db"
import { NextResponse } from "next/server"
import { normalizePoints } from "@/lib/points"
import { SPECIES_EMOJI, STAGE_CONFIG } from "@/lib/constants"
import { getPetCareWarning, getRemainingCooldown, PET_INTERACTION_CONFIG } from "@/lib/pet-care"
import { interactWithPet, syncPetState } from "@/lib/actions/pets"
import type { PetInteractionType } from "@prisma/client"

async function getMember() {
  const session = await auth()
  if (!session?.user?.id) return null
  return prisma.familyMember.findFirst({ where: { userId: session.user.id } })
}

export async function GET() {
  const member = await getMember()
  if (!member) return NextResponse.json({ error: "Unauthorized" }, { status: 401 })

  const pet = await syncPetState(member.id)
  const [outfits, grants, totalEarned] = await Promise.all([
    prisma.petOutfit.findMany({
      where: { OR: [{ familyId: member.familyId }, { familyId: null }] },
      orderBy: [{ sortOrder: "asc" }, { createdAt: "asc" }],
    }),
    prisma.petOutfitGrant.findMany({ where: { memberId: member.id }, select: { outfitId: true } }),
    prisma.taskCompletion.aggregate({
      where: { memberId: member.id, status: "APPROVED" },
      _sum: { pointsEarned: true },
    }),
  ])

  const unlockedOutfitIds = new Set(grants.map((g) => g.outfitId))
  const totalPoints = normalizePoints(totalEarned._sum.pointsEarned)
  let currentStage = "EGG"
  for (const [stage, cfg] of Object.entries(STAGE_CONFIG)) {
    if (totalPoints >= cfg.threshold) currentStage = stage
  }

  const now = new Date()
  const cooldowns = pet
    ? Object.fromEntries(
        (["FEED", "DRINK", "BATH", "PLAY"] as const).map((type) => {
          const field = PET_INTERACTION_CONFIG[type].timestampField
          const lastAt = field ? pet[field] : null
          return [type, getRemainingCooldown(lastAt, type, now)]
        })
      )
    : {}

  return NextResponse.json({
    pet,
    outfits,
    unlockedOutfitIds: Array.from(unlockedOutfitIds),
    totalPoints,
    currentStage,
    stageEmoji: STAGE_CONFIG[currentStage]?.emoji || "🥚",
    speciesEmoji: pet ? SPECIES_EMOJI[pet.species] || "🐱" : null,
    care: pet
      ? {
          hunger: pet.hunger,
          thirst: pet.thirst,
          hygiene: pet.hygiene,
          energy: pet.energy,
          mood: pet.mood,
          status: pet.status,
          warning: getPetCareWarning(pet),
          cooldowns,
        }
      : null,
  })
}

export async function POST(request: Request) {
  try {
    const body = await request.json().catch(() => ({}))
    const type = typeof body.type === "string" ? body.type : ""
    const idempotencyKey = typeof body.idempotencyKey === "string" ? body.idempotencyKey.slice(0, 100) : undefined
    const result = await interactWithPet(type, idempotencyKey)
    return NextResponse.json({
      ...result,
      pet: result.pet,
      interaction: type as PetInteractionType,
    })
  } catch (error) {
    const message = error instanceof Error ? error.message : "互动失败"
    const status = message.includes("登录") ? 401 : message.includes("宠物") ? 409 : 400
    return NextResponse.json({ error: message }, { status })
  }
}

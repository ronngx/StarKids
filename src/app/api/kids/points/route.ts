import { auth } from "@/auth"
import { prisma } from "@/lib/db"
import { PET_INTERACTION_CONFIG } from "@/lib/pet-care"
import { normalizePoints } from "@/lib/points"
import { NextResponse } from "next/server"

type PointDirection = "EARN" | "SPEND"
type PointStatus = "COMPLETED" | "PENDING" | "APPROVED" | "FULFILLED"

type PointDetail = {
  id: string
  createdAt: string
  direction: PointDirection
  amount: number
  title: string
  icon: string
  status: PointStatus
}

function parsePointsCost(effects: string | null): number {
  if (!effects) return 0
  try {
    const parsed = JSON.parse(effects) as { pointsCost?: unknown }
    const cost = typeof parsed.pointsCost === "number" ? parsed.pointsCost : Number(parsed.pointsCost)
    return Number.isFinite(cost) && cost > 0 ? normalizePoints(cost) : 0
  } catch {
    return 0
  }
}

export async function GET() {
  try {
    const session = await auth()
    if (!session?.user?.id) return NextResponse.json({ error: "Unauthorized" }, { status: 401 })

    const member = await prisma.familyMember.findFirst({
      where: { userId: session.user.id },
      select: { id: true, currentPoints: true },
    })
    if (!member) return NextResponse.json({ error: "No family" }, { status: 404 })

    const [completions, redemptions, interactions, outfitGrants] = await Promise.all([
      prisma.taskCompletion.findMany({
        where: { memberId: member.id, status: "APPROVED" },
        select: {
          id: true,
          pointsEarned: true,
          createdAt: true,
          approvedAt: true,
          task: { select: { name: true } },
        },
      }),
      prisma.rewardRedemption.findMany({
        where: { memberId: member.id, status: { not: "REJECTED" } },
        select: {
          id: true,
          pointsSpent: true,
          status: true,
          createdAt: true,
          reward: { select: { name: true } },
        },
      }),
      prisma.petInteraction.findMany({
        where: { memberId: member.id },
        select: { id: true, type: true, effects: true, createdAt: true },
      }),
      prisma.petOutfitGrant.findMany({
        where: { memberId: member.id },
        select: { id: true, pointsSpent: true, unlockedAt: true, outfit: { select: { name: true } } },
      }),
    ])

    const details: PointDetail[] = [
      ...completions
        .filter((completion) => normalizePoints(completion.pointsEarned) > 0)
        .map((completion) => ({
          id: `task-${completion.id}`,
          createdAt: (completion.approvedAt || completion.createdAt).toISOString(),
          direction: "EARN" as const,
          amount: normalizePoints(completion.pointsEarned),
          title: `完成任务：${completion.task.name}`,
          icon: "✅",
          status: "COMPLETED" as const,
        })),
      ...redemptions
        .filter((redemption) => normalizePoints(redemption.pointsSpent) > 0)
        .map((redemption) => ({
          id: `redemption-${redemption.id}`,
          createdAt: redemption.createdAt.toISOString(),
          direction: "SPEND" as const,
          amount: -normalizePoints(redemption.pointsSpent),
          title: `兑换奖励：${redemption.reward.name}`,
          icon: "🎁",
          status: redemption.status as PointStatus,
        })),
      ...interactions.flatMap((interaction) => {
        const cost = parsePointsCost(interaction.effects)
        if (cost <= 0) return []
        const config = PET_INTERACTION_CONFIG[interaction.type]
        return [{
          id: `pet-${interaction.id}`,
          createdAt: interaction.createdAt.toISOString(),
          direction: "SPEND" as const,
          amount: -cost,
          title: `宠物互动：${config?.label || "互动"}`,
          icon: config?.emoji || "🐾",
          status: "COMPLETED" as const,
        }]
      }),
      ...outfitGrants
        .filter((grant) => normalizePoints(grant.pointsSpent) > 0)
        .map((grant) => ({
          id: `outfit-${grant.id}`,
          createdAt: grant.unlockedAt.toISOString(),
          direction: "SPEND" as const,
          amount: -normalizePoints(grant.pointsSpent),
          title: `解锁宠物装扮：${grant.outfit.name}`,
          icon: "👗",
          status: "COMPLETED" as const,
        })),
    ].sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())

    const earned = normalizePoints(
      details.filter((detail) => detail.direction === "EARN").reduce((sum, detail) => sum + detail.amount, 0),
    )
    const spent = normalizePoints(
      details.filter((detail) => detail.direction === "SPEND").reduce((sum, detail) => sum + Math.abs(detail.amount), 0),
    )

    return NextResponse.json({
      balance: normalizePoints(member.currentPoints),
      summary: { earned, spent },
      items: details,
    })
  } catch (e) {
    console.error("GET /api/kids/points error:", e)
    return NextResponse.json({ error: "Internal Server Error" }, { status: 500 })
  }
}

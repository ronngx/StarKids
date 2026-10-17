import { auth } from "@/auth"
import { prisma } from "@/lib/db"
import { NextResponse } from "next/server"
import { normalizePoints } from "@/lib/points"

export async function GET() {
  try {
    const session = await auth()
    if (!session?.user?.id) return NextResponse.json({ error: "Unauthorized" }, { status: 401 })

    const member = await prisma.familyMember.findFirst({
      where: { userId: session.user.id },
    })
    if (!member) return NextResponse.json({ error: "No family" }, { status: 404 })

    const [rewards, totalEarned, totalSpent] = await Promise.all([
      prisma.reward.findMany({
        where: { familyId: member.familyId, status: "ACTIVE" },
        orderBy: [{ isFeatured: "desc" }, { sortOrder: "asc" }],
      }),
      prisma.taskCompletion.aggregate({
        where: { memberId: member.id, status: "APPROVED" },
        _sum: { pointsEarned: true },
      }),
      prisma.rewardRedemption.aggregate({
        where: { memberId: member.id, status: { not: "REJECTED" } },
        _sum: { pointsSpent: true },
      }),
    ])

    const earned = normalizePoints(totalEarned._sum.pointsEarned)
    const spent = normalizePoints(totalSpent._sum.pointsSpent)

    return NextResponse.json({
      rewards,
      balance: normalizePoints(member.currentPoints),
      totalEarned: earned,
      totalSpent: spent,
    })
  } catch (e) {
    console.error("GET /api/kids/shop error:", e)
    return NextResponse.json({ error: "Internal Server Error" }, { status: 500 })
  }
}

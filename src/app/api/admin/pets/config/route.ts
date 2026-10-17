import { auth } from "@/auth"
import { prisma } from "@/lib/db"
import { parsePoints } from "@/lib/points"
import {
  DEFAULT_PET_INTERACTION_COSTS_JSON,
  parsePetInteractionCosts,
  PUBLIC_PET_INTERACTIONS,
} from "@/lib/pet-care"
import { NextResponse } from "next/server"

async function getParentMember() {
  const session = await auth()
  if (!session?.user?.id) return { session, member: null }
  const member = await prisma.familyMember.findFirst({
    where: { userId: session.user.id, role: "PARENT" },
  })
  return { session, member }
}

async function getOrCreateConfig(familyId: string) {
  return prisma.pointConfig.upsert({
    where: { familyId },
    create: { familyId, petInteractionCosts: DEFAULT_PET_INTERACTION_COSTS_JSON },
    update: {},
  })
}

export async function GET() {
  try {
    const { session, member } = await getParentMember()
    if (!member) {
      return NextResponse.json(
        { error: session?.user?.id ? "Forbidden" : "Unauthorized" },
        { status: session?.user?.id ? 403 : 401 }
      )
    }

    const config = await getOrCreateConfig(member.familyId)
    return NextResponse.json({ petInteractionCosts: parsePetInteractionCosts(config.petInteractionCosts) })
  } catch (error) {
    console.error("GET /api/admin/pets/config error:", error)
    return NextResponse.json({ error: "Internal Server Error" }, { status: 500 })
  }
}

export async function POST(request: Request) {
  try {
    const { session, member } = await getParentMember()
    if (!member) {
      return NextResponse.json(
        { error: session?.user?.id ? "Forbidden" : "Unauthorized" },
        { status: session?.user?.id ? 403 : 401 }
      )
    }

    const formData = await request.formData()
    const costs = Object.fromEntries(
      PUBLIC_PET_INTERACTIONS.map((type) => [
        type,
        parsePoints(formData.get(type), { min: 0, defaultValue: 0, fieldName: `${type}互动积分` }),
      ])
    )

    const config = await prisma.pointConfig.upsert({
      where: { familyId: member.familyId },
      create: { familyId: member.familyId, petInteractionCosts: JSON.stringify(costs) },
      update: { petInteractionCosts: JSON.stringify(costs) },
    })
    return NextResponse.json({ petInteractionCosts: parsePetInteractionCosts(config.petInteractionCosts) })
  } catch (error) {
    const message = error instanceof Error ? error.message : "保存失败"
    if (message.includes("积分")) return NextResponse.json({ error: message }, { status: 400 })
    console.error("POST /api/admin/pets/config error:", error)
    return NextResponse.json({ error: "Internal Server Error" }, { status: 500 })
  }
}

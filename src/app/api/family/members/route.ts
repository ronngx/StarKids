import { auth } from "@/auth"
import { prisma } from "@/lib/db"
import { NextResponse } from "next/server"
import { updateFamilyMember } from "@/lib/actions/family"

export async function GET() {
  const session = await auth()
  if (!session?.user?.id) return NextResponse.json({ error: "Unauthorized" }, { status: 401 })

  const currentMember = await prisma.familyMember.findFirst({
    where: { userId: session.user.id },
  })
  if (!currentMember) return NextResponse.json({ error: "No family" }, { status: 404 })

  const family = await prisma.family.findUnique({
    where: { id: currentMember.familyId },
    select: { name: true, inviteCode: true, createdAt: true },
  })

  const members = await prisma.familyMember.findMany({
    where: { familyId: currentMember.familyId },
    select: {
      id: true,
      nickname: true,
      role: true,
      userId: true,
      user: { select: { username: true } },
      createdAt: true,
      currentPoints: true,
      pet: {
        select: { name: true, species: true, stage: true },
      },
    },
    orderBy: [{ role: "asc" }, { nickname: "asc" }],
  })

  return NextResponse.json({
    name: family?.name || "",
    inviteCode: family?.inviteCode || "",
    createdAt: family?.createdAt || "",
    canManageMembers: currentMember.role === "PARENT",
    members,
  })
}

export async function PATCH(request: Request) {
  try {
    const result = await updateFamilyMember(await request.formData())
    return NextResponse.json(result)
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : "修改失败" }, { status: 400 })
  }
}

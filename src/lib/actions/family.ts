"use server"

import { auth } from "@/auth"
import { prisma } from "@/lib/db"
import { revalidatePath } from "next/cache"
import { redirect } from "next/navigation"
import bcrypt from "bcryptjs"
import type { MemberRole } from "@prisma/client"
import { Prisma } from "@prisma/client"
import { memberUpdateSchema, registrationSchema } from "@/lib/credentials"

function generateInviteCode() {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
  let code = ""
  for (let i = 0; i < 6; i++) {
    code += chars[Math.floor(Math.random() * chars.length)]
  }
  return code
}

export async function createFamily(formData: FormData) {
  const session = await auth()
  if (!session?.user?.id) throw new Error("请先登录")

  const name = formData.get("name") as string
  const nickname = formData.get("nickname") as string

  if (!name || name.trim().length < 2) throw new Error("家庭名称至少2个字符")
  if (!nickname || nickname.trim().length < 2) throw new Error("昵称至少2个字符")

  let inviteCode = generateInviteCode()
  let existing = await prisma.family.findUnique({ where: { inviteCode } })
  let attempts = 0
  while (existing && attempts < 10) {
    inviteCode = generateInviteCode()
    existing = await prisma.family.findUnique({ where: { inviteCode } })
    attempts++
  }

  const family = await prisma.family.create({
    data: {
      name: name.trim(),
      inviteCode,
      members: {
        create: {
          userId: session.user.id,
          role: "PARENT",
          nickname: nickname.trim(),
        },
      },
    },
  })

  await prisma.pointConfig.create({
    data: {
      familyId: family.id,
      weekendDouble: true,
      birthdayTriple: true,
      dailyCap: 200,
    },
  })

  revalidatePath("/admin")
  redirect("/admin")
}

export async function joinFamily(formData: FormData) {
  const session = await auth()
  if (!session?.user?.id) throw new Error("请先登录")

  const inviteCode = (formData.get("inviteCode") as string).trim().toUpperCase()
  const nickname = formData.get("nickname") as string
  const role = formData.get("role") as string

  if (!inviteCode || inviteCode.length < 5) throw new Error("请输入有效的邀请码")
  if (!nickname || nickname.trim().length < 2) throw new Error("昵称至少2个字符")

  const family = await prisma.family.findUnique({
    where: { inviteCode },
  })

  if (!family) throw new Error("邀请码无效，请检查后重试")

  const existingMember = await prisma.familyMember.findFirst({
    where: { familyId: family.id, userId: session.user.id },
  })

  if (existingMember) throw new Error("你已经是这个家庭的成员了")

  await prisma.familyMember.create({
    data: {
      familyId: family.id,
      userId: session.user.id,
      role: (role === "KID" ? "KID" : "PARENT") as MemberRole,
      nickname: nickname.trim(),
    },
  })

  revalidatePath(role === "KID" ? "/kids" : "/admin")
  redirect(role === "KID" ? "/kids" : "/admin")
}

export async function addKidToFamily(formData: FormData) {
  const session = await auth()
  if (!session?.user?.id) throw new Error("请先登录")

  const currentMember = await prisma.familyMember.findFirst({
    where: { userId: session.user.id },
  })
  if (!currentMember || currentMember.role !== "PARENT") {
    throw new Error("只有家长可以添加小朋友")
  }

  const parsed = registrationSchema.safeParse({
    nickname: formData.get("nickname"),
    username: formData.get("username"),
    password: formData.get("password"),
    role: "KID",
  })
  if (!parsed.success) throw new Error(parsed.error.issues[0].message)
  const { nickname, username, password } = parsed.data

  const existingUser = await prisma.user.findUnique({ where: { username } })
  if (existingUser) throw new Error("该用户名已被使用")

  const hash = await bcrypt.hash(password, 12)

  try {
    await prisma.user.create({
      data: {
        username,
        name: nickname,
        passwordHash: hash,
        role: "KID",
        familyMembers: {
          create: { familyId: currentMember.familyId, role: "KID", nickname },
        },
      },
    })
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2002") {
      throw new Error("该用户名已被使用")
    }
    throw error
  }

  revalidatePath("/admin/family")
  return { success: true, kidNickname: nickname }
}

export async function updateFamilyMember(formData: FormData) {
  const session = await auth()
  if (!session?.user?.id) throw new Error("请先登录")

  const currentMember = await prisma.familyMember.findFirst({
    where: { userId: session.user.id },
  })
  if (!currentMember || currentMember.role !== "PARENT") {
    throw new Error("只有家长可以修改家庭成员")
  }

  const memberId = formData.get("memberId")
  if (typeof memberId !== "string" || !memberId) throw new Error("请选择要修改的成员")
  const member = await prisma.familyMember.findFirst({
    where: { id: memberId, familyId: currentMember.familyId },
  })
  if (!member) throw new Error("该成员不在当前家庭中")

  const parsed = memberUpdateSchema.safeParse({
    nickname: formData.get("nickname"),
    username: formData.get("username"),
    password: formData.get("password") ?? "",
  })
  if (!parsed.success) throw new Error(parsed.error.issues[0].message)
  const { nickname, username, password } = parsed.data

  const existingUser = await prisma.user.findUnique({ where: { username } })
  if (existingUser && existingUser.id !== member.userId) throw new Error("该用户名已被使用")

  const passwordHash = password ? await bcrypt.hash(password, 12) : undefined
  try {
    await prisma.$transaction([
      prisma.user.update({
        where: { id: member.userId },
        data: { username, name: nickname, ...(passwordHash ? { passwordHash } : {}) },
      }),
      prisma.familyMember.update({
        where: { id: member.id },
        data: { nickname },
      }),
    ])
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2002") {
      throw new Error("该用户名已被使用")
    }
    throw error
  }

  revalidatePath("/admin", "layout")
  revalidatePath("/kids", "layout")
  return { success: true, nickname }
}

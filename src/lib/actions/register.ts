"use server"

import { prisma } from "@/lib/db"
import bcrypt from "bcryptjs"
import { Prisma } from "@prisma/client"
import { registrationSchema } from "@/lib/credentials"

export async function registerUser(formData: FormData) {
  const parsed = registrationSchema.safeParse({
    username: formData.get("username"),
    password: formData.get("password"),
    nickname: formData.get("nickname"),
    role: formData.get("role") || "PARENT",
  })
  if (!parsed.success) throw new Error(parsed.error.issues[0].message)
  const { username, password, nickname, role } = parsed.data

  const existing = await prisma.user.findUnique({ where: { username } })
  if (existing) {
    throw new Error("该用户名已被使用")
  }

  const hash = await bcrypt.hash(password, 12)

  try {
    await prisma.user.create({
      data: { username, name: nickname, passwordHash: hash, role },
    })
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === "P2002") {
      throw new Error("该用户名已被使用")
    }
    throw error
  }
}

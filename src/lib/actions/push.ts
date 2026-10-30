"use server"

import { auth } from "@/auth"
import { prisma } from "@/lib/db"
import {
  decryptServerChanSendKey,
  encryptServerChanSendKey,
  extractServerChanUid,
  maskServerChanSendKey,
  sendServerChan3,
  validateServerChanSendKey,
} from "@/lib/push/serverchan3"

async function currentParentMember() {
  const session = await auth()
  if (!session?.user?.id) throw new Error("请先登录")

  const member = await prisma.familyMember.findFirst({
    where: { userId: session.user.id, role: "PARENT" },
  })
  if (!member) throw new Error("只有家长可以管理推送设置")
  return member
}

async function publicState(familyId: string) {
  const setting = await prisma.familyPushSetting.findUnique({ where: { familyId } })
  if (!setting) {
    return {
      configured: false,
      enabled: false,
      sendKey: null,
      lastTestAt: null,
      lastTestStatus: null,
      lastError: null,
    }
  }

  let masked = "已配置"
  try {
    masked = maskServerChanSendKey(decryptServerChanSendKey(setting.sendKeyCiphertext))
  } catch {
    // Never expose the encrypted value when a legacy or damaged configuration is found.
  }

  return {
    configured: true,
    enabled: setting.enabled,
    sendKey: masked,
    lastTestAt: setting.lastTestAt,
    lastTestStatus: setting.lastTestStatus,
    lastError: setting.lastError,
  }
}

export async function getFamilyPushSetting() {
  const member = await currentParentMember()
  return publicState(member.familyId)
}

export async function saveFamilyPushSetting(input: { sendKey?: string; enabled?: boolean }) {
  const member = await currentParentMember()
  const existing = await prisma.familyPushSetting.findUnique({ where: { familyId: member.familyId } })
  const sendKey = input.sendKey?.trim()

  let encrypted = existing?.sendKeyCiphertext
  if (sendKey) {
    validateServerChanSendKey(sendKey)
    encrypted = encryptServerChanSendKey(sendKey)
  }
  if (!encrypted) throw new Error("请输入 Server酱³ SendKey")

  await prisma.familyPushSetting.upsert({
    where: { familyId: member.familyId },
    create: {
      familyId: member.familyId,
      sendKeyCiphertext: encrypted,
      enabled: input.enabled ?? true,
      lastTestStatus: null,
      lastError: null,
    },
    update: {
      sendKeyCiphertext: encrypted,
      enabled: input.enabled ?? existing?.enabled ?? true,
      lastError: null,
    },
  })

  return publicState(member.familyId)
}

export async function disableFamilyPush() {
  const member = await currentParentMember()
  const setting = await prisma.familyPushSetting.findUnique({ where: { familyId: member.familyId } })
  if (setting) {
    await prisma.familyPushSetting.update({
      where: { familyId: member.familyId },
      data: { enabled: false },
    })
  }
  return publicState(member.familyId)
}

export async function testFamilyPush() {
  const member = await currentParentMember()
  const setting = await prisma.familyPushSetting.findUnique({ where: { familyId: member.familyId } })
  if (!setting) throw new Error("请先保存 Server酱³ SendKey")

  let result
  try {
    const sendKey = decryptServerChanSendKey(setting.sendKeyCiphertext)
    extractServerChanUid(sendKey)
    result = await sendServerChan3({
      sendKey,
      title: "StarKids 推送测试",
      desp: "Server酱³ 已成功连接到当前家庭。",
      short: "StarKids 推送测试",
      tags: "StarKids|测试",
    })
  } catch (error) {
    result = {
      ok: false,
      code: null,
      message: error instanceof Error ? error.message : "推送测试失败",
    }
  }

  await prisma.familyPushSetting.update({
    where: { familyId: member.familyId },
    data: {
      lastTestAt: new Date(),
      lastTestStatus: result.ok ? "SENT" : "FAILED",
      lastError: result.ok ? null : result.message.slice(0, 500),
    },
  })

  return {
    success: result.ok,
    message: result.ok ? "测试消息已发送" : result.message,
    setting: await publicState(member.familyId),
  }
}

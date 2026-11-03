import { prisma } from "@/lib/db"
import { formatPoints } from "@/lib/points"
import {
  decryptServerChanSendKey,
  sendServerChan3,
} from "@/lib/push/serverchan3"

function formatCompletedAt(date: Date, timezone: string) {
  try {
    return new Intl.DateTimeFormat("zh-CN", {
      timeZone: timezone,
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
      hour12: false,
    }).format(date).replace(/\//g, "-")
  } catch {
    return new Intl.DateTimeFormat("zh-CN", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
      hour12: false,
    }).format(date).replace(/\//g, "-")
  }
}

function appUrl(path: string) {
  const base = process.env.NEXT_PUBLIC_APP_URL?.trim().replace(/\/$/, "")
  return base ? `${base}${path}` : null
}

async function sendParentTaskCompletionPush(params: {
  parent: {
    id: string
    pushSetting: {
      enabled: boolean
      sendKeyCiphertext: string
    } | null
  }
  timezone: string
  completionId: string
  familyId: string
  kidNickname: string
  taskName: string
  points: number
  autoApproved: boolean
  completedAt: Date
}) {
  const setting = params.parent.pushSetting
  const delivery = await prisma.pushDelivery.upsert({
    where: {
      completionId_provider_recipientMemberId: {
        completionId: params.completionId,
        provider: "SERVERCHAN3",
        recipientMemberId: params.parent.id,
      },
    },
    create: {
      completionId: params.completionId,
      familyId: params.familyId,
      recipientMemberId: params.parent.id,
      provider: "SERVERCHAN3",
      status: setting?.enabled ? "PENDING" : "SKIPPED",
      responseMessage: !setting
        ? "家长未配置 Server酱³"
        : setting.enabled ? undefined : "家长未启用 Server酱³",
    },
    update: {},
  })

  if (delivery.status === "SENT") return delivery

  if (!setting || !setting.enabled) {
    if (delivery.status !== "SKIPPED") {
      return prisma.pushDelivery.update({
        where: { id: delivery.id },
        data: { status: "SKIPPED", responseMessage: "家长未启用 Server酱³" },
      })
    }
    return delivery
  }

  const title = `🌟 ${params.kidNickname || "小朋友"}完成了任务`
  const state = params.autoApproved ? "已自动通过" : "等待家长审核"
  const lines = [
    `小朋友：${params.kidNickname || "小朋友"}`,
    `任务：${params.taskName}`,
    `积分：+${formatPoints(params.points)}⭐`,
    `状态：${state}`,
    `时间：${formatCompletedAt(params.completedAt, params.timezone)}`,
  ]
  const link = appUrl("/admin/tasks")
  if (link) lines.push(`\n[打开 StarKids](${link})`)

  let result
  try {
    result = await sendServerChan3({
      sendKey: decryptServerChanSendKey(setting.sendKeyCiphertext),
      title,
      desp: lines.join("\n"),
      short: `${params.taskName} +${formatPoints(params.points)}⭐ · ${state}`,
      tags: "StarKids|任务完成",
    })
  } catch (error) {
    result = {
      ok: false,
      code: null,
      httpStatus: 0,
      message: error instanceof Error ? error.message : "推送配置读取失败",
    }
  }

  return prisma.pushDelivery.update({
    where: { id: delivery.id },
    data: {
      status: result.ok ? "SENT" : "FAILED",
      attemptCount: { increment: 1 },
      responseCode: result.code,
      responseMessage: result.message.slice(0, 500),
      errorMessage: result.ok ? null : result.message.slice(0, 500),
      sentAt: result.ok ? new Date() : null,
    },
  })
}

export async function sendFamilyTaskCompletionPush(params: {
  familyId: string
  completionId: string
  kidNickname: string
  taskName: string
  points: number
  autoApproved: boolean
  completedAt: Date
}) {
  const family = await prisma.family.findUnique({
    where: { id: params.familyId },
    select: { timezone: true },
  })
  if (!family) return []

  const parents = await prisma.familyMember.findMany({
    where: { familyId: params.familyId, role: "PARENT" },
    select: {
      id: true,
      pushSetting: {
        select: { enabled: true, sendKeyCiphertext: true },
      },
    },
  })

  const sendKeys = new Set<string>()
  const recipients = parents.filter((parent) => {
    const setting = parent.pushSetting
    if (!setting?.enabled) return true

    try {
      // Legacy family settings were copied to every parent. Compare plaintext
      // keys because saving the same key again produces different ciphertext.
      const sendKey = decryptServerChanSendKey(setting.sendKeyCiphertext).trim()
      if (sendKeys.has(sendKey)) return false
      sendKeys.add(sendKey)
    } catch {
      // Let the normal delivery flow record invalid settings as FAILED.
    }
    return true
  })

  return Promise.all(recipients.map((parent) => sendParentTaskCompletionPush({
    parent,
    timezone: family.timezone,
    ...params,
  })))
}

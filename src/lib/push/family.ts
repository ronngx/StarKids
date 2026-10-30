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

export async function sendFamilyTaskCompletionPush(params: {
  familyId: string
  completionId: string
  kidNickname: string
  taskName: string
  points: number
  autoApproved: boolean
  completedAt: Date
}) {
  const setting = await prisma.familyPushSetting.findUnique({
    where: { familyId: params.familyId },
    include: { family: { select: { timezone: true } } },
  })

  const delivery = await prisma.pushDelivery.upsert({
    where: {
      completionId_provider: {
        completionId: params.completionId,
        provider: "SERVERCHAN3",
      },
    },
    create: {
      completionId: params.completionId,
      familyId: params.familyId,
      provider: "SERVERCHAN3",
      status: setting?.enabled ? "PENDING" : "SKIPPED",
      responseMessage: !setting
        ? "家庭未配置 Server酱³"
        : setting.enabled ? undefined : "家庭未启用 Server酱³",
    },
    update: {},
  })

  if (delivery.status === "SENT") return delivery

  if (!setting || !setting.enabled) {
    if (delivery.status !== "SKIPPED") {
      return prisma.pushDelivery.update({
        where: { id: delivery.id },
        data: { status: "SKIPPED", responseMessage: "家庭未启用 Server酱³" },
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
    `时间：${formatCompletedAt(params.completedAt, setting.family.timezone)}`,
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

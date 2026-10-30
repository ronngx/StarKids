import { NextResponse } from "next/server"
import {
  disableFamilyPush,
  getFamilyPushSetting,
  saveFamilyPushSetting,
  testFamilyPush,
} from "@/lib/actions/push"

export async function GET() {
  try {
    return NextResponse.json(await getFamilyPushSetting())
  } catch (error) {
    const message = error instanceof Error ? error.message : "无法读取推送设置"
    return NextResponse.json({ error: message }, { status: message === "请先登录" ? 401 : 403 })
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json() as {
      sendKey?: unknown
      enabled?: unknown
      test?: unknown
    }

    if (body.test === true) {
      return NextResponse.json(await testFamilyPush())
    }

    if (body.sendKey !== undefined && typeof body.sendKey !== "string") {
      return NextResponse.json({ error: "SendKey 必须是文本" }, { status: 400 })
    }
    if (body.enabled !== undefined && typeof body.enabled !== "boolean") {
      return NextResponse.json({ error: "推送开关格式无效" }, { status: 400 })
    }

    return NextResponse.json(await saveFamilyPushSetting({
      sendKey: body.sendKey as string | undefined,
      enabled: body.enabled as boolean | undefined,
    }))
  } catch (error) {
    const message = error instanceof Error ? error.message : "保存推送设置失败"
    const status = message === "请先登录" ? 401 : message.includes("只有家长") ? 403 : 400
    return NextResponse.json({ error: message }, { status })
  }
}

export async function DELETE() {
  try {
    return NextResponse.json(await disableFamilyPush())
  } catch (error) {
    const message = error instanceof Error ? error.message : "禁用推送失败"
    return NextResponse.json({ error: message }, { status: message === "请先登录" ? 401 : 403 })
  }
}

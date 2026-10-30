import { createCipheriv, createDecipheriv, createHash, randomBytes } from "node:crypto"
import { getAppSecret } from "@/lib/config"

const SEND_KEY_PATTERN = /^sctp(\d+)t[^\s]+$/
const DEFAULT_TIMEOUT_MS = Number(process.env.PUSH_REQUEST_TIMEOUT_MS) || 5_000

export type ServerChanSendResult = {
  ok: boolean
  code: number | null
  message: string
  httpStatus: number
}

function encryptionKey() {
  return createHash("sha256").update(getAppSecret()).digest()
}

export function extractServerChanUid(sendKey: string) {
  const normalized = sendKey.trim()
  const match = normalized.match(SEND_KEY_PATTERN)
  if (!match) throw new Error("SendKey 格式无效，请从 Server酱³ 的 SendKey 页面复制")
  return match[1]
}

export function validateServerChanSendKey(sendKey: string) {
  extractServerChanUid(sendKey)
  return sendKey.trim()
}

export function maskServerChanSendKey(sendKey: string) {
  const normalized = sendKey.trim()
  if (normalized.length <= 10) return "********"
  const hiddenLength = Math.max(0, Math.min(8, normalized.length - 12))
  return `${normalized.slice(0, 8)}${"*".repeat(hiddenLength)}${normalized.slice(-4)}`
}

export function encryptServerChanSendKey(sendKey: string) {
  const iv = randomBytes(12)
  const cipher = createCipheriv("aes-256-gcm", encryptionKey(), iv)
  const ciphertext = Buffer.concat([cipher.update(sendKey, "utf8"), cipher.final()])
  const tag = cipher.getAuthTag()
  return ["v1", iv.toString("base64url"), tag.toString("base64url"), ciphertext.toString("base64url")].join(".")
}

export function decryptServerChanSendKey(payload: string) {
  const [version, ivText, tagText, ciphertextText] = payload.split(".")
  if (version !== "v1" || !ivText || !tagText || !ciphertextText) {
    throw new Error("Server酱³ SendKey 配置损坏")
  }

  try {
    const decipher = createDecipheriv(
      "aes-256-gcm",
      encryptionKey(),
      Buffer.from(ivText, "base64url")
    )
    decipher.setAuthTag(Buffer.from(tagText, "base64url"))
    return Buffer.concat([
      decipher.update(Buffer.from(ciphertextText, "base64url")),
      decipher.final(),
    ]).toString("utf8")
  } catch {
    throw new Error("Server酱³ SendKey 解密失败")
  }
}

export async function sendServerChan3(params: {
  sendKey: string
  title: string
  desp: string
  tags?: string
  short?: string
  timeoutMs?: number
}): Promise<ServerChanSendResult> {
  const sendKey = validateServerChanSendKey(params.sendKey)
  const uid = extractServerChanUid(sendKey)
  const endpoint = `https://${uid}.push.ft07.com/send/${encodeURIComponent(sendKey)}.send`
  const body = new URLSearchParams({ title: params.title, desp: params.desp })
  if (params.tags) body.set("tags", params.tags)
  if (params.short) body.set("short", params.short)

  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), params.timeoutMs ?? DEFAULT_TIMEOUT_MS)

  try {
    const response = await fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body,
      signal: controller.signal,
    })

    const text = await response.text()
    let result: { code?: unknown; message?: unknown } = {}
    try {
      result = JSON.parse(text) as typeof result
    } catch {
      result = {}
    }

    const code = typeof result.code === "number" ? result.code : null
    const message = typeof result.message === "string" ? result.message : text.slice(0, 300)
    return {
      ok: response.ok && code === 0,
      code,
      message: message || (response.ok ? "Server酱³ 未返回消息" : `HTTP ${response.status}`),
      httpStatus: response.status,
    }
  } catch (error) {
    const message = error instanceof Error && error.name === "AbortError"
      ? "Server酱³ 请求超时"
      : error instanceof Error ? error.message : "Server酱³ 请求失败"
    return { ok: false, code: null, message, httpStatus: 0 }
  } finally {
    clearTimeout(timeout)
  }
}

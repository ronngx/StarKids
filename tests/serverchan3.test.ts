/** Run: npx tsx --test tests/serverchan3.test.ts */
import assert from "node:assert/strict"
import { test } from "node:test"
import {
  decryptServerChanSendKey,
  encryptServerChanSendKey,
  extractServerChanUid,
  sendServerChan3,
} from "../src/lib/push/serverchan3"


test("Server酱³ SendKey 可以校验、提取 UID 并加解密", () => {
  const sendKey = "sctp12345t-test-secret"
  assert.equal(extractServerChanUid(sendKey), "12345")
  const encrypted = encryptServerChanSendKey(sendKey)
  assert.notEqual(encrypted, sendKey)
  assert.equal(decryptServerChanSendKey(encrypted), sendKey)
  assert.throws(() => extractServerChanUid("invalid-key"), /SendKey 格式无效/)
})

test("Server酱³ 适配器发送表单参数并识别成功响应", async () => {
  const originalFetch = globalThis.fetch
  let requestUrl = ""
  let requestBody = ""
  globalThis.fetch = async (input, init) => {
    requestUrl = String(input)
    requestBody = String(init?.body)
    return new Response(JSON.stringify({ code: 0, message: "发送成功" }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    })
  }

  try {
    const result = await sendServerChan3({
      sendKey: "sctp12345t-test-secret",
      title: "任务完成",
      desp: "刷牙 +5⭐",
      tags: "StarKids|任务完成",
      short: "刷牙 +5⭐",
    })
    assert.equal(result.ok, true)
    assert.equal(result.code, 0)
    assert.equal(requestUrl, "https://12345.push.ft07.com/send/sctp12345t-test-secret.send")
    const params = new URLSearchParams(requestBody)
    assert.equal(params.get("title"), "任务完成")
    assert.equal(params.get("desp"), "刷牙 +5⭐")
    assert.equal(params.get("tags"), "StarKids|任务完成")
    assert.equal(params.get("short"), "刷牙 +5⭐")
  } finally {
    globalThis.fetch = originalFetch
  }
})

test("Server酱³ 非零返回码会作为失败处理", async () => {
  const originalFetch = globalThis.fetch
  globalThis.fetch = async () => new Response(JSON.stringify({ code: 400, message: "SendKey 无效" }), { status: 200 })
  try {
    const result = await sendServerChan3({
      sendKey: "sctp12345t-test-secret",
      title: "测试",
      desp: "测试",
    })
    assert.equal(result.ok, false)
    assert.equal(result.code, 400)
    assert.match(result.message, /SendKey 无效/)
  } finally {
    globalThis.fetch = originalFetch
  }
})

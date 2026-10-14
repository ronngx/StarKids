/** Run: npx tsx --test tests/task-toggle.test.ts */
import assert from "node:assert/strict"
import { after, before, beforeEach, test } from "node:test"
import { execFileSync } from "node:child_process"
import { mkdtempSync, rmSync, writeFileSync } from "node:fs"
import { createRequire } from "node:module"
import path from "node:path"
import { build } from "esbuild"
import { PrismaClient } from "@prisma/client"
import { PrismaBetterSqlite3 } from "@prisma/adapter-better-sqlite3"

const root = path.resolve(__dirname, "..")
const require = createRequire(path.join(root, "package.json"))
const testDir = mkdtempSync(path.join(root, "tests/.task-toggle-"))
const databaseUrl = `file:${path.join(testDir, "test.db")}`
const db = new PrismaClient({ adapter: new PrismaBetterSqlite3({ url: databaseUrl }) })
const state = { db, userId: "kid", revalidated: [] as string[] }
Object.assign(globalThis, { __taskToggleTest: state })
let actions: typeof import("../src/lib/actions/tasks")
let taskId: string

before(async () => {
  // Use the real schema and business logic; replace only request authentication and cache APIs.
  const configPath = path.join(testDir, "prisma.config.ts")
  writeFileSync(configPath, `import { defineConfig } from "prisma/config"
export default defineConfig({
  schema: ${JSON.stringify(path.join(root, "prisma/schema.prisma"))},
  datasource: { url: ${JSON.stringify(databaseUrl)} },
})`)
  const prismaCli = path.join(path.dirname(require.resolve("prisma/package.json")), "build/index.js")
  execFileSync(process.execPath, [prismaCli, "db", "push", "--config", configPath], {
    cwd: root,
    stdio: "pipe",
  })
  const bundlePath = path.join(testDir, "actions.cjs")
  await build({
    entryPoints: [path.join(root, "src/lib/actions/tasks.ts")],
    outfile: bundlePath,
    bundle: true,
    platform: "node",
    format: "cjs",
    packages: "external",
    plugins: [{
      name: "request-context",
      setup(builder) {
        builder.onResolve({ filter: /^(@\/auth|@\/lib\/db|next\/cache)$/ }, (args) => ({
          path: args.path, namespace: "request-context",
        }))
        builder.onLoad({ filter: /.*/, namespace: "request-context" }, (args) => ({
          contents: args.path === "@/auth"
            ? "export async function auth() { const id = globalThis.__taskToggleTest.userId; return id ? { user: { id } } : null }"
            : args.path === "@/lib/db"
              ? "export const prisma = globalThis.__taskToggleTest.db"
              : "export function revalidatePath(path) { globalThis.__taskToggleTest.revalidated.push(path) }",
        }))
      },
    }],
  })
  actions = require(bundlePath)
})

beforeEach(async () => {
  await db.family.deleteMany()
  await db.user.deleteMany()
  state.userId = "kid"
  state.revalidated.length = 0
  for (const id of ["kid", "parent", "other-kid"]) {
    await db.user.create({ data: { id, email: `${id}@test.invalid`, role: id === "parent" ? "PARENT" : "KID" } })
  }
  await db.family.create({
    data: {
      id: "family", name: "Test family",
      members: { create: [
        { id: "kid-member", userId: "kid", role: "KID", nickname: "小朋友", currentPoints: 100 },
        { id: "parent-member", userId: "parent", role: "PARENT" },
        { id: "other-member", userId: "other-kid", role: "KID" },
      ] },
    },
  })
  const task = await db.task.create({
    data: {
      name: "刷牙", familyId: "family", creatorId: "parent", points: 10,
      assignees: { connect: { id: "kid-member" } },
    },
  })
  taskId = task.id
})

after(async () => {
  await db.$disconnect()
  Reflect.deleteProperty(globalThis, "__taskToggleTest")
  rmSync(testDir, { recursive: true, force: true })
})

async function completion() {
  return db.taskCompletion.findFirstOrThrow({ where: { taskId, memberId: "kid-member" } })
}

async function balance() {
  return (await db.familyMember.findUniqueOrThrow({ where: { id: "kid-member" } })).currentPoints
}

async function addAchievement() {
  await db.achievement.create({
    data: {
      familyId: "family", name: "第一次完成", icon: "🏆", bonusPoints: 5,
      condition: JSON.stringify({ type: "TASK_COUNT", count: 1 }),
    },
  })
}

test("待审核任务可取消、清除审核通知并重新提交", async () => {
  await actions.completeTask(taskId)
  const first = await completion()
  assert.equal(first.status, "PENDING")
  assert.equal(await db.notification.count(), 1)
  await actions.cancelTaskCompletion(first.id)
  assert.equal(await db.taskCompletion.count(), 0)
  assert.equal(await db.notification.count(), 0)
  assert.equal(await balance(), 100)
  await actions.completeTask(taskId)
  assert.equal((await completion()).status, "PENDING")
  assert.ok(state.revalidated.includes("/kids/tasks"))
  assert.ok(state.revalidated.includes("/admin/tasks"))
})

test("自动审核任务撤回实际积分及本次成就，反复勾选不累加奖励", async () => {
  await db.task.update({ where: { id: taskId }, data: { autoApprove: true } })
  await addAchievement()
  for (let i = 0; i < 3; i++) {
    await actions.completeTask(taskId)
    const current = await completion()
    assert.equal(current.status, "APPROVED")
    assert.equal(current.pointsEarned, 15)
    assert.equal(await balance(), 115)
    assert.equal(await db.achievementGrant.count(), 1)
    await actions.cancelTaskCompletion(current.id)
    assert.equal(await balance(), 100)
    assert.equal(await db.achievementGrant.count(), 0)
  }
})

test("家长审核后可取消，重复审核不会重复加分", async () => {
  await addAchievement()
  await actions.completeTask(taskId)
  const pending = await completion()
  state.userId = "parent"
  await actions.approveTask(pending.id)
  assert.equal(await balance(), 115)
  await assert.rejects(actions.approveTask(pending.id))
  assert.equal(await balance(), 115)
  state.userId = "kid"
  await actions.cancelTaskCompletion(pending.id)
  assert.equal(await balance(), 100)
  assert.equal(await db.achievementGrant.count(), 0)
  state.userId = "parent"
  await assert.rejects(actions.approveTask(pending.id))
  await assert.rejects(actions.rejectTask(pending.id))
  assert.equal(await balance(), 100)
})

test("拒绝未登录、他人任务及非今日记录的取消请求", async () => {
  await actions.completeTask(taskId)
  const pending = await completion()
  state.userId = ""
  await assert.rejects(actions.cancelTaskCompletion(pending.id), /请先登录/)
  state.userId = "other-kid"
  await assert.rejects(actions.cancelTaskCompletion(pending.id), /自己今天/)
  state.userId = "kid"
  for (const offset of [-1, 1]) {
    const date = new Date()
    date.setHours(0, 0, 0, 0)
    date.setDate(date.getDate() + offset)
    await db.taskCompletion.update({ where: { id: pending.id }, data: { date } })
    await assert.rejects(actions.cancelTaskCompletion(pending.id), /自己今天/)
  }
  assert.equal(await db.taskCompletion.count(), 1)
  assert.equal(await balance(), 100)
})

test("并发取消只扣一次积分，旧请求不能取消重新提交的记录", async () => {
  await db.task.update({ where: { id: taskId }, data: { autoApprove: true } })
  await actions.completeTask(taskId)
  const first = await completion()
  const results = await Promise.allSettled([
    actions.cancelTaskCompletion(first.id), actions.cancelTaskCompletion(first.id),
  ])
  assert.equal(results.filter((result) => result.status === "fulfilled").length, 1)
  assert.equal(await balance(), 100)
  await actions.completeTask(taskId)
  await assert.rejects(actions.cancelTaskCompletion(first.id))
  assert.equal(await balance(), 110)
  assert.equal(await db.taskCompletion.count(), 1)
})

test("取消事务失败时保留完成记录和积分", async () => {
  await db.task.update({ where: { id: taskId }, data: { autoApprove: true } })
  await actions.completeTask(taskId)
  const current = await completion()
  const failingDb = db.$extends({ query: { familyMember: { async update() {
    throw new Error("模拟积分更新失败")
  } } } })
  // The bundled actions read the database reference once; alter the transaction delegate temporarily.
  const originalTransaction = db.$transaction.bind(db)
  Object.assign(db, { $transaction: failingDb.$transaction.bind(failingDb) })
  try {
    await assert.rejects(actions.cancelTaskCompletion(current.id), /模拟积分更新失败/)
  } finally {
    Object.assign(db, { $transaction: originalTransaction })
  }
  assert.equal(await db.taskCompletion.count(), 1)
  assert.equal(await balance(), 110)
})

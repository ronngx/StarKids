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
const testDir = mkdtempSync(path.join(root, "tests/.points-engine-"))
const databaseUrl = `file:${path.join(testDir, "test.db")}`
const db = new PrismaClient({ adapter: new PrismaBetterSqlite3({ url: databaseUrl }) })
const state = { db }
Object.assign(globalThis, { __pointsEngineTest: state })

let calculatePoints: typeof import("../src/lib/points-engine").calculatePoints
let familyId: string
let memberId: string

before(async () => {
  writeFileSync(path.join(testDir, "test.db"), "")
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

  const bundlePath = path.join(testDir, "points-engine.cjs")
  await build({
    entryPoints: [path.join(root, "src/lib/points-engine.ts")],
    outfile: bundlePath,
    bundle: true,
    platform: "node",
    format: "cjs",
    packages: "external",
    plugins: [{
      name: "database-context",
      setup(builder) {
        builder.onResolve({ filter: /^@\/lib\/db$/ }, () => ({
          path: "@/lib/db",
          namespace: "database-context",
        }))
        builder.onLoad({ filter: /.*/, namespace: "database-context" }, () => ({
          contents: "export const prisma = globalThis.__pointsEngineTest.db",
        }))
      },
    }],
  })
  ;({ calculatePoints } = require(bundlePath))
})

beforeEach(async () => {
  await db.family.deleteMany()
  await db.user.deleteMany()
  const user = await db.user.create({ data: { id: "kid", username: "kid", role: "KID" } })
  const family = await db.family.create({
    data: {
      id: "family",
      name: "测试家庭",
      members: { create: { id: "kid-member", userId: user.id, role: "KID" } },
    },
  })
  familyId = family.id
  memberId = "kid-member"
  await db.pointConfig.create({ data: { familyId, weekendDouble: true } })
})

after(async () => {
  await db.$disconnect()
  Reflect.deleteProperty(globalThis, "__pointsEngineTest")
  rmSync(testDir, { recursive: true, force: true })
})

test("weekendDouble 开关在没有 WEEKEND_DOUBLE 规则记录时仍然生效", async () => {
  const result = await calculatePoints(
    1,
    memberId,
    familyId,
    new Date("2026-10-31T12:00:00.000Z"),
  )
  assert.equal(result.totalPoints, 2)
  assert.equal(result.bonusPoints, 1)
})

test("工作日不触发 weekendDouble", async () => {
  const result = await calculatePoints(
    1,
    memberId,
    familyId,
    new Date("2026-11-02T12:00:00.000Z"),
  )
  assert.equal(result.totalPoints, 1)
  assert.equal(result.bonusPoints, 0)
})

test("已有 WEEKEND_DOUBLE 规则时使用规则倍数且不重复加倍", async () => {
  await db.pointRule.create({
    data: {
      familyId,
      ruleType: "WEEKEND_DOUBLE",
      name: "周末三倍",
      params: JSON.stringify({ multiplier: 3 }),
    },
  })
  const result = await calculatePoints(
    1,
    memberId,
    familyId,
    new Date("2026-10-31T12:00:00.000Z"),
  )
  assert.equal(result.totalPoints, 3)
  assert.equal(result.bonusPoints, 2)
})

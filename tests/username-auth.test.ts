/** Run: npx tsx --test tests/username-auth.test.ts */
import assert from "node:assert/strict"
import { after, before, beforeEach, test } from "node:test"
import { execFileSync } from "node:child_process"
import { mkdtempSync, rmSync, writeFileSync } from "node:fs"
import { createRequire } from "node:module"
import path from "node:path"
import { build } from "esbuild"
import bcrypt from "bcryptjs"
import { PrismaClient } from "@prisma/client"
import { PrismaBetterSqlite3 } from "@prisma/adapter-better-sqlite3"
import { usernameSchema } from "../src/lib/credentials"

const root = path.resolve(__dirname, "..")
const require = createRequire(path.join(root, "package.json"))
const testDir = mkdtempSync(path.join(root, "tests/.username-auth-"))
const db = new PrismaClient({ adapter: new PrismaBetterSqlite3({ url: `file:${testDir}/test.db` }) })
const state = { db, userId: null as string | null, config: null as any }
Object.assign(globalThis, { __usernameTest: state })
let registerUser: typeof import("../src/lib/actions/register").registerUser
let addKidToFamily: typeof import("../src/lib/actions/family").addKidToFamily
let updateFamilyMember: typeof import("../src/lib/actions/family").updateFamilyMember
let membersGET: typeof import("../src/app/api/family/members/route").GET
let membersPATCH: typeof import("../src/app/api/family/members/route").PATCH

function form(values: Record<string, string>) {
  const data = new FormData()
  for (const [key, value] of Object.entries(values)) data.set(key, value)
  return data
}

before(async () => {
  writeFileSync(path.join(testDir, "test.db"), "")
  const config = path.join(testDir, "prisma.config.ts")
  writeFileSync(config, `import { defineConfig } from "prisma/config"
export default defineConfig({schema: ${JSON.stringify(path.join(root, "prisma/schema.prisma"))},
datasource: {url: ${JSON.stringify(`file:${testDir}/test.db`)}}})`)
  const cli = path.join(path.dirname(require.resolve("prisma/package.json")), "build/index.js")
  execFileSync(process.execPath, [cli, "db", "push", "--config", config], { stdio: "pipe" })

  const out = path.join(testDir, "auth.cjs")
  // Keep real actions, auth callbacks, database queries and bcrypt. Only the
  // framework request/session boundary is replaced in this isolated database.
  await build({
    stdin: {
      contents: 'export * from "./src/auth"; export * from "./src/lib/actions/register"; export * from "./src/lib/actions/family"; export { GET as membersGET, PATCH as membersPATCH } from "./src/app/api/family/members/route";',
      resolveDir: root,
      loader: "ts",
    },
    outfile: out,
    bundle: true,
    platform: "node",
    format: "cjs",
    packages: "external",
    plugins: [{
      name: "framework-boundary",
      setup(builder) {
        builder.onResolve({ filter: /^(@\/lib\/db|@\/auth|next-auth|next\/cache|next\/navigation)$/ }, (args) => ({ path: args.path, namespace: "boundary" }))
        builder.onLoad({ filter: /.*/, namespace: "boundary" }, ({ path: name }) => ({
          contents: name === "@/lib/db" ? "export const prisma = globalThis.__usernameTest.db"
            : name === "@/auth" ? "export async function auth() { const id = globalThis.__usernameTest.userId; return id ? { user: { id } } : null }"
            : name === "next-auth" ? "export default function NextAuth(config) { config.providers = config.providers.map(p => ({ ...p, ...p.options })); globalThis.__usernameTest.config = config; return {} }"
            : name === "next/cache" ? "export function revalidatePath() {}"
            : "export function redirect(path) { throw new Error(path) }",
        }))
      },
    }],
  })
  ;({ registerUser, addKidToFamily, updateFamilyMember, membersGET, membersPATCH } = require(out))
})

beforeEach(async () => {
  await db.family.deleteMany()
  await db.user.deleteMany()
  state.userId = null
})

after(async () => {
  await db.$disconnect()
  Reflect.deleteProperty(globalThis, "__usernameTest")
  rmSync(testDir, { recursive: true, force: true })
})

test("register and authenticate a normalized Chinese username without an email", async () => {
  const password = "  secret123  "
  await registerUser(form({ username: "  爸爸Dad  ", password, nickname: "爸爸", role: "PARENT" }))
  const user = await db.user.findUniqueOrThrow({ where: { username: "爸爸dad" } })
  assert.ok(!("email" in user))
  assert.notEqual(user.passwordHash, password)
  assert.ok(await bcrypt.compare(password, user.passwordHash!))
  const authorize = state.config.providers[0].authorize
  const signedIn = await authorize({ username: " 爸爸DAD ", password })
  assert.equal(signedIn.id, user.id)
  assert.equal(signedIn.username, "爸爸dad")
  assert.ok((await db.user.findUniqueOrThrow({ where: { id: user.id } })).lastLoginAt)
  const token = await state.config.callbacks.jwt({ token: {}, user: signedIn })
  const session = await state.config.callbacks.session({ session: { user: {} }, token })
  assert.equal(session.user.username, "爸爸dad")
  assert.equal(session.user.role, "PARENT")
})

test("wrong passwords, disabled accounts and email-only credentials cannot log in", async () => {
  await registerUser(form({ username: "dad", password: "secret123", nickname: "爸爸" }))
  const authorize = state.config.providers[0].authorize
  assert.equal(await authorize({ username: "dad", password: "wrong123" }), null)
  assert.equal(await authorize({ email: "dad@example.com", password: "secret123" }), null)
  assert.equal(await authorize({ username: { invalid: true }, password: "secret123" }), null)
  await db.user.update({ where: { username: "dad" }, data: { isActive: false } })
  assert.equal(await authorize({ username: "dad", password: "secret123" }), null)
})

test("registration rejects duplicates regardless of case and concurrent requests", async () => {
  const values = { username: "  Dad ", password: "secret123", nickname: "爸爸" }
  const results = await Promise.allSettled([registerUser(form(values)), registerUser(form(values))])
  assert.equal(results.filter((result) => result.status === "fulfilled").length, 1)
  const failed = results.find((result) => result.status === "rejected") as PromiseRejectedResult
  assert.match(failed.reason.message, /用户名已被使用/)
  assert.equal(await db.user.count(), 1)
  await assert.rejects(registerUser(form({ ...values, username: "DAD" })), /用户名已被使用/)
})

test("server validation rejects missing usernames, email addresses, spaces and privileged roles", async () => {
  for (const username of ["", "a", "dad@example.com", "dad mom", "a".repeat(65)]) {
    assert.equal(usernameSchema.safeParse(username).success, false)
    await assert.rejects(registerUser(form({ username, password: "secret123", nickname: "爸爸" })))
  }
  await assert.rejects(registerUser(form({ username: "dad", password: "secret123", nickname: "爸爸", role: "ADMIN" })))
  await assert.rejects(registerUser(form({ username: "dad", password: "123", nickname: "爸爸" })))
  assert.equal(await db.user.count(), 0)
})

test("parents create a kid's username account and membership together, preserving password whitespace", async () => {
  await registerUser(form({ username: "dad", password: "secret123", nickname: "爸爸" }))
  const parent = await db.user.findUniqueOrThrow({ where: { username: "dad" } })
  await db.family.create({ data: { id: "family", name: "测试家庭", members: { create: { userId: parent.id, role: "PARENT", nickname: "爸爸" } } } })
  state.userId = parent.id
  await addKidToFamily(form({ username: "  朵朵Kid ", password: " secret123 ", nickname: "朵朵" }))
  const kid = await db.user.findUniqueOrThrow({ where: { username: "朵朵kid" }, include: { familyMembers: true } })
  assert.equal(kid.role, "KID")
  assert.equal(kid.familyMembers[0].familyId, "family")
  assert.ok(await bcrypt.compare(" secret123 ", kid.passwordHash!))
  assert.equal(await state.config.providers[0].authorize({ username: "朵朵kid", password: "secret123" }), null)
  await assert.rejects(addKidToFamily(form({ username: "朵朵KID", password: "secret123", nickname: "朵朵" })), /用户名已被使用/)
  assert.equal(await db.user.count(), 2)
  state.userId = kid.id
  await assert.rejects(addKidToFamily(form({ username: "otherkid", password: "secret123", nickname: "小明" })), /只有家长/)
})

test("a failed family membership cannot leave an orphaned kid account", async () => {
  await registerUser(form({ username: "dad", password: "secret123", nickname: "爸爸" }))
  const parent = await db.user.findUniqueOrThrow({ where: { username: "dad" } })
  await db.family.create({ data: { id: "family", name: "测试家庭", members: { create: { userId: parent.id, role: "PARENT" } } } })
  state.userId = parent.id
  await db.$executeRawUnsafe(`CREATE TRIGGER reject_kid BEFORE INSERT ON family_members WHEN NEW.role = 'KID' BEGIN SELECT RAISE(ABORT, 'membership rejected'); END`)
  try {
    await assert.rejects(addKidToFamily(form({ username: "xiaoming", password: "secret123", nickname: "小明" })))
    assert.equal(await db.user.findUnique({ where: { username: "xiaoming" } }), null)
  } finally {
    await db.$executeRawUnsafe("DROP TRIGGER reject_kid")
  }
})

async function editableFamily() {
  const passwordHash = await bcrypt.hash("original123", 4)
  const parent = await db.user.create({ data: { username: "dad", name: "爸爸", role: "PARENT", passwordHash } })
  const otherParent = await db.user.create({ data: { username: "mom", name: "妈妈", role: "PARENT", passwordHash } })
  const kid = await db.user.create({ data: { username: "kid", name: "朵朵", role: "KID", passwordHash } })
  const family = await db.family.create({
    data: { name: "测试家庭", members: { create: [
      { userId: parent.id, role: "PARENT", nickname: "爸爸" },
      { userId: otherParent.id, role: "PARENT", nickname: "妈妈" },
      { userId: kid.id, role: "KID", nickname: "朵朵", currentPoints: 42 },
    ] } },
    include: { members: true },
  })
  state.userId = parent.id
  return { parent, otherParent, kid, family, passwordHash }
}

test("parents edit themselves and other parents, retain blank passwords, and safely refresh their session", async () => {
  const { parent, otherParent, family, passwordHash } = await editableFamily()
  for (const user of [parent, otherParent]) {
    const member = family.members.find((m) => m.userId === user.id)!
    await updateFamilyMember(form({ memberId: member.id, nickname: " 新昵称 ", username: ` ${user.username.toUpperCase()} `, password: "" }))
    const account = await db.user.findUniqueOrThrow({ where: { id: user.id } })
    assert.equal(account.username, user.username)
    assert.equal(account.name, "新昵称")
    assert.equal(account.passwordHash, passwordHash)
    assert.equal(account.role, "PARENT")
    assert.equal((await db.familyMember.findUniqueOrThrow({ where: { id: member.id } })).nickname, "新昵称")
  }
  const self = family.members.find((m) => m.userId === parent.id)!
  await updateFamilyMember(form({ memberId: self.id, nickname: "爸爸新名", username: " NewDad " }))
  const token = await state.config.callbacks.jwt({
    token: { id: parent.id, role: "PARENT", username: "dad", name: "爸爸" },
    trigger: "update",
    session: { id: otherParent.id, role: "ADMIN", username: "forged", name: "forged" },
  })
  const session = await state.config.callbacks.session({ session: { user: {} }, token })
  assert.equal(session.user.id, parent.id)
  assert.equal(session.user.role, "PARENT")
  assert.equal(session.user.username, "newdad")
  assert.equal(session.user.name, "爸爸新名")
})

test("member API resets a kid's login credentials without changing roles or points", async () => {
  const { kid, family } = await editableFamily()
  const member = family.members.find((m) => m.userId === kid.id)!
  const response = await membersPATCH(new Request("http://localhost/api/family/members", {
    method: "PATCH",
    body: form({ memberId: member.id, nickname: "小朋友", username: "  朵朵NEW ", password: " newSecret123 ", role: "ADMIN", userId: "untrusted" }),
  }))
  assert.equal(response.status, 200)
  assert.deepEqual(await response.json(), { success: true, nickname: "小朋友" })
  const updated = await db.user.findUniqueOrThrow({ where: { id: kid.id } })
  assert.equal(updated.username, "朵朵new")
  assert.equal(updated.role, "KID")
  const membership = await db.familyMember.findUniqueOrThrow({ where: { id: member.id } })
  assert.equal(membership.nickname, "小朋友")
  assert.equal(membership.role, "KID")
  assert.equal(membership.currentPoints, 42)
  const authorize = state.config.providers[0].authorize
  assert.equal(await authorize({ username: "kid", password: "original123" }), null)
  assert.equal(await authorize({ username: "朵朵new", password: "original123" }), null)
  assert.equal(await authorize({ username: "朵朵new", password: "newSecret123" }), null)
  assert.equal((await authorize({ username: "朵朵NEW", password: " newSecret123 " })).id, kid.id)
  const listing = await (await membersGET()).json()
  assert.equal(listing.canManageMembers, true)
  assert.equal(listing.members.find((m: any) => m.id === member.id).user.username, "朵朵new")
  assert.ok(!JSON.stringify(listing).includes("passwordHash"))
})

test("member edits reject unauthenticated users, kids, users without a family and other families", async () => {
  const { parent, kid, family } = await editableFamily()
  const member = family.members.find((m) => m.userId === kid.id)!
  const values = { memberId: member.id, nickname: "新昵称", username: "newkid" }
  state.userId = null
  await assert.rejects(updateFamilyMember(form(values)), /请先登录/)
  assert.equal((await membersGET()).status, 401)
  state.userId = kid.id
  await assert.rejects(updateFamilyMember(form(values)), /只有家长/)
  assert.equal((await (await membersGET()).json()).canManageMembers, false)
  const outsider = await db.user.create({ data: { username: "outsider", role: "PARENT" } })
  state.userId = outsider.id
  await assert.rejects(updateFamilyMember(form(values)), /只有家长/)
  await db.family.create({ data: { name: "另一个家庭", members: { create: { userId: outsider.id, role: "PARENT" } } } })
  const response = await membersPATCH(new Request("http://localhost/api/family/members", { method: "PATCH", body: form(values) }))
  assert.equal(response.status, 400)
  assert.match((await response.json()).error, /不在当前家庭/)
  state.userId = parent.id
  await assert.rejects(updateFamilyMember(form({ ...values, memberId: "nonexistent" })), /不在当前家庭/)
  assert.equal((await db.user.findUniqueOrThrow({ where: { id: kid.id } })).username, "kid")
  assert.equal((await db.familyMember.findUniqueOrThrow({ where: { id: member.id } })).nickname, "朵朵")
})

test("invalid member edits and case-insensitive duplicate usernames leave original data intact", async () => {
  const { kid, family, passwordHash } = await editableFamily()
  const member = family.members.find((m) => m.userId === kid.id)!
  const values = { memberId: member.id, nickname: "新昵称", username: "newkid", password: "" }
  await assert.rejects(updateFamilyMember(form({ ...values, username: " DAD " })), /用户名已被使用/)
  for (const changes of [{ nickname: "  " }, { username: "a@b.com" }, { password: "123" }]) {
    await assert.rejects(updateFamilyMember(form({ ...values, ...changes })))
  }
  const account = await db.user.findUniqueOrThrow({ where: { id: kid.id } })
  assert.equal(account.username, "kid")
  assert.equal(account.passwordHash, passwordHash)
  assert.equal((await db.familyMember.findUniqueOrThrow({ where: { id: member.id } })).nickname, "朵朵")
})

test("failed member writes roll back account names, usernames and passwords together", async () => {
  const { kid, family, passwordHash } = await editableFamily()
  const member = family.members.find((m) => m.userId === kid.id)!
  await db.$executeRawUnsafe(`CREATE TRIGGER reject_member_edit BEFORE UPDATE ON family_members BEGIN SELECT RAISE(ABORT, 'edit rejected'); END`)
  try {
    await assert.rejects(updateFamilyMember(form({ memberId: member.id, nickname: "新昵称", username: "newkid", password: "newSecret123" })))
    const account = await db.user.findUniqueOrThrow({ where: { id: kid.id } })
    assert.equal(account.username, "kid")
    assert.equal(account.name, "朵朵")
    assert.equal(account.passwordHash, passwordHash)
    assert.equal((await db.familyMember.findUniqueOrThrow({ where: { id: member.id } })).nickname, "朵朵")
  } finally {
    await db.$executeRawUnsafe("DROP TRIGGER reject_member_edit")
  }
})

test("concurrent member edits cannot claim the same username or leave partial nicknames", async () => {
  const { kid, otherParent, family } = await editableFamily()
  const targets = [kid, otherParent].map((user) => family.members.find((m) => m.userId === user.id)!)
  const results = await Promise.allSettled(targets.map((member) => updateFamilyMember(form({ memberId: member.id, nickname: "新昵称", username: "sharedname" }))))
  assert.equal(results.filter((r) => r.status === "fulfilled").length, 1)
  assert.match((results.find((r) => r.status === "rejected") as PromiseRejectedResult).reason.message, /用户名已被使用/)
  for (const member of targets) {
    const account = await db.user.findUniqueOrThrow({ where: { id: member.userId } })
    const updated = await db.familyMember.findUniqueOrThrow({ where: { id: member.id } })
    assert.equal(updated.nickname, account.username === "sharedname" ? "新昵称" : member.nickname)
  }
})

test("SQLite migration preserves passwords, relationships and case-insensitive collisions, and is repeatable", () => {
  const Database = require("better-sqlite3")
  const file = path.join(testDir, "legacy.db")
  const legacy = new Database(file)
  legacy.exec(`PRAGMA foreign_keys = ON;
    CREATE TABLE users (id TEXT PRIMARY KEY, email TEXT NOT NULL, emailVerified TEXT, passwordHash TEXT);
    CREATE UNIQUE INDEX users_email_key ON users(email);
    CREATE TABLE family_members (id TEXT PRIMARY KEY, userId TEXT NOT NULL REFERENCES users(id), currentPoints INTEGER);
    INSERT INTO users VALUES ('parent', ' Dad@example.com ', NULL, 'original-hash'),
      ('kid1', 'kid@one.example', NULL, 'hash1'), ('kid2', 'KID@two.example', NULL, 'hash2'),
      ('invalid', 'bad+name@example.com', NULL, 'hash3'), ('reserved', 'legacy_kid1@example.com', NULL, 'hash4'),
      ('chinese', '爸爸@example.com', NULL, 'hash5');
    INSERT INTO family_members VALUES ('member', 'parent', 100);`)
  legacy.close()
  const script = path.join(root, "scripts/migrate-usernames-sqlite.cjs")
  execFileSync(process.execPath, [script, file], { stdio: "pipe" })
  execFileSync(process.execPath, [script, file], { stdio: "pipe" })
  const migrated = new Database(file)
  try {
    const rows = migrated.prepare("SELECT * FROM users ORDER BY id").all()
    assert.deepEqual(rows.map((row: any) => row.username), ["爸爸", "legacy_invalid", "legacy_kid1", "legacy_kid2", "dad", "legacy_reserved"])
    assert.ok(rows.every((row: any) => usernameSchema.safeParse(row.username).success))
    assert.equal(rows.find((row: any) => row.id === "parent").passwordHash, "original-hash")
    assert.deepEqual(migrated.prepare("SELECT userId, currentPoints FROM family_members").get(), { userId: "parent", currentPoints: 100 })
    assert.deepEqual(migrated.prepare("PRAGMA foreign_key_check").all(), [])
    assert.ok(!migrated.prepare("PRAGMA table_info(users)").all().some((col: any) => ["email", "emailVerified"].includes(col.name)))
  } finally {
    migrated.close()
  }
})

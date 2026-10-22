// Upgrade an existing local SQLite database before running prisma db push.
const Database = require("better-sqlite3");
const { existsSync } = require("node:fs");
const { resolve } = require("node:path");

const databasePath = resolve(process.argv[2] || "dev.db");
if (!existsSync(databasePath)) {
  console.error("数据库文件不存在；新安装请直接运行 npm run db:push。");
  process.exit(1);
}

const db = new Database(databasePath, { fileMustExist: true });
try {
  const columns = db.prepare('PRAGMA table_info("users")').all();
  if (columns.some((column) => column.name === "username") && !columns.some((column) => column.name === "email")) {
    console.log("数据库已使用用户名，无需迁移。");
  } else {
    if (!columns.some((column) => column.name === "email")) {
      throw new Error("未找到旧版 users.email 字段，请检查数据库文件。");
    }
    const migrate = db.transaction(() => {
      const users = db.prepare('SELECT "id", "email" FROM "users"').all();
      const candidates = users.map((user) => ({ id: user.id, candidate: user.email.split("@")[0].trim().toLowerCase() }));
      const counts = new Map();
      for (const { candidate } of candidates) counts.set(candidate, (counts.get(candidate) || 0) + 1);
      db.exec('ALTER TABLE "users" RENAME COLUMN "email" TO "username"');
      if (columns.some((column) => column.name === "emailVerified")) {
        db.exec('ALTER TABLE "users" DROP COLUMN "emailVerified"');
      }
      db.exec('DROP INDEX IF EXISTS "users_email_key"');
      const update = db.prepare('UPDATE "users" SET "username" = ? WHERE "id" = ?');
      for (const { id, candidate } of candidates) {
        const valid = candidate.length >= 2 && candidate.length <= 64 && /^[\p{L}\p{N}_.-]+$/u.test(candidate);
        const username = valid && counts.get(candidate) === 1 && !candidate.startsWith("legacy_")
          ? candidate : `legacy_${id}`;
        update.run(username, id);
      }
      db.exec('CREATE UNIQUE INDEX "users_username_key" ON "users"("username")');
      return users.length;
    });
    console.log(`已迁移 ${migrate()} 个账号，原密码和家庭数据保留。`);
  }
} finally {
  db.close();
}

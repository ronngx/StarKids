-- 将家庭级推送配置拆分为每位家长独立配置。
PRAGMA foreign_keys=OFF;

CREATE TABLE "parent_push_settings" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "parentMemberId" TEXT NOT NULL,
    "provider" TEXT NOT NULL DEFAULT 'SERVERCHAN3',
    "sendKeyCiphertext" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "lastTestAt" DATETIME,
    "lastTestStatus" TEXT,
    "lastError" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "parent_push_settings_parentMemberId_fkey" FOREIGN KEY ("parentMemberId") REFERENCES "family_members" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- 旧家庭配置复制给该家庭当时的每位家长，避免升级后丢失已保存的 SendKey。
INSERT INTO "parent_push_settings" (
    "id", "parentMemberId", "provider", "sendKeyCiphertext", "enabled",
    "lastTestAt", "lastTestStatus", "lastError", "createdAt", "updatedAt"
)
SELECT
    lower(hex(randomblob(16))), fm."id", fps."provider", fps."sendKeyCiphertext", fps."enabled",
    fps."lastTestAt", fps."lastTestStatus", fps."lastError", fps."createdAt", fps."updatedAt"
FROM "family_push_settings" fps
JOIN "family_members" fm
  ON fm."familyId" = fps."familyId"
 AND fm."role" = 'PARENT';

DROP TABLE "family_push_settings";

ALTER TABLE "push_deliveries" RENAME TO "push_deliveries_old";

CREATE TABLE "push_deliveries" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "completionId" TEXT NOT NULL,
    "familyId" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "attemptCount" INTEGER NOT NULL DEFAULT 0,
    "responseCode" INTEGER,
    "responseMessage" TEXT,
    "errorMessage" TEXT,
    "sentAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "recipientMemberId" TEXT,
    CONSTRAINT "push_deliveries_completionId_fkey" FOREIGN KEY ("completionId") REFERENCES "task_completions" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "push_deliveries_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "families" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "push_deliveries_recipientMemberId_fkey" FOREIGN KEY ("recipientMemberId") REFERENCES "family_members" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

INSERT INTO "push_deliveries" (
    "id", "completionId", "familyId", "provider", "status", "attemptCount",
    "responseCode", "responseMessage", "errorMessage", "sentAt", "createdAt", "updatedAt", "recipientMemberId"
)
SELECT
    "id", "completionId", "familyId", "provider", "status", "attemptCount",
    "responseCode", "responseMessage", "errorMessage", "sentAt", "createdAt", "updatedAt", NULL
FROM "push_deliveries_old";

DROP TABLE "push_deliveries_old";

CREATE UNIQUE INDEX "parent_push_settings_parentMemberId_key" ON "parent_push_settings"("parentMemberId");
CREATE UNIQUE INDEX "push_deliveries_completionId_provider_recipientMemberId_key"
    ON "push_deliveries"("completionId", "provider", "recipientMemberId");
CREATE INDEX "push_deliveries_familyId_status_createdAt_idx"
    ON "push_deliveries"("familyId", "status", "createdAt");

PRAGMA foreign_keys=ON;

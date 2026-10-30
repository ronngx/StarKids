-- CreateTable
CREATE TABLE "family_push_settings" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "familyId" TEXT NOT NULL,
    "provider" TEXT NOT NULL DEFAULT 'SERVERCHAN3',
    "sendKeyCiphertext" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "lastTestAt" DATETIME,
    "lastTestStatus" TEXT,
    "lastError" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "family_push_settings_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "families" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
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
    CONSTRAINT "push_deliveries_completionId_fkey" FOREIGN KEY ("completionId") REFERENCES "task_completions" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "push_deliveries_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES "families" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "family_push_settings_familyId_key" ON "family_push_settings"("familyId");

-- CreateIndex
CREATE INDEX "push_deliveries_familyId_status_createdAt_idx" ON "push_deliveries"("familyId", "status", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "push_deliveries_completionId_provider_key" ON "push_deliveries"("completionId", "provider");

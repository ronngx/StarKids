-- Add virtual pet care state while preserving all existing pets.
ALTER TABLE "pets" ADD COLUMN "hunger" INTEGER NOT NULL DEFAULT 100;
ALTER TABLE "pets" ADD COLUMN "thirst" INTEGER NOT NULL DEFAULT 100;
ALTER TABLE "pets" ADD COLUMN "hygiene" INTEGER NOT NULL DEFAULT 100;
ALTER TABLE "pets" ADD COLUMN "energy" INTEGER NOT NULL DEFAULT 100;
ALTER TABLE "pets" ADD COLUMN "status" TEXT NOT NULL DEFAULT 'ALIVE';
ALTER TABLE "pets" ADD COLUMN "deathAt" TIMESTAMP;
ALTER TABLE "pets" ADD COLUMN "deathReason" TEXT;
ALTER TABLE "pets" ADD COLUMN "criticalSince" TIMESTAMP;
-- SQLite only accepts constant defaults while adding a NOT NULL column.
-- Existing pets are initialized to the migration time immediately below.
ALTER TABLE "pets" ADD COLUMN "lastSimulatedAt" TIMESTAMP NOT NULL DEFAULT '1970-01-01 00:00:00';
ALTER TABLE "pets" ADD COLUMN "lastFedAt" TIMESTAMP;
ALTER TABLE "pets" ADD COLUMN "lastWateredAt" TIMESTAMP;
ALTER TABLE "pets" ADD COLUMN "lastBathedAt" TIMESTAMP;
ALTER TABLE "pets" ADD COLUMN "lastPlayedAt" TIMESTAMP;

UPDATE "pets" SET "lastSimulatedAt" = CURRENT_TIMESTAMP;

CREATE TABLE "pet_interactions" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "petId" TEXT NOT NULL,
    "memberId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "idempotencyKey" TEXT,
    "effects" TEXT,
    "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "pet_interactions_petId_fkey" FOREIGN KEY ("petId") REFERENCES "pets" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "pet_interactions_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "family_members" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "pet_interactions_petId_createdAt_idx" ON "pet_interactions"("petId", "createdAt");
CREATE INDEX "pet_interactions_memberId_createdAt_idx" ON "pet_interactions"("memberId", "createdAt");
CREATE UNIQUE INDEX "pet_interactions_petId_idempotencyKey_key" ON "pet_interactions"("petId", "idempotencyKey");

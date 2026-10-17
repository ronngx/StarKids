-- The pet care migration originally created these fields as TEXT so it could
-- also be applied to SQLite. PostgreSQL needs the enum types used by Prisma.
DO $$
BEGIN
    CREATE TYPE "public"."PetStatus" AS ENUM ('ALIVE', 'CRITICAL', 'DEAD');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
    CREATE TYPE "public"."PetInteractionType" AS ENUM ('FEED', 'DRINK', 'BATH', 'PLAY', 'REST', 'REVIVE');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

ALTER TABLE "pets" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "pets"
    ALTER COLUMN "status" TYPE "public"."PetStatus"
    USING "status"::text::"public"."PetStatus";
ALTER TABLE "pets" ALTER COLUMN "status" SET DEFAULT 'ALIVE'::"public"."PetStatus";

ALTER TABLE "pet_interactions"
    ALTER COLUMN "type" TYPE "public"."PetInteractionType"
    USING "type"::text::"public"."PetInteractionType";

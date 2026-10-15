-- Keep user IDs, password hashes and all related family data intact.
BEGIN;

ALTER TABLE "users" RENAME COLUMN "email" TO "username";
ALTER TABLE "users" DROP COLUMN "emailVerified";
DROP INDEX "users_email_key";

-- Only unambiguous, valid local parts become short usernames. Reserve the
-- legacy_ prefix while assigning names so generated names cannot collide.
WITH candidates AS (
    SELECT "id", lower(btrim(split_part("username", '@', 1))) AS candidate
    FROM "users"
), counted AS (
    SELECT "id", candidate, count(*) OVER (PARTITION BY candidate) AS uses
    FROM candidates
)
UPDATE "users" AS u
SET "username" = CASE
    WHEN c.uses = 1
      AND char_length(c.candidate) BETWEEN 2 AND 64
      AND c.candidate ~ '^[[:alnum:]_.-]+$'
      AND left(c.candidate, 7) <> 'legacy_'
    THEN c.candidate
    ELSE 'legacy_' || u."id"
END
FROM counted AS c
WHERE u."id" = c."id";

CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

COMMIT;

-- Store family-specific costs for the four child-facing pet interactions.
-- Existing families remain free until a parent configures a cost.
ALTER TABLE "point_configs"
ADD COLUMN "petInteractionCosts" TEXT NOT NULL DEFAULT '{"FEED":0,"DRINK":0,"BATH":0,"PLAY":0}';

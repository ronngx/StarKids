--
-- PostgreSQL database dump
--

\restrict Ta1Ook1lnpaaKoyrcwHrnCdzOGd4K89jHwiYny9eb3DyxLmYlZCzcvQXOMPdhHH

-- Dumped from database version 17.11
-- Dumped by pg_dump version 17.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: AchievementCategory; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."AchievementCategory" AS ENUM (
    'LABOR',
    'STUDY',
    'EXERCISE',
    'HABIT',
    'SOCIAL',
    'REDEMPTION',
    'SPECIAL'
);


ALTER TYPE public."AchievementCategory" OWNER TO starkids;

--
-- Name: CompletionStatus; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."CompletionStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


ALTER TYPE public."CompletionStatus" OWNER TO starkids;

--
-- Name: MemberRole; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."MemberRole" AS ENUM (
    'PARENT',
    'KID'
);


ALTER TYPE public."MemberRole" OWNER TO starkids;

--
-- Name: NotificationPriority; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."NotificationPriority" AS ENUM (
    'LOW',
    'NORMAL',
    'HIGH'
);


ALTER TYPE public."NotificationPriority" OWNER TO starkids;

--
-- Name: NotificationType; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."NotificationType" AS ENUM (
    'TASK_COMPLETED',
    'TASK_APPROVED',
    'TASK_REJECTED',
    'REDEMPTION_REQUEST',
    'REDEMPTION_APPROVED',
    'REDEMPTION_REJECTED',
    'REDEMPTION_FULFILLED',
    'NEW_TASK',
    'PET_MISSING',
    'ACHIEVEMENT_UNLOCKED',
    'STREAK_REMINDER',
    'DAILY_REMINDER',
    'WEEKLY_REPORT',
    'LOW_STOCK'
);


ALTER TYPE public."NotificationType" OWNER TO starkids;

--
-- Name: PetInteractionType; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."PetInteractionType" AS ENUM (
    'FEED',
    'DRINK',
    'BATH',
    'PLAY',
    'REST',
    'REVIVE'
);


ALTER TYPE public."PetInteractionType" OWNER TO starkids;

--
-- Name: PetSpecies; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."PetSpecies" AS ENUM (
    'CAT',
    'DOG',
    'FOX',
    'RABBIT',
    'DRAGON',
    'UNICORN',
    'PANDA',
    'PENGUIN'
);


ALTER TYPE public."PetSpecies" OWNER TO starkids;

--
-- Name: PetStage; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."PetStage" AS ENUM (
    'EGG',
    'BABY',
    'GROWING',
    'EVOLVED',
    'ULTIMATE'
);


ALTER TYPE public."PetStage" OWNER TO starkids;

--
-- Name: PetStatus; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."PetStatus" AS ENUM (
    'ALIVE',
    'CRITICAL',
    'DEAD'
);


ALTER TYPE public."PetStatus" OWNER TO starkids;

--
-- Name: PointReason; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."PointReason" AS ENUM (
    'TASK_COMPLETE',
    'TASK_BONUS',
    'MANUAL_ADD',
    'MANUAL_SUB',
    'ACHIEVEMENT_BONUS',
    'REDEMPTION',
    'RESET',
    'SYSTEM_BONUS',
    'PET_OUTFIT'
);


ALTER TYPE public."PointReason" OWNER TO starkids;

--
-- Name: RedemptionStatus; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."RedemptionStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'FULFILLED'
);


ALTER TYPE public."RedemptionStatus" OWNER TO starkids;

--
-- Name: RewardCategory; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."RewardCategory" AS ENUM (
    'MONEY',
    'TOY',
    'BOOK',
    'ENTERTAINMENT',
    'PRIVILEGE',
    'EXPERIENCE',
    'CUSTOM'
);


ALTER TYPE public."RewardCategory" OWNER TO starkids;

--
-- Name: RewardStatus; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."RewardStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'SOLD_OUT'
);


ALTER TYPE public."RewardStatus" OWNER TO starkids;

--
-- Name: SkinType; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."SkinType" AS ENUM (
    'DEFAULT',
    'OCEAN',
    'SPACE',
    'FOREST',
    'CANDY',
    'DUNGEON',
    'RAINBOW'
);


ALTER TYPE public."SkinType" OWNER TO starkids;

--
-- Name: TaskCategory; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."TaskCategory" AS ENUM (
    'HOUSEWORK',
    'STUDY',
    'EXERCISE',
    'HABIT',
    'SOCIAL',
    'OTHER'
);


ALTER TYPE public."TaskCategory" OWNER TO starkids;

--
-- Name: TaskDifficulty; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."TaskDifficulty" AS ENUM (
    'EASY',
    'MEDIUM',
    'HARD'
);


ALTER TYPE public."TaskDifficulty" OWNER TO starkids;

--
-- Name: TaskFrequency; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."TaskFrequency" AS ENUM (
    'DAILY',
    'WEEKLY',
    'MANUAL'
);


ALTER TYPE public."TaskFrequency" OWNER TO starkids;

--
-- Name: TaskStatus; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."TaskStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'ARCHIVED'
);


ALTER TYPE public."TaskStatus" OWNER TO starkids;

--
-- Name: TaskType; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."TaskType" AS ENUM (
    'DAILY',
    'ONETIME',
    'CHALLENGE',
    'HABIT'
);


ALTER TYPE public."TaskType" OWNER TO starkids;

--
-- Name: TriggerConditionType; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."TriggerConditionType" AS ENUM (
    'TASK_COUNT',
    'CONSECUTIVE_DAYS',
    'TOTAL_POINTS',
    'REDEMPTION_COUNT',
    'SPECIFIC_TASK',
    'STREAK',
    'SPECIAL_DATE'
);


ALTER TYPE public."TriggerConditionType" OWNER TO starkids;

--
-- Name: UserAccountRole; Type: TYPE; Schema: public; Owner: starkids
--

CREATE TYPE public."UserAccountRole" AS ENUM (
    'ADMIN',
    'PARENT',
    'KID'
);


ALTER TYPE public."UserAccountRole" OWNER TO starkids;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _TaskAssignees; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public."_TaskAssignees" (
    "A" text NOT NULL,
    "B" text NOT NULL
);


ALTER TABLE public."_TaskAssignees" OWNER TO starkids;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO starkids;

--
-- Name: achievement_grants; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.achievement_grants (
    id text NOT NULL,
    "achievementId" text NOT NULL,
    "memberId" text NOT NULL,
    "grantedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "triggeredBy" text,
    context text
);


ALTER TABLE public.achievement_grants OWNER TO starkids;

--
-- Name: achievements; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.achievements (
    id text NOT NULL,
    "familyId" text,
    "isGlobal" boolean DEFAULT false NOT NULL,
    name text NOT NULL,
    description text,
    icon text NOT NULL,
    category public."AchievementCategory" DEFAULT 'SPECIAL'::public."AchievementCategory" NOT NULL,
    condition text NOT NULL,
    "bonusPoints" double precision DEFAULT 0 NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "isHidden" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.achievements OWNER TO starkids;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.comments (
    id text NOT NULL,
    "userId" text NOT NULL,
    "memberId" text,
    "completionId" text,
    content text NOT NULL,
    "isPinned" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.comments OWNER TO starkids;

--
-- Name: daily_stats; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.daily_stats (
    id text NOT NULL,
    "memberId" text NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    "tasksAssigned" integer DEFAULT 0 NOT NULL,
    "tasksCompleted" integer DEFAULT 0 NOT NULL,
    "tasksApproved" integer DEFAULT 0 NOT NULL,
    "pointsEarned" double precision DEFAULT 0 NOT NULL,
    "pointsSpent" double precision DEFAULT 0 NOT NULL,
    redemptions integer DEFAULT 0 NOT NULL,
    streak integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.daily_stats OWNER TO starkids;

--
-- Name: families; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.families (
    id text NOT NULL,
    name text NOT NULL,
    avatar text,
    description text,
    timezone text DEFAULT 'Asia/Shanghai'::text NOT NULL,
    "inviteCode" text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.families OWNER TO starkids;

--
-- Name: family_members; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.family_members (
    id text NOT NULL,
    "familyId" text NOT NULL,
    "userId" text NOT NULL,
    role public."MemberRole" NOT NULL,
    nickname text,
    avatar text,
    age integer,
    birthdate timestamp(3) without time zone,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "currentPoints" double precision DEFAULT 0 NOT NULL
);


ALTER TABLE public.family_members OWNER TO starkids;

--
-- Name: family_settings; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.family_settings (
    id text NOT NULL,
    "familyId" text NOT NULL,
    key text NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.family_settings OWNER TO starkids;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.notifications (
    id text NOT NULL,
    "userId" text NOT NULL,
    "memberId" text,
    type public."NotificationType" NOT NULL,
    priority public."NotificationPriority" DEFAULT 'NORMAL'::public."NotificationPriority" NOT NULL,
    title text NOT NULL,
    content text,
    link text,
    data text,
    "isRead" boolean DEFAULT false NOT NULL,
    "readAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.notifications OWNER TO starkids;

--
-- Name: pet_interactions; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.pet_interactions (
    id text NOT NULL,
    "petId" text NOT NULL,
    "memberId" text NOT NULL,
    type public."PetInteractionType" NOT NULL,
    "idempotencyKey" text,
    effects text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.pet_interactions OWNER TO starkids;

--
-- Name: pet_outfit_grants; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.pet_outfit_grants (
    id text NOT NULL,
    "outfitId" text NOT NULL,
    "memberId" text NOT NULL,
    "pointsSpent" double precision DEFAULT 0 NOT NULL,
    "unlockedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.pet_outfit_grants OWNER TO starkids;

--
-- Name: pet_outfits; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.pet_outfits (
    id text NOT NULL,
    "familyId" text,
    name text NOT NULL,
    description text,
    image text,
    species public."PetSpecies",
    points double precision DEFAULT 0 NOT NULL,
    "isDefault" boolean DEFAULT false NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.pet_outfits OWNER TO starkids;

--
-- Name: pets; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.pets (
    id text NOT NULL,
    "memberId" text NOT NULL,
    species public."PetSpecies" NOT NULL,
    name text DEFAULT '小宝贝'::text NOT NULL,
    level double precision DEFAULT 0 NOT NULL,
    stage public."PetStage" DEFAULT 'EGG'::public."PetStage" NOT NULL,
    mood integer DEFAULT 100 NOT NULL,
    "lastFeedDate" timestamp(3) without time zone,
    "lastMoodUpdate" timestamp(3) without time zone,
    "currentOutfit" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    hunger integer DEFAULT 100 NOT NULL,
    thirst integer DEFAULT 100 NOT NULL,
    hygiene integer DEFAULT 100 NOT NULL,
    energy integer DEFAULT 100 NOT NULL,
    status public."PetStatus" DEFAULT 'ALIVE'::public."PetStatus" NOT NULL,
    "deathAt" timestamp without time zone,
    "deathReason" text,
    "criticalSince" timestamp without time zone,
    "lastSimulatedAt" timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    "lastFedAt" timestamp without time zone,
    "lastWateredAt" timestamp without time zone,
    "lastBathedAt" timestamp without time zone,
    "lastPlayedAt" timestamp without time zone
);


ALTER TABLE public.pets OWNER TO starkids;

--
-- Name: point_configs; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.point_configs (
    id text NOT NULL,
    "familyId" text NOT NULL,
    "weekendDouble" boolean DEFAULT false NOT NULL,
    "birthdayTriple" boolean DEFAULT false NOT NULL,
    "enableDeduction" boolean DEFAULT false NOT NULL,
    "dailyCap" double precision DEFAULT 0 NOT NULL,
    "resetType" text DEFAULT 'NONE'::text NOT NULL,
    "streakBonuses" text DEFAULT '[{"days":3,"points":10},{"days":7,"points":50},{"days":14,"points":100},{"days":30,"points":300}]'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "petInteractionCosts" text DEFAULT '{"FEED":0,"DRINK":0,"BATH":0,"PLAY":0}'::text NOT NULL
);


ALTER TABLE public.point_configs OWNER TO starkids;

--
-- Name: point_logs; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.point_logs (
    id text NOT NULL,
    "memberId" text NOT NULL,
    amount double precision NOT NULL,
    reason public."PointReason" NOT NULL,
    "referenceId" text,
    "referenceType" text,
    note text,
    "balanceAfter" double precision NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.point_logs OWNER TO starkids;

--
-- Name: point_rules; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.point_rules (
    id text NOT NULL,
    "familyId" text NOT NULL,
    "ruleType" text NOT NULL,
    name text NOT NULL,
    description text,
    params text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.point_rules OWNER TO starkids;

--
-- Name: reward_redemptions; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.reward_redemptions (
    id text NOT NULL,
    "rewardId" text NOT NULL,
    "memberId" text NOT NULL,
    "pointsSpent" double precision NOT NULL,
    status public."RedemptionStatus" DEFAULT 'PENDING'::public."RedemptionStatus" NOT NULL,
    "kidMessage" text,
    "parentNote" text,
    "approvedBy" text,
    "approvedAt" timestamp(3) without time zone,
    "fulfilledAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.reward_redemptions OWNER TO starkids;

--
-- Name: rewards; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.rewards (
    id text NOT NULL,
    "familyId" text NOT NULL,
    name text NOT NULL,
    description text,
    image text,
    category public."RewardCategory" NOT NULL,
    tags text DEFAULT '[]'::text NOT NULL,
    points double precision NOT NULL,
    stock integer DEFAULT 0 NOT NULL,
    "remainingStock" integer DEFAULT 0 NOT NULL,
    "maxPerPerson" integer DEFAULT 0 NOT NULL,
    "cooldownDays" integer DEFAULT 0 NOT NULL,
    status public."RewardStatus" DEFAULT 'ACTIVE'::public."RewardStatus" NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "isFeatured" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.rewards OWNER TO starkids;

--
-- Name: task_completions; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.task_completions (
    id text NOT NULL,
    "taskId" text NOT NULL,
    "memberId" text NOT NULL,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "pointsEarned" double precision DEFAULT 0 NOT NULL,
    status public."CompletionStatus" DEFAULT 'PENDING'::public."CompletionStatus" NOT NULL,
    "approvedBy" text,
    "approvedAt" timestamp(3) without time zone,
    "parentNote" text,
    "proofImages" text DEFAULT '[]'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.task_completions OWNER TO starkids;

--
-- Name: task_templates; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.task_templates (
    id text NOT NULL,
    "familyId" text,
    "isGlobal" boolean DEFAULT false NOT NULL,
    name text NOT NULL,
    description text,
    icon text,
    category public."TaskCategory" DEFAULT 'OTHER'::public."TaskCategory" NOT NULL,
    type public."TaskType" DEFAULT 'DAILY'::public."TaskType" NOT NULL,
    frequency public."TaskFrequency" DEFAULT 'DAILY'::public."TaskFrequency" NOT NULL,
    difficulty public."TaskDifficulty" DEFAULT 'MEDIUM'::public."TaskDifficulty" NOT NULL,
    points double precision DEFAULT 10 NOT NULL,
    "autoApprove" boolean DEFAULT false NOT NULL,
    "maxDaily" integer DEFAULT 1 NOT NULL,
    "weekDays" text DEFAULT '[1,2,3,4,5]'::text NOT NULL,
    tags text DEFAULT '[]'::text NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.task_templates OWNER TO starkids;

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.tasks (
    id text NOT NULL,
    "familyId" text NOT NULL,
    name text NOT NULL,
    description text,
    icon text,
    image text,
    category public."TaskCategory" DEFAULT 'OTHER'::public."TaskCategory" NOT NULL,
    type public."TaskType" DEFAULT 'DAILY'::public."TaskType" NOT NULL,
    frequency public."TaskFrequency" DEFAULT 'MANUAL'::public."TaskFrequency" NOT NULL,
    difficulty public."TaskDifficulty" DEFAULT 'MEDIUM'::public."TaskDifficulty" NOT NULL,
    points double precision DEFAULT 5 NOT NULL,
    "autoApprove" boolean DEFAULT false NOT NULL,
    "maxDaily" integer DEFAULT 1 NOT NULL,
    "weekDays" text DEFAULT '[1,2,3,4,5]'::text NOT NULL,
    "startDate" timestamp(3) without time zone,
    "endDate" timestamp(3) without time zone,
    status public."TaskStatus" DEFAULT 'ACTIVE'::public."TaskStatus" NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "isTemplate" boolean DEFAULT false NOT NULL,
    "creatorId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.tasks OWNER TO starkids;

--
-- Name: theme_skins; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.theme_skins (
    id text NOT NULL,
    "familyId" text NOT NULL,
    "memberId" text,
    skin public."SkinType" NOT NULL,
    points double precision DEFAULT 0 NOT NULL,
    "isUnlocked" boolean DEFAULT false NOT NULL,
    "isDefault" boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.theme_skins OWNER TO starkids;

--
-- Name: users; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.users (
    id text NOT NULL,
    username text NOT NULL,
    name text,
    "passwordHash" text,
    role public."UserAccountRole" DEFAULT 'PARENT'::public."UserAccountRole" NOT NULL,
    avatar text,
    "isActive" boolean DEFAULT true NOT NULL,
    "lastLoginAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO starkids;

--
-- Name: weekly_stats; Type: TABLE; Schema: public; Owner: starkids
--

CREATE TABLE public.weekly_stats (
    id text NOT NULL,
    "memberId" text NOT NULL,
    "weekStart" timestamp(3) without time zone NOT NULL,
    "weekEnd" timestamp(3) without time zone NOT NULL,
    "tasksCompleted" integer DEFAULT 0 NOT NULL,
    "tasksCompletedRate" double precision DEFAULT 0 NOT NULL,
    "pointsEarned" double precision DEFAULT 0 NOT NULL,
    "pointsSpent" double precision DEFAULT 0 NOT NULL,
    redemptions integer DEFAULT 0 NOT NULL,
    achievements integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.weekly_stats OWNER TO starkids;

--
-- Data for Name: _TaskAssignees; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public."_TaskAssignees" ("A", "B") FROM stdin;
24c282eb-acdd-428e-abb0-4e0aba390e8a	171c5060-2f8d-4d7a-a98d-41f5c62cd026
24c282eb-acdd-428e-abb0-4e0aba390e8a	07abca18-10e4-41da-ba30-9d50257ab1b5
24c282eb-acdd-428e-abb0-4e0aba390e8a	658ec8cf-13bc-48e1-bea7-ffb48bea7bf4
24c282eb-acdd-428e-abb0-4e0aba390e8a	7977059d-b02c-4a1b-a2b8-e1c8f37fa116
24c282eb-acdd-428e-abb0-4e0aba390e8a	b532d10f-5b04-49e5-96b9-6f053e85f32c
24c282eb-acdd-428e-abb0-4e0aba390e8a	17b1c1dd-7e28-4329-a5ca-8b06c1b38642
24c282eb-acdd-428e-abb0-4e0aba390e8a	494b6b2b-43f5-4ac9-b6ac-0b5c8be90ff4
24c282eb-acdd-428e-abb0-4e0aba390e8a	cc0b30db-ea5b-4fae-ac59-00bf21dfee16
24c282eb-acdd-428e-abb0-4e0aba390e8a	5ff36a0f-3c0f-41ed-835e-7350671fa919
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
34b6493d-7cd5-4bb0-b0a7-8f72a4ae6f4a	1d721c30074b9d4995b429af1c1118ef6e9f9b69f9b8747675b6967ca06ae47f	\N	0000_init	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 0000_init\n\nDatabase error code: 42704\n\nDatabase error:\nERROR: type "datetime" does not exist\n\nPosition:\n[1m  0[0m\n[1m  1[0m -- CreateTable\n[1m  2[0m CREATE TABLE "users" (\n[1m  3[0m     "id" TEXT NOT NULL PRIMARY KEY,\n[1m  4[0m     "email" TEXT NOT NULL,\n[1m  5[1;31m     "emailVerified" DATETIME,[0m\n\nDbError { severity: "ERROR", parsed_severity: Some(Error), code: SqlState(E42704), message: "type \\"datetime\\" does not exist", detail: None, hint: None, position: Some(Original(122)), where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("parse_type.c"), line: Some(270), routine: Some("typenameType") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="0000_init"\n             at schema-engine/connectors/sql-schema-connector/src/apply_migration.rs:113\n   1: schema_commands::commands::apply_migrations::Applying migration\n           with migration_name="0000_init"\n             at schema-engine/commands/src/commands/apply_migrations.rs:95\n   2: schema_core::state::ApplyMigrations\n             at schema-engine/core/src/state.rs:255	2026-10-14 10:35:05.059424+00	2026-10-14 10:33:24.10849+00	0
160ddfcf-80c4-4259-8dbb-9c30dd98fcb3	1d721c30074b9d4995b429af1c1118ef6e9f9b69f9b8747675b6967ca06ae47f	2026-10-14 10:35:05.064827+00	0000_init		\N	2026-10-14 10:35:05.064827+00	0
f4bc2ff5-3f5d-4639-aa4c-4865b0594828	68339e5966ce44d8ff8bce944b14cabc91e05af1df549d0eb2756acf62e2a2a8	2026-10-15 09:17:15.764352+00	0001_username_auth	\N	\N	2026-10-15 09:17:15.685398+00	1
b0f28a8e-605b-4c56-a07a-06ec87d1b8e7	3c36dd8b949cc2263cdb9b5de7441b92b7c13c634e1bd4b89ddd34bd4a994c19	2026-10-17 04:00:00.881741+00	0002_support_decimal_points	\N	\N	2026-10-17 04:00:00.674413+00	1
8cefa9ac-e1bb-42dd-a7ec-095573532084	52bbf34fb483bebe15e15db54d0a84d6614ce4944046d2354676191d4a7a3967	2026-10-17 10:27:25.049085+00	0003_pet_care_system	\N	\N	2026-10-17 10:27:24.961108+00	1
b7c410d9-804b-4695-9469-a7b2888e7899	fff59b2a31d6f96712d453d23e860e2826d57898530d9f5c0dbdc4c6040666b1	2026-10-17 10:32:02.557736+00	0004_pet_enum_types	\N	\N	2026-10-17 10:32:02.516974+00	1
349c42b8-69fe-4e3c-8834-6f263731a264	5de40f297e79ad8cdfa969a69a9c70cf6edca8c841701c74d62ea88fe1feebec	2026-10-17 11:00:33.13842+00	0005_pet_interaction_costs	\N	\N	2026-10-17 11:00:33.123007+00	1
\.


--
-- Data for Name: achievement_grants; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.achievement_grants (id, "achievementId", "memberId", "grantedAt", "triggeredBy", context) FROM stdin;
\.


--
-- Data for Name: achievements; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.achievements (id, "familyId", "isGlobal", name, description, icon, category, condition, "bonusPoints", "sortOrder", "isActive", "isHidden", "createdAt") FROM stdin;
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.comments (id, "userId", "memberId", "completionId", content, "isPinned", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: daily_stats; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.daily_stats (id, "memberId", date, "tasksAssigned", "tasksCompleted", "tasksApproved", "pointsEarned", "pointsSpent", redemptions, streak, "createdAt") FROM stdin;
\.


--
-- Data for Name: families; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.families (id, name, avatar, description, timezone, "inviteCode", "isActive", "createdAt", "updatedAt") FROM stdin;
928ef7e1-1641-4fb2-aa24-57da2fdd57e7	侍尹恒一家	\N	\N	Asia/Shanghai	PD3KF4	t	2026-10-14 11:46:09.665	2026-10-14 11:46:09.665
\.


--
-- Data for Name: family_members; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.family_members (id, "familyId", "userId", role, nickname, avatar, age, birthdate, "sortOrder", "createdAt", "updatedAt", "currentPoints") FROM stdin;
5823ade5-7ea0-4c17-95c2-4b9a7adea105	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	f9cd6fc9-8950-4ae5-909e-22e02a99609c	PARENT	爸爸	\N	\N	\N	0	2026-10-14 11:46:09.665	2026-10-15 09:27:00.235	0
49397885-0ba8-4f34-8be7-56cbc0847eae	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	abbd170e-0eef-41b0-b48c-22c0aa5a1db0	PARENT	恒恒妈妈	\N	\N	\N	0	2026-10-17 12:14:59.779	2026-10-17 12:14:59.779	0
24c282eb-acdd-428e-abb0-4e0aba390e8a	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	1ca6b7ea-40eb-4234-9ff8-cd7b60dad7e0	KID	恒恒	\N	\N	\N	0	2026-10-14 11:46:43.952	2026-10-18 13:17:43.131	13.25
\.


--
-- Data for Name: family_settings; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.family_settings (id, "familyId", key, value) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.notifications (id, "userId", "memberId", type, priority, title, content, link, data, "isRead", "readAt", "createdAt") FROM stdin;
cbd5a794-107b-45f9-a67f-6486fcf7cfb2	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"阅读" +1⭐，等待你的审核	/admin/tasks	{"completionId":"06987df6-7691-4d80-b6a2-db1f359e067a","taskId":"171c5060-2f8d-4d7a-a98d-41f5c62cd026","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-15 15:04:58.952
850d92b5-26d4-4fa1-bbc3-fe243ea92d6d	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"吊3分钟单杠" +1⭐，等待你的审核	/admin/tasks	{"completionId":"267a11fb-0e2e-4365-8143-ea302046b0c9","taskId":"7977059d-b02c-4a1b-a2b8-e1c8f37fa116","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-15 15:05:02.387
6beb43f2-acbf-409a-a3ab-54fa7ed0056f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"背一首古诗" +2⭐，等待你的审核	/admin/tasks	{"completionId":"6f51bf6c-3900-4963-935c-030364f383df","taskId":"07abca18-10e4-41da-ba30-9d50257ab1b5","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-15 23:45:21.757
46ca0edd-3e6a-4810-9072-a42c7e47cfa6	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"吊3分钟单杠" +1⭐，等待你的审核	/admin/tasks	{"completionId":"59d10068-ffa3-4b0f-a9c4-f4c4a04e97c2","taskId":"7977059d-b02c-4a1b-a2b8-e1c8f37fa116","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-16 09:49:00.634
d7aba491-ddad-4171-8a38-091f366e1adb	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"跳绳1000个" +1⭐，等待你的审核	/admin/tasks	{"completionId":"7a70749a-4a4b-44eb-9141-f5f2ab5e1647","taskId":"b532d10f-5b04-49e5-96b9-6f053e85f32c","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-16 10:06:28.605
b4cd5800-da45-45e2-9e21-e499a016a984	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"20点前完成1张练字" +1⭐，等待你的审核	/admin/tasks	{"completionId":"18f90cf0-e800-4eb4-8f9f-e4981bffe5ee","taskId":"494b6b2b-43f5-4ac9-b6ac-0b5c8be90ff4","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-16 11:30:44.854
5b64b145-c47b-4563-ac1a-f79b0c9d0376	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"学一课hello english" +1⭐，等待你的审核	/admin/tasks	{"completionId":"23ebb603-02af-40d2-947d-87795f104f83","taskId":"cc0b30db-ea5b-4fae-ac59-00bf21dfee16","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-16 13:15:10.68
34fda871-9111-4e2b-beea-f028e60cb0b9	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"吊3分钟单杠" +1⭐，等待你的审核	/admin/tasks	{"completionId":"c675f361-2bb7-467c-a623-1773f6967078","taskId":"7977059d-b02c-4a1b-a2b8-e1c8f37fa116","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-17 02:04:55.027
fb559c74-b061-47c0-bc9a-20573643e7aa	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"完成1张（2页）数学题" +1⭐，等待你的审核	/admin/tasks	{"completionId":"f73e6aab-3a1e-4d03-832c-6e72843e1628","taskId":"17b1c1dd-7e28-4329-a5ca-8b06c1b38642","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-17 02:43:18.656
55a20639-0354-4c9d-9fc8-b4d52cc03ec9	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"早饭吃一杯牛奶+一个鸡蛋" +0.25⭐，等待你的审核	/admin/tasks	{"completionId":"289d72f3-1351-49fe-953c-676c363174bc","taskId":"5ff36a0f-3c0f-41ed-835e-7350671fa919","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-17 10:00:04.694
d54e66f4-a279-43a4-991a-9c01422973ef	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"跳绳1000个" +1⭐，等待你的审核	/admin/tasks	{"completionId":"9e2a9268-553b-4e56-b263-d25a8ab78709","taskId":"b532d10f-5b04-49e5-96b9-6f053e85f32c","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-17 10:23:45.125
2bd5e0ea-2dca-4926-afcd-32bac6c7f70d	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"学一课hello english" +1⭐，等待你的审核	/admin/tasks	{"completionId":"27c7f4bd-8ade-4c8c-8058-8d2e18d8890f","taskId":"cc0b30db-ea5b-4fae-ac59-00bf21dfee16","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-17 13:55:55.151
c41d7789-cfd3-4df3-b3fa-810586081887	abbd170e-0eef-41b0-b48c-22c0aa5a1db0	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"学一课hello english" +1⭐，等待你的审核	/admin/tasks	{"completionId":"27c7f4bd-8ade-4c8c-8058-8d2e18d8890f","taskId":"cc0b30db-ea5b-4fae-ac59-00bf21dfee16","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-17 13:55:55.157
b413ef51-15ef-4af0-8390-981bd725b1dd	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"吊5分钟单杠" +1⭐，等待你的审核	/admin/tasks	{"completionId":"100cdff8-6e5d-4679-a9ae-2de5320f371c","taskId":"7977059d-b02c-4a1b-a2b8-e1c8f37fa116","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-18 01:53:26.575
44162742-17a3-4079-91ef-e758af964149	abbd170e-0eef-41b0-b48c-22c0aa5a1db0	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"吊5分钟单杠" +1⭐，等待你的审核	/admin/tasks	{"completionId":"100cdff8-6e5d-4679-a9ae-2de5320f371c","taskId":"7977059d-b02c-4a1b-a2b8-e1c8f37fa116","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-18 01:53:26.58
a08a4720-0991-450d-9d23-2d127afd9418	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"完成1张（2页）数学题" +1⭐，等待你的审核	/admin/tasks	{"completionId":"65f2eae3-f939-4551-825e-d8ffff87e844","taskId":"17b1c1dd-7e28-4329-a5ca-8b06c1b38642","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-18 02:23:45.637
36165f00-4a82-49ce-b4a5-333906b31f95	abbd170e-0eef-41b0-b48c-22c0aa5a1db0	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"完成1张（2页）数学题" +1⭐，等待你的审核	/admin/tasks	{"completionId":"65f2eae3-f939-4551-825e-d8ffff87e844","taskId":"17b1c1dd-7e28-4329-a5ca-8b06c1b38642","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-18 02:23:45.642
597728c7-bbfb-4244-b5af-8ce0b9b93e62	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"20点前完成1张练字" +1⭐，等待你的审核	/admin/tasks	{"completionId":"545a97e7-1791-4377-a716-4bba5bf55b05","taskId":"494b6b2b-43f5-4ac9-b6ac-0b5c8be90ff4","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-18 05:36:27.537
d665c464-4360-4a5b-85b5-404e2cb3fe33	abbd170e-0eef-41b0-b48c-22c0aa5a1db0	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"20点前完成1张练字" +1⭐，等待你的审核	/admin/tasks	{"completionId":"545a97e7-1791-4377-a716-4bba5bf55b05","taskId":"494b6b2b-43f5-4ac9-b6ac-0b5c8be90ff4","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-18 05:36:27.541
2d4dd258-e5fe-4db6-8ec4-51a510bc53a7	1ca6b7ea-40eb-4234-9ff8-cd7b60dad7e0	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_APPROVED	HIGH	任务审核通过！🎉	"20点前完成1张练字" 已审核通过，获得 1⭐	/kids/tasks	\N	f	\N	2026-10-18 13:17:43.139
9b855ffb-7458-499f-96ca-766e67794513	f9cd6fc9-8950-4ae5-909e-22e02a99609c	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"跳绳800个" +1⭐，等待你的审核	/admin/tasks	{"completionId":"6ff1e929-9a5e-4bff-b6e9-8124b2a9ff8d","taskId":"b532d10f-5b04-49e5-96b9-6f053e85f32c","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-18 13:27:36.564
08943070-d0f3-4015-af71-9c406e2536ad	abbd170e-0eef-41b0-b48c-22c0aa5a1db0	24c282eb-acdd-428e-abb0-4e0aba390e8a	TASK_COMPLETED	NORMAL	恒恒 完成了任务	"跳绳800个" +1⭐，等待你的审核	/admin/tasks	{"completionId":"6ff1e929-9a5e-4bff-b6e9-8124b2a9ff8d","taskId":"b532d10f-5b04-49e5-96b9-6f053e85f32c","memberId":"24c282eb-acdd-428e-abb0-4e0aba390e8a"}	f	\N	2026-10-18 13:27:36.568
\.


--
-- Data for Name: pet_interactions; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.pet_interactions (id, "petId", "memberId", type, "idempotencyKey", effects, "createdAt") FROM stdin;
45da142c-638e-4628-b284-c74902548367	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	FEED	FEED-1792233254791	{"hunger":30,"mood":5}	2026-10-17 10:34:14.514
2bdfd189-60fc-4229-a0c0-9777dd9776e1	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	DRINK	DRINK-1792233263010	{"thirst":40,"mood":2}	2026-10-17 10:34:22.718
d5e9de80-7c9c-403e-a8d5-b685723613cf	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	BATH	BATH-1792233264535	{"hygiene":35,"mood":8}	2026-10-17 10:34:24.253
3697afb1-54b8-4c8b-b98a-1f619315cc15	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	PLAY	PLAY-1792233265935	{"mood":25,"energy":-15}	2026-10-17 10:34:25.648
ffc7ffb4-8e30-4584-8e20-4a6e5222a62d	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	DRINK	DRINK-1792245431785	{"thirst":40,"mood":2,"pointsCost":0,"balanceAfter":10.25}	2026-10-17 13:57:11.188
115e5e03-813c-47fa-83dc-9979e0dbf5f3	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	PLAY	PLAY-1792245437764	{"mood":25,"energy":-15,"pointsCost":0,"balanceAfter":10.25}	2026-10-17 13:57:17.154
cb8e31ab-27a1-4973-8875-b42dabafdc47	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	DRINK	DRINK-1792282372159	{"thirst":40,"mood":2,"pointsCost":0,"balanceAfter":10.25}	2026-10-18 00:12:51.933
556ef956-9d09-4ee5-aabb-18d5409fb8fc	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	PLAY	PLAY-1792282373185	{"mood":25,"energy":-15,"pointsCost":0,"balanceAfter":10.25}	2026-10-18 00:12:52.961
e2b21a5f-eafa-4baa-9911-7a6a0dd29e92	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	FEED	FEED-1792282374273	{"hunger":30,"mood":5,"pointsCost":0,"balanceAfter":10.25}	2026-10-18 00:12:54.052
496ad258-635d-4a4a-a492-ee15c287e29f	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	BATH	BATH-1792282375285	{"hygiene":35,"mood":8,"pointsCost":0,"balanceAfter":10.25}	2026-10-18 00:12:55.06
4ee5fe52-96a1-4134-a11f-9f8c09747ad6	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	PLAY	PLAY-1792294131533	{"mood":25,"energy":-15,"pointsCost":0,"balanceAfter":10.25}	2026-10-18 03:28:50.613
83ba51bb-3fcc-4e58-b6e7-1751e9d2b2cb	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	DRINK	DRINK-1792295860328	{"thirst":40,"mood":2,"pointsCost":0,"balanceAfter":10.25}	2026-10-18 03:57:40.05
fb1bcc85-7e9e-4426-a5f1-c902f1a3cc23	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	FEED	FEED-1792301446264	{"hunger":30,"mood":5,"pointsCost":0,"balanceAfter":12.25}	2026-10-18 05:30:45.484
9f29a06d-23ce-4ba5-9f98-b02d12176410	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	DRINK	DRINK-1792304297682	{"thirst":40,"mood":2,"pointsCost":0,"balanceAfter":12.25}	2026-10-18 06:18:16.671
a56af99e-92e0-485c-bf2a-75d1a9a1655a	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	PLAY	PLAY-1792305920605	{"mood":25,"energy":-15,"pointsCost":0,"balanceAfter":12.25}	2026-10-18 06:45:20.368
42754df0-dc5a-4ca7-9cad-6076e6f7c077	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	FEED	FEED-1792329424706	{"hunger":30,"mood":5,"pointsCost":0,"balanceAfter":12.25}	2026-10-18 13:17:04.027
7323da23-f29f-441e-b473-d48896e6d666	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	DRINK	DRINK-1792329425375	{"thirst":40,"mood":2,"pointsCost":0,"balanceAfter":12.25}	2026-10-18 13:17:04.686
03f0eade-569e-4f06-8d39-15695024686e	bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	BATH	BATH-1792329426142	{"hygiene":35,"mood":8,"pointsCost":0,"balanceAfter":12.25}	2026-10-18 13:17:05.444
\.


--
-- Data for Name: pet_outfit_grants; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.pet_outfit_grants (id, "outfitId", "memberId", "pointsSpent", "unlockedAt") FROM stdin;
\.


--
-- Data for Name: pet_outfits; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.pet_outfits (id, "familyId", name, description, image, species, points, "isDefault", "sortOrder", "createdAt") FROM stdin;
\.


--
-- Data for Name: pets; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.pets (id, "memberId", species, name, level, stage, mood, "lastFeedDate", "lastMoodUpdate", "currentOutfit", "createdAt", "updatedAt", hunger, thirst, hygiene, energy, status, "deathAt", "deathReason", "criticalSince", "lastSimulatedAt", "lastFedAt", "lastWateredAt", "lastBathedAt", "lastPlayedAt") FROM stdin;
bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	PANDA	小小熊	6	EGG	100	2026-10-18 13:17:04.011	2026-10-18 13:17:05.438	\N	2026-10-14 11:58:56.451	2026-10-18 13:17:05.49	100	100	100	60	ALIVE	\N	\N	\N	2026-10-18 13:17:05.487	2026-10-18 13:17:04.011	2026-10-18 13:17:04.667	2026-10-18 13:17:05.438	2026-10-18 06:45:20.358
\.


--
-- Data for Name: point_configs; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.point_configs (id, "familyId", "weekendDouble", "birthdayTriple", "enableDeduction", "dailyCap", "resetType", "streakBonuses", "createdAt", "updatedAt", "petInteractionCosts") FROM stdin;
52414caf-daee-4052-8466-a46f41539e9e	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	t	t	f	200	NONE	[{"days":3,"points":10},{"days":7,"points":50},{"days":14,"points":100},{"days":30,"points":300}]	2026-10-14 11:46:09.679	2026-10-14 11:46:09.679	{"FEED":0,"DRINK":0,"BATH":0,"PLAY":0}
\.


--
-- Data for Name: point_logs; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.point_logs (id, "memberId", amount, reason, "referenceId", "referenceType", note, "balanceAfter", "createdAt") FROM stdin;
\.


--
-- Data for Name: point_rules; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.point_rules (id, "familyId", "ruleType", name, description, params, "isActive", "sortOrder", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: reward_redemptions; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.reward_redemptions (id, "rewardId", "memberId", "pointsSpent", status, "kidMessage", "parentNote", "approvedBy", "approvedAt", "fulfilledAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: rewards; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.rewards (id, "familyId", name, description, image, category, tags, points, stock, "remainingStock", "maxPerPerson", "cooldownDays", status, "sortOrder", "isFeatured", "createdAt", "updatedAt") FROM stdin;
592a3f2f-8745-4fbe-b65f-7eccfd4e3b46	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	磁力玩具	\N	\N	TOY	[]	29	1	1	0	0	ACTIVE	0	f	2026-10-18 01:48:40.356	2026-10-18 01:48:40.356
\.


--
-- Data for Name: task_completions; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.task_completions (id, "taskId", "memberId", date, "pointsEarned", status, "approvedBy", "approvedAt", "parentNote", "proofImages", "createdAt") FROM stdin;
06987df6-7691-4d80-b6a2-db1f359e067a	171c5060-2f8d-4d7a-a98d-41f5c62cd026	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-15 00:00:00	1	APPROVED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-15 15:05:19.492	完成得很好！继续保持！🌟	[]	2026-10-15 15:04:58.935
267a11fb-0e2e-4365-8143-ea302046b0c9	7977059d-b02c-4a1b-a2b8-e1c8f37fa116	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-15 00:00:00	1	APPROVED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-15 15:05:21.58	完成得很好！继续保持！🌟	[]	2026-10-15 15:05:02.38
59d10068-ffa3-4b0f-a9c4-f4c4a04e97c2	7977059d-b02c-4a1b-a2b8-e1c8f37fa116	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-16 00:00:00	1	APPROVED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-16 11:32:09.671	完成得很好！继续保持！🌟	[]	2026-10-16 09:49:00.624
18f90cf0-e800-4eb4-8f9f-e4981bffe5ee	494b6b2b-43f5-4ac9-b6ac-0b5c8be90ff4	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-16 00:00:00	1	APPROVED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-16 11:32:12.491	完成得很好！继续保持！🌟	[]	2026-10-16 11:30:44.844
7a70749a-4a4b-44eb-9141-f5f2ab5e1647	b532d10f-5b04-49e5-96b9-6f053e85f32c	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-16 00:00:00	1	APPROVED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-16 11:32:16.453	完成得很好！继续保持！🌟	[]	2026-10-16 10:06:28.591
6f51bf6c-3900-4963-935c-030364f383df	07abca18-10e4-41da-ba30-9d50257ab1b5	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-15 00:00:00	2	REJECTED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-16 11:32:23.47	需要再努力一点哦～	[]	2026-10-15 23:45:21.736
23ebb603-02af-40d2-947d-87795f104f83	cc0b30db-ea5b-4fae-ac59-00bf21dfee16	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-16 00:00:00	1	APPROVED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-16 13:16:33.816	完成得很好！继续保持！🌟	[]	2026-10-16 13:15:10.668
c675f361-2bb7-467c-a623-1773f6967078	7977059d-b02c-4a1b-a2b8-e1c8f37fa116	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-17 00:00:00	1	APPROVED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-17 09:46:37.725	完成得很好！继续保持！🌟	[]	2026-10-17 02:04:55.016
f73e6aab-3a1e-4d03-832c-6e72843e1628	17b1c1dd-7e28-4329-a5ca-8b06c1b38642	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-17 00:00:00	1	APPROVED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-17 09:46:39.08	完成得很好！继续保持！🌟	[]	2026-10-17 02:43:18.643
289d72f3-1351-49fe-953c-676c363174bc	5ff36a0f-3c0f-41ed-835e-7350671fa919	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-17 00:00:00	0.25	APPROVED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-17 10:50:49.815	完成得很好！继续保持！🌟	[]	2026-10-17 10:00:04.682
9e2a9268-553b-4e56-b263-d25a8ab78709	b532d10f-5b04-49e5-96b9-6f053e85f32c	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-17 00:00:00	1	APPROVED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-17 10:50:51.024	完成得很好！继续保持！🌟	[]	2026-10-17 10:23:45.11
27c7f4bd-8ade-4c8c-8058-8d2e18d8890f	cc0b30db-ea5b-4fae-ac59-00bf21dfee16	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-17 00:00:00	1	APPROVED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-17 13:56:37.779	完成得很好！继续保持！🌟	[]	2026-10-17 13:55:55.138
65f2eae3-f939-4551-825e-d8ffff87e844	17b1c1dd-7e28-4329-a5ca-8b06c1b38642	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-18 00:00:00	1	APPROVED	abbd170e-0eef-41b0-b48c-22c0aa5a1db0	2026-10-18 03:59:34.583	完成得很好！继续保持！🌟	[]	2026-10-18 02:23:45.627
100cdff8-6e5d-4679-a9ae-2de5320f371c	7977059d-b02c-4a1b-a2b8-e1c8f37fa116	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-18 00:00:00	1	APPROVED	abbd170e-0eef-41b0-b48c-22c0aa5a1db0	2026-10-18 03:59:35.801	完成得很好！继续保持！🌟	[]	2026-10-18 01:53:26.565
545a97e7-1791-4377-a716-4bba5bf55b05	494b6b2b-43f5-4ac9-b6ac-0b5c8be90ff4	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-18 00:00:00	1	APPROVED	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-18 13:17:43.117	完成得很好！继续保持！🌟	[]	2026-10-18 05:36:27.528
6ff1e929-9a5e-4bff-b6e9-8124b2a9ff8d	b532d10f-5b04-49e5-96b9-6f053e85f32c	24c282eb-acdd-428e-abb0-4e0aba390e8a	2026-10-18 00:00:00	1	PENDING	\N	\N	\N	[]	2026-10-18 13:27:36.553
\.


--
-- Data for Name: task_templates; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.task_templates (id, "familyId", "isGlobal", name, description, icon, category, type, frequency, difficulty, points, "autoApprove", "maxDaily", "weekDays", tags, "sortOrder", "createdAt") FROM stdin;
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.tasks (id, "familyId", name, description, icon, image, category, type, frequency, difficulty, points, "autoApprove", "maxDaily", "weekDays", "startDate", "endDate", status, "sortOrder", "isTemplate", "creatorId", "createdAt", "updatedAt") FROM stdin;
171c5060-2f8d-4d7a-a98d-41f5c62cd026	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	阅读	每天至少阅读半小时	📚	\N	HABIT	DAILY	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-14 12:09:37.091	2026-10-14 13:16:09.346
658ec8cf-13bc-48e1-bea7-ffb48bea7bf4	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	晚饭前完成作业	有兴趣课除外	✏️	\N	STUDY	DAILY	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-14 12:13:24.956	2026-10-14 13:16:17.973
07abca18-10e4-41da-ba30-9d50257ab1b5	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	背一首古诗	每天背一首古诗	🥦	\N	STUDY	CHALLENGE	DAILY	MEDIUM	2	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-14 12:11:35.846	2026-10-15 00:35:58.57
17b1c1dd-7e28-4329-a5ca-8b06c1b38642	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	完成1张（2页）数学题	最多错两题	✏️	\N	STUDY	CHALLENGE	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-15 11:47:33.147	2026-10-15 11:47:33.147
494b6b2b-43f5-4ac9-b6ac-0b5c8be90ff4	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	20点前完成1张练字	\N	✏️	\N	STUDY	CHALLENGE	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-15 11:50:17.034	2026-10-15 11:50:17.034
cc0b30db-ea5b-4fae-ac59-00bf21dfee16	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	学一课hello english	\N	👀	\N	STUDY	CHALLENGE	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-16 12:41:19.028	2026-10-16 12:41:19.028
7977059d-b02c-4a1b-a2b8-e1c8f37fa116	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	吊5分钟单杠	争取每天吊5分钟单杠，累计时长。	🏃	\N	EXERCISE	CHALLENGE	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-14 12:14:44.713	2026-10-17 09:47:04.539
5ff36a0f-3c0f-41ed-835e-7350671fa919	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	早饭吃一杯牛奶+一个鸡蛋	再吃点其他碳水	🥦	\N	HABIT	DAILY	DAILY	EASY	0.25	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-17 09:48:58.632	2026-10-17 09:48:58.632
b532d10f-5b04-49e5-96b9-6f053e85f32c	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	跳绳800个	\N	🏃	\N	EXERCISE	CHALLENGE	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-14 14:04:45.226	2026-10-18 13:18:51.747
\.


--
-- Data for Name: theme_skins; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.theme_skins (id, "familyId", "memberId", skin, points, "isUnlocked", "isDefault", "isActive", "createdAt") FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.users (id, username, name, "passwordHash", role, avatar, "isActive", "lastLoginAt", "createdAt", "updatedAt") FROM stdin;
1ca6b7ea-40eb-4234-9ff8-cd7b60dad7e0	syh	恒恒	$2b$12$aFgwz7WdGuZK4aZOL4hM4eYbNWloObzpYbByjGiXREwef7vhbxeqi	KID	\N	t	2026-10-15 15:04:16.156	2026-10-14 11:46:43.944	2026-10-15 15:04:16.156
f9cd6fc9-8950-4ae5-909e-22e02a99609c	srx	爸爸	$2b$12$S6o3BIFUAAXPO2Jak.Nne.ANQdFNDwZ87FnuKzjOLZJ4wKwtNh.ni	PARENT	\N	t	2026-10-16 11:31:54.789	2026-10-14 11:45:40.452	2026-10-16 11:31:54.79
abbd170e-0eef-41b0-b48c-22c0aa5a1db0	恒恒妈妈	恒恒妈妈	$2b$12$t7S186gQSrym7AHLngHFwO0WrHrG.leVmH5qTrngUALUHBIMXBIQm	PARENT	\N	t	2026-10-17 12:14:16.88	2026-10-17 12:14:16.392	2026-10-17 12:14:16.881
\.


--
-- Data for Name: weekly_stats; Type: TABLE DATA; Schema: public; Owner: starkids
--

COPY public.weekly_stats (id, "memberId", "weekStart", "weekEnd", "tasksCompleted", "tasksCompletedRate", "pointsEarned", "pointsSpent", redemptions, achievements, "createdAt") FROM stdin;
\.


--
-- Name: _TaskAssignees _TaskAssignees_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public."_TaskAssignees"
    ADD CONSTRAINT "_TaskAssignees_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: achievement_grants achievement_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.achievement_grants
    ADD CONSTRAINT achievement_grants_pkey PRIMARY KEY (id);


--
-- Name: achievements achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: daily_stats daily_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.daily_stats
    ADD CONSTRAINT daily_stats_pkey PRIMARY KEY (id);


--
-- Name: families families_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.families
    ADD CONSTRAINT families_pkey PRIMARY KEY (id);


--
-- Name: family_members family_members_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.family_members
    ADD CONSTRAINT family_members_pkey PRIMARY KEY (id);


--
-- Name: family_settings family_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.family_settings
    ADD CONSTRAINT family_settings_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: pet_interactions pet_interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.pet_interactions
    ADD CONSTRAINT pet_interactions_pkey PRIMARY KEY (id);


--
-- Name: pet_outfit_grants pet_outfit_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.pet_outfit_grants
    ADD CONSTRAINT pet_outfit_grants_pkey PRIMARY KEY (id);


--
-- Name: pet_outfits pet_outfits_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.pet_outfits
    ADD CONSTRAINT pet_outfits_pkey PRIMARY KEY (id);


--
-- Name: pets pets_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.pets
    ADD CONSTRAINT pets_pkey PRIMARY KEY (id);


--
-- Name: point_configs point_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.point_configs
    ADD CONSTRAINT point_configs_pkey PRIMARY KEY (id);


--
-- Name: point_logs point_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.point_logs
    ADD CONSTRAINT point_logs_pkey PRIMARY KEY (id);


--
-- Name: point_rules point_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.point_rules
    ADD CONSTRAINT point_rules_pkey PRIMARY KEY (id);


--
-- Name: reward_redemptions reward_redemptions_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.reward_redemptions
    ADD CONSTRAINT reward_redemptions_pkey PRIMARY KEY (id);


--
-- Name: rewards rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: task_completions task_completions_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.task_completions
    ADD CONSTRAINT task_completions_pkey PRIMARY KEY (id);


--
-- Name: task_templates task_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.task_templates
    ADD CONSTRAINT task_templates_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: theme_skins theme_skins_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.theme_skins
    ADD CONSTRAINT theme_skins_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: weekly_stats weekly_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.weekly_stats
    ADD CONSTRAINT weekly_stats_pkey PRIMARY KEY (id);


--
-- Name: _TaskAssignees_B_index; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "_TaskAssignees_B_index" ON public."_TaskAssignees" USING btree ("B");


--
-- Name: achievement_grants_achievementId_memberId_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX "achievement_grants_achievementId_memberId_key" ON public.achievement_grants USING btree ("achievementId", "memberId");


--
-- Name: achievement_grants_memberId_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "achievement_grants_memberId_idx" ON public.achievement_grants USING btree ("memberId");


--
-- Name: achievements_category_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX achievements_category_idx ON public.achievements USING btree (category);


--
-- Name: achievements_familyId_isGlobal_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "achievements_familyId_isGlobal_idx" ON public.achievements USING btree ("familyId", "isGlobal");


--
-- Name: comments_memberId_createdAt_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "comments_memberId_createdAt_idx" ON public.comments USING btree ("memberId", "createdAt");


--
-- Name: daily_stats_memberId_date_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "daily_stats_memberId_date_idx" ON public.daily_stats USING btree ("memberId", date);


--
-- Name: daily_stats_memberId_date_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX "daily_stats_memberId_date_key" ON public.daily_stats USING btree ("memberId", date);


--
-- Name: families_inviteCode_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX "families_inviteCode_key" ON public.families USING btree ("inviteCode");


--
-- Name: family_members_familyId_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "family_members_familyId_idx" ON public.family_members USING btree ("familyId");


--
-- Name: family_members_familyId_userId_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX "family_members_familyId_userId_key" ON public.family_members USING btree ("familyId", "userId");


--
-- Name: family_members_userId_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "family_members_userId_idx" ON public.family_members USING btree ("userId");


--
-- Name: family_settings_familyId_key_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX "family_settings_familyId_key_key" ON public.family_settings USING btree ("familyId", key);


--
-- Name: notifications_createdAt_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "notifications_createdAt_idx" ON public.notifications USING btree ("createdAt");


--
-- Name: notifications_memberId_isRead_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "notifications_memberId_isRead_idx" ON public.notifications USING btree ("memberId", "isRead");


--
-- Name: notifications_userId_isRead_createdAt_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "notifications_userId_isRead_createdAt_idx" ON public.notifications USING btree ("userId", "isRead", "createdAt");


--
-- Name: pet_interactions_memberId_createdAt_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "pet_interactions_memberId_createdAt_idx" ON public.pet_interactions USING btree ("memberId", "createdAt");


--
-- Name: pet_interactions_petId_createdAt_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "pet_interactions_petId_createdAt_idx" ON public.pet_interactions USING btree ("petId", "createdAt");


--
-- Name: pet_interactions_petId_idempotencyKey_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX "pet_interactions_petId_idempotencyKey_key" ON public.pet_interactions USING btree ("petId", "idempotencyKey");


--
-- Name: pet_outfit_grants_outfitId_memberId_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX "pet_outfit_grants_outfitId_memberId_key" ON public.pet_outfit_grants USING btree ("outfitId", "memberId");


--
-- Name: pets_memberId_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX "pets_memberId_key" ON public.pets USING btree ("memberId");


--
-- Name: point_configs_familyId_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX "point_configs_familyId_key" ON public.point_configs USING btree ("familyId");


--
-- Name: point_logs_createdAt_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "point_logs_createdAt_idx" ON public.point_logs USING btree ("createdAt");


--
-- Name: point_logs_memberId_createdAt_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "point_logs_memberId_createdAt_idx" ON public.point_logs USING btree ("memberId", "createdAt");


--
-- Name: point_logs_memberId_reason_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "point_logs_memberId_reason_idx" ON public.point_logs USING btree ("memberId", reason);


--
-- Name: point_rules_familyId_isActive_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "point_rules_familyId_isActive_idx" ON public.point_rules USING btree ("familyId", "isActive");


--
-- Name: reward_redemptions_createdAt_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "reward_redemptions_createdAt_idx" ON public.reward_redemptions USING btree ("createdAt");


--
-- Name: reward_redemptions_memberId_status_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "reward_redemptions_memberId_status_idx" ON public.reward_redemptions USING btree ("memberId", status);


--
-- Name: reward_redemptions_rewardId_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "reward_redemptions_rewardId_idx" ON public.reward_redemptions USING btree ("rewardId");


--
-- Name: rewards_familyId_category_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "rewards_familyId_category_idx" ON public.rewards USING btree ("familyId", category);


--
-- Name: rewards_familyId_status_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "rewards_familyId_status_idx" ON public.rewards USING btree ("familyId", status);


--
-- Name: task_completions_date_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX task_completions_date_idx ON public.task_completions USING btree (date);


--
-- Name: task_completions_memberId_status_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "task_completions_memberId_status_idx" ON public.task_completions USING btree ("memberId", status);


--
-- Name: task_completions_taskId_date_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "task_completions_taskId_date_idx" ON public.task_completions USING btree ("taskId", date);


--
-- Name: task_completions_taskId_memberId_date_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX "task_completions_taskId_memberId_date_key" ON public.task_completions USING btree ("taskId", "memberId", date);


--
-- Name: task_templates_isGlobal_category_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "task_templates_isGlobal_category_idx" ON public.task_templates USING btree ("isGlobal", category);


--
-- Name: tasks_familyId_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "tasks_familyId_idx" ON public.tasks USING btree ("familyId");


--
-- Name: tasks_familyId_status_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "tasks_familyId_status_idx" ON public.tasks USING btree ("familyId", status);


--
-- Name: tasks_status_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX tasks_status_idx ON public.tasks USING btree (status);


--
-- Name: theme_skins_familyId_memberId_skin_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX "theme_skins_familyId_memberId_skin_key" ON public.theme_skins USING btree ("familyId", "memberId", skin);


--
-- Name: users_username_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX users_username_key ON public.users USING btree (username);


--
-- Name: weekly_stats_memberId_weekStart_idx; Type: INDEX; Schema: public; Owner: starkids
--

CREATE INDEX "weekly_stats_memberId_weekStart_idx" ON public.weekly_stats USING btree ("memberId", "weekStart");


--
-- Name: weekly_stats_memberId_weekStart_key; Type: INDEX; Schema: public; Owner: starkids
--

CREATE UNIQUE INDEX "weekly_stats_memberId_weekStart_key" ON public.weekly_stats USING btree ("memberId", "weekStart");


--
-- Name: _TaskAssignees _TaskAssignees_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public."_TaskAssignees"
    ADD CONSTRAINT "_TaskAssignees_A_fkey" FOREIGN KEY ("A") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _TaskAssignees _TaskAssignees_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public."_TaskAssignees"
    ADD CONSTRAINT "_TaskAssignees_B_fkey" FOREIGN KEY ("B") REFERENCES public.tasks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: achievement_grants achievement_grants_achievementId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.achievement_grants
    ADD CONSTRAINT "achievement_grants_achievementId_fkey" FOREIGN KEY ("achievementId") REFERENCES public.achievements(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: achievement_grants achievement_grants_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.achievement_grants
    ADD CONSTRAINT "achievement_grants_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: achievements achievements_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT "achievements_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: comments comments_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: comments comments_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: daily_stats daily_stats_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.daily_stats
    ADD CONSTRAINT "daily_stats_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: family_members family_members_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.family_members
    ADD CONSTRAINT "family_members_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: family_members family_members_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.family_members
    ADD CONSTRAINT "family_members_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: family_settings family_settings_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.family_settings
    ADD CONSTRAINT "family_settings_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notifications notifications_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: notifications notifications_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pet_interactions pet_interactions_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.pet_interactions
    ADD CONSTRAINT "pet_interactions_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pet_interactions pet_interactions_petId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.pet_interactions
    ADD CONSTRAINT "pet_interactions_petId_fkey" FOREIGN KEY ("petId") REFERENCES public.pets(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pet_outfit_grants pet_outfit_grants_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.pet_outfit_grants
    ADD CONSTRAINT "pet_outfit_grants_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pet_outfit_grants pet_outfit_grants_outfitId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.pet_outfit_grants
    ADD CONSTRAINT "pet_outfit_grants_outfitId_fkey" FOREIGN KEY ("outfitId") REFERENCES public.pet_outfits(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pet_outfits pet_outfits_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.pet_outfits
    ADD CONSTRAINT "pet_outfits_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: pets pets_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.pets
    ADD CONSTRAINT "pets_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: point_configs point_configs_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.point_configs
    ADD CONSTRAINT "point_configs_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: point_logs point_logs_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.point_logs
    ADD CONSTRAINT "point_logs_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: point_rules point_rules_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.point_rules
    ADD CONSTRAINT "point_rules_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reward_redemptions reward_redemptions_approvedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.reward_redemptions
    ADD CONSTRAINT "reward_redemptions_approvedBy_fkey" FOREIGN KEY ("approvedBy") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: reward_redemptions reward_redemptions_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.reward_redemptions
    ADD CONSTRAINT "reward_redemptions_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reward_redemptions reward_redemptions_rewardId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.reward_redemptions
    ADD CONSTRAINT "reward_redemptions_rewardId_fkey" FOREIGN KEY ("rewardId") REFERENCES public.rewards(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rewards rewards_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.rewards
    ADD CONSTRAINT "rewards_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: task_completions task_completions_approvedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.task_completions
    ADD CONSTRAINT "task_completions_approvedBy_fkey" FOREIGN KEY ("approvedBy") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: task_completions task_completions_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.task_completions
    ADD CONSTRAINT "task_completions_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: task_completions task_completions_taskId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.task_completions
    ADD CONSTRAINT "task_completions_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES public.tasks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: task_templates task_templates_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.task_templates
    ADD CONSTRAINT "task_templates_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tasks tasks_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "tasks_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: theme_skins theme_skins_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.theme_skins
    ADD CONSTRAINT "theme_skins_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: theme_skins theme_skins_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.theme_skins
    ADD CONSTRAINT "theme_skins_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: weekly_stats weekly_stats_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: starkids
--

ALTER TABLE ONLY public.weekly_stats
    ADD CONSTRAINT "weekly_stats_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict Ta1Ook1lnpaaKoyrcwHrnCdzOGd4K89jHwiYny9eb3DyxLmYlZCzcvQXOMPdhHH


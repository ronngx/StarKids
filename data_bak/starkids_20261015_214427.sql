--
-- PostgreSQL database dump
--

\restrict Sx2j4hSfVnFmq0s9qbDiq6tolFvKcT7z86rlqAbnb7q4dNngfn0cFsHuFPUgQ7b

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
-- Name: AchievementCategory; Type: TYPE; Schema: public; Owner: -
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


--
-- Name: CompletionStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."CompletionStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED'
);


--
-- Name: MemberRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."MemberRole" AS ENUM (
    'PARENT',
    'KID'
);


--
-- Name: NotificationPriority; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."NotificationPriority" AS ENUM (
    'LOW',
    'NORMAL',
    'HIGH'
);


--
-- Name: NotificationType; Type: TYPE; Schema: public; Owner: -
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


--
-- Name: PetSpecies; Type: TYPE; Schema: public; Owner: -
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


--
-- Name: PetStage; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."PetStage" AS ENUM (
    'EGG',
    'BABY',
    'GROWING',
    'EVOLVED',
    'ULTIMATE'
);


--
-- Name: PointReason; Type: TYPE; Schema: public; Owner: -
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


--
-- Name: RedemptionStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."RedemptionStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'FULFILLED'
);


--
-- Name: RewardCategory; Type: TYPE; Schema: public; Owner: -
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


--
-- Name: RewardStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."RewardStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'SOLD_OUT'
);


--
-- Name: SkinType; Type: TYPE; Schema: public; Owner: -
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


--
-- Name: TaskCategory; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."TaskCategory" AS ENUM (
    'HOUSEWORK',
    'STUDY',
    'EXERCISE',
    'HABIT',
    'SOCIAL',
    'OTHER'
);


--
-- Name: TaskDifficulty; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."TaskDifficulty" AS ENUM (
    'EASY',
    'MEDIUM',
    'HARD'
);


--
-- Name: TaskFrequency; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."TaskFrequency" AS ENUM (
    'DAILY',
    'WEEKLY',
    'MANUAL'
);


--
-- Name: TaskStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."TaskStatus" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'ARCHIVED'
);


--
-- Name: TaskType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."TaskType" AS ENUM (
    'DAILY',
    'ONETIME',
    'CHALLENGE',
    'HABIT'
);


--
-- Name: TriggerConditionType; Type: TYPE; Schema: public; Owner: -
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


--
-- Name: UserAccountRole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."UserAccountRole" AS ENUM (
    'ADMIN',
    'PARENT',
    'KID'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _TaskAssignees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."_TaskAssignees" (
    "A" text NOT NULL,
    "B" text NOT NULL
);


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: achievement_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.achievement_grants (
    id text NOT NULL,
    "achievementId" text NOT NULL,
    "memberId" text NOT NULL,
    "grantedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "triggeredBy" text,
    context text
);


--
-- Name: achievements; Type: TABLE; Schema: public; Owner: -
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
    "bonusPoints" integer DEFAULT 0 NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "isHidden" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: daily_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.daily_stats (
    id text NOT NULL,
    "memberId" text NOT NULL,
    date timestamp(3) without time zone NOT NULL,
    "tasksAssigned" integer DEFAULT 0 NOT NULL,
    "tasksCompleted" integer DEFAULT 0 NOT NULL,
    "tasksApproved" integer DEFAULT 0 NOT NULL,
    "pointsEarned" integer DEFAULT 0 NOT NULL,
    "pointsSpent" integer DEFAULT 0 NOT NULL,
    redemptions integer DEFAULT 0 NOT NULL,
    streak integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: families; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: family_members; Type: TABLE; Schema: public; Owner: -
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
    "currentPoints" integer DEFAULT 0 NOT NULL
);


--
-- Name: family_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.family_settings (
    id text NOT NULL,
    "familyId" text NOT NULL,
    key text NOT NULL,
    value text NOT NULL
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: pet_outfit_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pet_outfit_grants (
    id text NOT NULL,
    "outfitId" text NOT NULL,
    "memberId" text NOT NULL,
    "pointsSpent" integer DEFAULT 0 NOT NULL,
    "unlockedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: pet_outfits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pet_outfits (
    id text NOT NULL,
    "familyId" text,
    name text NOT NULL,
    description text,
    image text,
    species public."PetSpecies",
    points integer DEFAULT 0 NOT NULL,
    "isDefault" boolean DEFAULT false NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: pets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pets (
    id text NOT NULL,
    "memberId" text NOT NULL,
    species public."PetSpecies" NOT NULL,
    name text DEFAULT '小宝贝'::text NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    stage public."PetStage" DEFAULT 'EGG'::public."PetStage" NOT NULL,
    mood integer DEFAULT 100 NOT NULL,
    "lastFeedDate" timestamp(3) without time zone,
    "lastMoodUpdate" timestamp(3) without time zone,
    "currentOutfit" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: point_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.point_configs (
    id text NOT NULL,
    "familyId" text NOT NULL,
    "weekendDouble" boolean DEFAULT false NOT NULL,
    "birthdayTriple" boolean DEFAULT false NOT NULL,
    "enableDeduction" boolean DEFAULT false NOT NULL,
    "dailyCap" integer DEFAULT 0 NOT NULL,
    "resetType" text DEFAULT 'NONE'::text NOT NULL,
    "streakBonuses" text DEFAULT '[{"days":3,"points":10},{"days":7,"points":50},{"days":14,"points":100},{"days":30,"points":300}]'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


--
-- Name: point_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.point_logs (
    id text NOT NULL,
    "memberId" text NOT NULL,
    amount integer NOT NULL,
    reason public."PointReason" NOT NULL,
    "referenceId" text,
    "referenceType" text,
    note text,
    "balanceAfter" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: point_rules; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: reward_redemptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reward_redemptions (
    id text NOT NULL,
    "rewardId" text NOT NULL,
    "memberId" text NOT NULL,
    "pointsSpent" integer NOT NULL,
    status public."RedemptionStatus" DEFAULT 'PENDING'::public."RedemptionStatus" NOT NULL,
    "kidMessage" text,
    "parentNote" text,
    "approvedBy" text,
    "approvedAt" timestamp(3) without time zone,
    "fulfilledAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: rewards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rewards (
    id text NOT NULL,
    "familyId" text NOT NULL,
    name text NOT NULL,
    description text,
    image text,
    category public."RewardCategory" NOT NULL,
    tags text DEFAULT '[]'::text NOT NULL,
    points integer NOT NULL,
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


--
-- Name: task_completions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_completions (
    id text NOT NULL,
    "taskId" text NOT NULL,
    "memberId" text NOT NULL,
    date timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "pointsEarned" integer DEFAULT 0 NOT NULL,
    status public."CompletionStatus" DEFAULT 'PENDING'::public."CompletionStatus" NOT NULL,
    "approvedBy" text,
    "approvedAt" timestamp(3) without time zone,
    "parentNote" text,
    "proofImages" text DEFAULT '[]'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: task_templates; Type: TABLE; Schema: public; Owner: -
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
    points integer DEFAULT 10 NOT NULL,
    "autoApprove" boolean DEFAULT false NOT NULL,
    "maxDaily" integer DEFAULT 1 NOT NULL,
    "weekDays" text DEFAULT '[1,2,3,4,5]'::text NOT NULL,
    tags text DEFAULT '[]'::text NOT NULL,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -
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
    points integer DEFAULT 5 NOT NULL,
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


--
-- Name: theme_skins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.theme_skins (
    id text NOT NULL,
    "familyId" text NOT NULL,
    "memberId" text,
    skin public."SkinType" NOT NULL,
    points integer DEFAULT 0 NOT NULL,
    "isUnlocked" boolean DEFAULT false NOT NULL,
    "isDefault" boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: weekly_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weekly_stats (
    id text NOT NULL,
    "memberId" text NOT NULL,
    "weekStart" timestamp(3) without time zone NOT NULL,
    "weekEnd" timestamp(3) without time zone NOT NULL,
    "tasksCompleted" integer DEFAULT 0 NOT NULL,
    "tasksCompletedRate" double precision DEFAULT 0 NOT NULL,
    "pointsEarned" integer DEFAULT 0 NOT NULL,
    "pointsSpent" integer DEFAULT 0 NOT NULL,
    redemptions integer DEFAULT 0 NOT NULL,
    achievements integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Data for Name: _TaskAssignees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."_TaskAssignees" ("A", "B") FROM stdin;
24c282eb-acdd-428e-abb0-4e0aba390e8a	171c5060-2f8d-4d7a-a98d-41f5c62cd026
24c282eb-acdd-428e-abb0-4e0aba390e8a	07abca18-10e4-41da-ba30-9d50257ab1b5
24c282eb-acdd-428e-abb0-4e0aba390e8a	658ec8cf-13bc-48e1-bea7-ffb48bea7bf4
24c282eb-acdd-428e-abb0-4e0aba390e8a	7977059d-b02c-4a1b-a2b8-e1c8f37fa116
24c282eb-acdd-428e-abb0-4e0aba390e8a	b532d10f-5b04-49e5-96b9-6f053e85f32c
24c282eb-acdd-428e-abb0-4e0aba390e8a	17b1c1dd-7e28-4329-a5ca-8b06c1b38642
24c282eb-acdd-428e-abb0-4e0aba390e8a	494b6b2b-43f5-4ac9-b6ac-0b5c8be90ff4
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
34b6493d-7cd5-4bb0-b0a7-8f72a4ae6f4a	1d721c30074b9d4995b429af1c1118ef6e9f9b69f9b8747675b6967ca06ae47f	\N	0000_init	A migration failed to apply. New migrations cannot be applied before the error is recovered from. Read more about how to resolve migration issues in a production database: https://pris.ly/d/migrate-resolve\n\nMigration name: 0000_init\n\nDatabase error code: 42704\n\nDatabase error:\nERROR: type "datetime" does not exist\n\nPosition:\n[1m  0[0m\n[1m  1[0m -- CreateTable\n[1m  2[0m CREATE TABLE "users" (\n[1m  3[0m     "id" TEXT NOT NULL PRIMARY KEY,\n[1m  4[0m     "email" TEXT NOT NULL,\n[1m  5[1;31m     "emailVerified" DATETIME,[0m\n\nDbError { severity: "ERROR", parsed_severity: Some(Error), code: SqlState(E42704), message: "type \\"datetime\\" does not exist", detail: None, hint: None, position: Some(Original(122)), where_: None, schema: None, table: None, column: None, datatype: None, constraint: None, file: Some("parse_type.c"), line: Some(270), routine: Some("typenameType") }\n\n   0: sql_schema_connector::apply_migration::apply_script\n           with migration_name="0000_init"\n             at schema-engine/connectors/sql-schema-connector/src/apply_migration.rs:113\n   1: schema_commands::commands::apply_migrations::Applying migration\n           with migration_name="0000_init"\n             at schema-engine/commands/src/commands/apply_migrations.rs:95\n   2: schema_core::state::ApplyMigrations\n             at schema-engine/core/src/state.rs:255	2026-10-14 10:35:05.059424+00	2026-10-14 10:33:24.10849+00	0
160ddfcf-80c4-4259-8dbb-9c30dd98fcb3	1d721c30074b9d4995b429af1c1118ef6e9f9b69f9b8747675b6967ca06ae47f	2026-10-14 10:35:05.064827+00	0000_init		\N	2026-10-14 10:35:05.064827+00	0
f4bc2ff5-3f5d-4639-aa4c-4865b0594828	68339e5966ce44d8ff8bce944b14cabc91e05af1df549d0eb2756acf62e2a2a8	2026-10-15 09:17:15.764352+00	0001_username_auth	\N	\N	2026-10-15 09:17:15.685398+00	1
\.


--
-- Data for Name: achievement_grants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.achievement_grants (id, "achievementId", "memberId", "grantedAt", "triggeredBy", context) FROM stdin;
\.


--
-- Data for Name: achievements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.achievements (id, "familyId", "isGlobal", name, description, icon, category, condition, "bonusPoints", "sortOrder", "isActive", "isHidden", "createdAt") FROM stdin;
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comments (id, "userId", "memberId", "completionId", content, "isPinned", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: daily_stats; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.daily_stats (id, "memberId", date, "tasksAssigned", "tasksCompleted", "tasksApproved", "pointsEarned", "pointsSpent", redemptions, streak, "createdAt") FROM stdin;
\.


--
-- Data for Name: families; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.families (id, name, avatar, description, timezone, "inviteCode", "isActive", "createdAt", "updatedAt") FROM stdin;
928ef7e1-1641-4fb2-aa24-57da2fdd57e7	侍尹恒一家	\N	\N	Asia/Shanghai	PD3KF4	t	2026-10-14 11:46:09.665	2026-10-14 11:46:09.665
\.


--
-- Data for Name: family_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.family_members (id, "familyId", "userId", role, nickname, avatar, age, birthdate, "sortOrder", "createdAt", "updatedAt", "currentPoints") FROM stdin;
24c282eb-acdd-428e-abb0-4e0aba390e8a	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	1ca6b7ea-40eb-4234-9ff8-cd7b60dad7e0	KID	恒恒	\N	\N	\N	0	2026-10-14 11:46:43.952	2026-10-14 14:02:48.471	0
5823ade5-7ea0-4c17-95c2-4b9a7adea105	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	f9cd6fc9-8950-4ae5-909e-22e02a99609c	PARENT	爸爸	\N	\N	\N	0	2026-10-14 11:46:09.665	2026-10-15 09:27:00.235	0
\.


--
-- Data for Name: family_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.family_settings (id, "familyId", key, value) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, "userId", "memberId", type, priority, title, content, link, data, "isRead", "readAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: pet_outfit_grants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pet_outfit_grants (id, "outfitId", "memberId", "pointsSpent", "unlockedAt") FROM stdin;
\.


--
-- Data for Name: pet_outfits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pet_outfits (id, "familyId", name, description, image, species, points, "isDefault", "sortOrder", "createdAt") FROM stdin;
\.


--
-- Data for Name: pets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pets (id, "memberId", species, name, level, stage, mood, "lastFeedDate", "lastMoodUpdate", "currentOutfit", "createdAt", "updatedAt") FROM stdin;
bd3c6351-8c56-4622-8648-555ac4d246a4	24c282eb-acdd-428e-abb0-4e0aba390e8a	PANDA	小小熊	0	EGG	100	2026-10-14 11:59:07.85	2026-10-14 11:59:07.85	\N	2026-10-14 11:58:56.451	2026-10-14 11:59:07.852
\.


--
-- Data for Name: point_configs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.point_configs (id, "familyId", "weekendDouble", "birthdayTriple", "enableDeduction", "dailyCap", "resetType", "streakBonuses", "createdAt", "updatedAt") FROM stdin;
52414caf-daee-4052-8466-a46f41539e9e	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	t	t	f	200	NONE	[{"days":3,"points":10},{"days":7,"points":50},{"days":14,"points":100},{"days":30,"points":300}]	2026-10-14 11:46:09.679	2026-10-14 11:46:09.679
\.


--
-- Data for Name: point_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.point_logs (id, "memberId", amount, reason, "referenceId", "referenceType", note, "balanceAfter", "createdAt") FROM stdin;
\.


--
-- Data for Name: point_rules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.point_rules (id, "familyId", "ruleType", name, description, params, "isActive", "sortOrder", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: reward_redemptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reward_redemptions (id, "rewardId", "memberId", "pointsSpent", status, "kidMessage", "parentNote", "approvedBy", "approvedAt", "fulfilledAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: rewards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rewards (id, "familyId", name, description, image, category, tags, points, stock, "remainingStock", "maxPerPerson", "cooldownDays", status, "sortOrder", "isFeatured", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: task_completions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_completions (id, "taskId", "memberId", date, "pointsEarned", status, "approvedBy", "approvedAt", "parentNote", "proofImages", "createdAt") FROM stdin;
\.


--
-- Data for Name: task_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_templates (id, "familyId", "isGlobal", name, description, icon, category, type, frequency, difficulty, points, "autoApprove", "maxDaily", "weekDays", tags, "sortOrder", "createdAt") FROM stdin;
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tasks (id, "familyId", name, description, icon, image, category, type, frequency, difficulty, points, "autoApprove", "maxDaily", "weekDays", "startDate", "endDate", status, "sortOrder", "isTemplate", "creatorId", "createdAt", "updatedAt") FROM stdin;
171c5060-2f8d-4d7a-a98d-41f5c62cd026	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	阅读	每天至少阅读半小时	📚	\N	HABIT	DAILY	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-14 12:09:37.091	2026-10-14 13:16:09.346
658ec8cf-13bc-48e1-bea7-ffb48bea7bf4	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	晚饭前完成作业	有兴趣课除外	✏️	\N	STUDY	DAILY	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-14 12:13:24.956	2026-10-14 13:16:17.973
7977059d-b02c-4a1b-a2b8-e1c8f37fa116	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	吊3分钟单杠	争取每天吊3分钟单杠，累计时长。	🏃	\N	EXERCISE	CHALLENGE	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-14 12:14:44.713	2026-10-14 14:03:35.89
07abca18-10e4-41da-ba30-9d50257ab1b5	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	背一首古诗	每天背一首古诗	🥦	\N	STUDY	CHALLENGE	DAILY	MEDIUM	2	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-14 12:11:35.846	2026-10-15 00:35:58.57
17b1c1dd-7e28-4329-a5ca-8b06c1b38642	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	完成1张（2页）数学题	最多错两题	✏️	\N	STUDY	CHALLENGE	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-15 11:47:33.147	2026-10-15 11:47:33.147
494b6b2b-43f5-4ac9-b6ac-0b5c8be90ff4	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	20点前完成1张练字	\N	✏️	\N	STUDY	CHALLENGE	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-15 11:50:17.034	2026-10-15 11:50:17.034
b532d10f-5b04-49e5-96b9-6f053e85f32c	928ef7e1-1641-4fb2-aa24-57da2fdd57e7	跳绳1000个	\N	🏃	\N	EXERCISE	CHALLENGE	DAILY	EASY	1	f	1	[1,2,3,4,5,6,0]	\N	\N	ACTIVE	0	f	f9cd6fc9-8950-4ae5-909e-22e02a99609c	2026-10-14 14:04:45.226	2026-10-15 11:51:25.066
\.


--
-- Data for Name: theme_skins; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.theme_skins (id, "familyId", "memberId", skin, points, "isUnlocked", "isDefault", "isActive", "createdAt") FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, username, name, "passwordHash", role, avatar, "isActive", "lastLoginAt", "createdAt", "updatedAt") FROM stdin;
1ca6b7ea-40eb-4234-9ff8-cd7b60dad7e0	syh	恒恒	$2b$12$aFgwz7WdGuZK4aZOL4hM4eYbNWloObzpYbByjGiXREwef7vhbxeqi	KID	\N	t	2026-10-14 13:38:11.277	2026-10-14 11:46:43.944	2026-10-14 13:38:11.277
f9cd6fc9-8950-4ae5-909e-22e02a99609c	srx	爸爸	$2b$12$S6o3BIFUAAXPO2Jak.Nne.ANQdFNDwZ87FnuKzjOLZJ4wKwtNh.ni	PARENT	\N	t	2026-10-14 12:01:02.87	2026-10-14 11:45:40.452	2026-10-15 09:27:00.229
\.


--
-- Data for Name: weekly_stats; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.weekly_stats (id, "memberId", "weekStart", "weekEnd", "tasksCompleted", "tasksCompletedRate", "pointsEarned", "pointsSpent", redemptions, achievements, "createdAt") FROM stdin;
\.


--
-- Name: _TaskAssignees _TaskAssignees_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_TaskAssignees"
    ADD CONSTRAINT "_TaskAssignees_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: achievement_grants achievement_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievement_grants
    ADD CONSTRAINT achievement_grants_pkey PRIMARY KEY (id);


--
-- Name: achievements achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: daily_stats daily_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_stats
    ADD CONSTRAINT daily_stats_pkey PRIMARY KEY (id);


--
-- Name: families families_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.families
    ADD CONSTRAINT families_pkey PRIMARY KEY (id);


--
-- Name: family_members family_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.family_members
    ADD CONSTRAINT family_members_pkey PRIMARY KEY (id);


--
-- Name: family_settings family_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.family_settings
    ADD CONSTRAINT family_settings_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: pet_outfit_grants pet_outfit_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pet_outfit_grants
    ADD CONSTRAINT pet_outfit_grants_pkey PRIMARY KEY (id);


--
-- Name: pet_outfits pet_outfits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pet_outfits
    ADD CONSTRAINT pet_outfits_pkey PRIMARY KEY (id);


--
-- Name: pets pets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pets
    ADD CONSTRAINT pets_pkey PRIMARY KEY (id);


--
-- Name: point_configs point_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.point_configs
    ADD CONSTRAINT point_configs_pkey PRIMARY KEY (id);


--
-- Name: point_logs point_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.point_logs
    ADD CONSTRAINT point_logs_pkey PRIMARY KEY (id);


--
-- Name: point_rules point_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.point_rules
    ADD CONSTRAINT point_rules_pkey PRIMARY KEY (id);


--
-- Name: reward_redemptions reward_redemptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reward_redemptions
    ADD CONSTRAINT reward_redemptions_pkey PRIMARY KEY (id);


--
-- Name: rewards rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rewards
    ADD CONSTRAINT rewards_pkey PRIMARY KEY (id);


--
-- Name: task_completions task_completions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_completions
    ADD CONSTRAINT task_completions_pkey PRIMARY KEY (id);


--
-- Name: task_templates task_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_templates
    ADD CONSTRAINT task_templates_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: theme_skins theme_skins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theme_skins
    ADD CONSTRAINT theme_skins_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: weekly_stats weekly_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weekly_stats
    ADD CONSTRAINT weekly_stats_pkey PRIMARY KEY (id);


--
-- Name: _TaskAssignees_B_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "_TaskAssignees_B_index" ON public."_TaskAssignees" USING btree ("B");


--
-- Name: achievement_grants_achievementId_memberId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "achievement_grants_achievementId_memberId_key" ON public.achievement_grants USING btree ("achievementId", "memberId");


--
-- Name: achievement_grants_memberId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "achievement_grants_memberId_idx" ON public.achievement_grants USING btree ("memberId");


--
-- Name: achievements_category_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX achievements_category_idx ON public.achievements USING btree (category);


--
-- Name: achievements_familyId_isGlobal_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "achievements_familyId_isGlobal_idx" ON public.achievements USING btree ("familyId", "isGlobal");


--
-- Name: comments_memberId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "comments_memberId_createdAt_idx" ON public.comments USING btree ("memberId", "createdAt");


--
-- Name: daily_stats_memberId_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "daily_stats_memberId_date_idx" ON public.daily_stats USING btree ("memberId", date);


--
-- Name: daily_stats_memberId_date_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "daily_stats_memberId_date_key" ON public.daily_stats USING btree ("memberId", date);


--
-- Name: families_inviteCode_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "families_inviteCode_key" ON public.families USING btree ("inviteCode");


--
-- Name: family_members_familyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "family_members_familyId_idx" ON public.family_members USING btree ("familyId");


--
-- Name: family_members_familyId_userId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "family_members_familyId_userId_key" ON public.family_members USING btree ("familyId", "userId");


--
-- Name: family_members_userId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "family_members_userId_idx" ON public.family_members USING btree ("userId");


--
-- Name: family_settings_familyId_key_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "family_settings_familyId_key_key" ON public.family_settings USING btree ("familyId", key);


--
-- Name: notifications_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "notifications_createdAt_idx" ON public.notifications USING btree ("createdAt");


--
-- Name: notifications_memberId_isRead_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "notifications_memberId_isRead_idx" ON public.notifications USING btree ("memberId", "isRead");


--
-- Name: notifications_userId_isRead_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "notifications_userId_isRead_createdAt_idx" ON public.notifications USING btree ("userId", "isRead", "createdAt");


--
-- Name: pet_outfit_grants_outfitId_memberId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "pet_outfit_grants_outfitId_memberId_key" ON public.pet_outfit_grants USING btree ("outfitId", "memberId");


--
-- Name: pets_memberId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "pets_memberId_key" ON public.pets USING btree ("memberId");


--
-- Name: point_configs_familyId_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "point_configs_familyId_key" ON public.point_configs USING btree ("familyId");


--
-- Name: point_logs_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "point_logs_createdAt_idx" ON public.point_logs USING btree ("createdAt");


--
-- Name: point_logs_memberId_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "point_logs_memberId_createdAt_idx" ON public.point_logs USING btree ("memberId", "createdAt");


--
-- Name: point_logs_memberId_reason_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "point_logs_memberId_reason_idx" ON public.point_logs USING btree ("memberId", reason);


--
-- Name: point_rules_familyId_isActive_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "point_rules_familyId_isActive_idx" ON public.point_rules USING btree ("familyId", "isActive");


--
-- Name: reward_redemptions_createdAt_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "reward_redemptions_createdAt_idx" ON public.reward_redemptions USING btree ("createdAt");


--
-- Name: reward_redemptions_memberId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "reward_redemptions_memberId_status_idx" ON public.reward_redemptions USING btree ("memberId", status);


--
-- Name: reward_redemptions_rewardId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "reward_redemptions_rewardId_idx" ON public.reward_redemptions USING btree ("rewardId");


--
-- Name: rewards_familyId_category_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "rewards_familyId_category_idx" ON public.rewards USING btree ("familyId", category);


--
-- Name: rewards_familyId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "rewards_familyId_status_idx" ON public.rewards USING btree ("familyId", status);


--
-- Name: task_completions_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX task_completions_date_idx ON public.task_completions USING btree (date);


--
-- Name: task_completions_memberId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "task_completions_memberId_status_idx" ON public.task_completions USING btree ("memberId", status);


--
-- Name: task_completions_taskId_date_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "task_completions_taskId_date_idx" ON public.task_completions USING btree ("taskId", date);


--
-- Name: task_completions_taskId_memberId_date_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "task_completions_taskId_memberId_date_key" ON public.task_completions USING btree ("taskId", "memberId", date);


--
-- Name: task_templates_isGlobal_category_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "task_templates_isGlobal_category_idx" ON public.task_templates USING btree ("isGlobal", category);


--
-- Name: tasks_familyId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "tasks_familyId_idx" ON public.tasks USING btree ("familyId");


--
-- Name: tasks_familyId_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "tasks_familyId_status_idx" ON public.tasks USING btree ("familyId", status);


--
-- Name: tasks_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tasks_status_idx ON public.tasks USING btree (status);


--
-- Name: theme_skins_familyId_memberId_skin_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "theme_skins_familyId_memberId_skin_key" ON public.theme_skins USING btree ("familyId", "memberId", skin);


--
-- Name: users_username_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_username_key ON public.users USING btree (username);


--
-- Name: weekly_stats_memberId_weekStart_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "weekly_stats_memberId_weekStart_idx" ON public.weekly_stats USING btree ("memberId", "weekStart");


--
-- Name: weekly_stats_memberId_weekStart_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "weekly_stats_memberId_weekStart_key" ON public.weekly_stats USING btree ("memberId", "weekStart");


--
-- Name: _TaskAssignees _TaskAssignees_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_TaskAssignees"
    ADD CONSTRAINT "_TaskAssignees_A_fkey" FOREIGN KEY ("A") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _TaskAssignees _TaskAssignees_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."_TaskAssignees"
    ADD CONSTRAINT "_TaskAssignees_B_fkey" FOREIGN KEY ("B") REFERENCES public.tasks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: achievement_grants achievement_grants_achievementId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievement_grants
    ADD CONSTRAINT "achievement_grants_achievementId_fkey" FOREIGN KEY ("achievementId") REFERENCES public.achievements(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: achievement_grants achievement_grants_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievement_grants
    ADD CONSTRAINT "achievement_grants_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: achievements achievements_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT "achievements_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: comments comments_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: comments comments_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "comments_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: daily_stats daily_stats_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.daily_stats
    ADD CONSTRAINT "daily_stats_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: family_members family_members_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.family_members
    ADD CONSTRAINT "family_members_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: family_members family_members_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.family_members
    ADD CONSTRAINT "family_members_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: family_settings family_settings_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.family_settings
    ADD CONSTRAINT "family_settings_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notifications notifications_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: notifications notifications_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pet_outfit_grants pet_outfit_grants_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pet_outfit_grants
    ADD CONSTRAINT "pet_outfit_grants_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pet_outfit_grants pet_outfit_grants_outfitId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pet_outfit_grants
    ADD CONSTRAINT "pet_outfit_grants_outfitId_fkey" FOREIGN KEY ("outfitId") REFERENCES public.pet_outfits(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pet_outfits pet_outfits_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pet_outfits
    ADD CONSTRAINT "pet_outfits_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: pets pets_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pets
    ADD CONSTRAINT "pets_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: point_configs point_configs_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.point_configs
    ADD CONSTRAINT "point_configs_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: point_logs point_logs_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.point_logs
    ADD CONSTRAINT "point_logs_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: point_rules point_rules_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.point_rules
    ADD CONSTRAINT "point_rules_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reward_redemptions reward_redemptions_approvedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reward_redemptions
    ADD CONSTRAINT "reward_redemptions_approvedBy_fkey" FOREIGN KEY ("approvedBy") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: reward_redemptions reward_redemptions_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reward_redemptions
    ADD CONSTRAINT "reward_redemptions_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reward_redemptions reward_redemptions_rewardId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reward_redemptions
    ADD CONSTRAINT "reward_redemptions_rewardId_fkey" FOREIGN KEY ("rewardId") REFERENCES public.rewards(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rewards rewards_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rewards
    ADD CONSTRAINT "rewards_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: task_completions task_completions_approvedBy_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_completions
    ADD CONSTRAINT "task_completions_approvedBy_fkey" FOREIGN KEY ("approvedBy") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: task_completions task_completions_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_completions
    ADD CONSTRAINT "task_completions_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: task_completions task_completions_taskId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_completions
    ADD CONSTRAINT "task_completions_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES public.tasks(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: task_templates task_templates_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_templates
    ADD CONSTRAINT "task_templates_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tasks tasks_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT "tasks_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: theme_skins theme_skins_familyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theme_skins
    ADD CONSTRAINT "theme_skins_familyId_fkey" FOREIGN KEY ("familyId") REFERENCES public.families(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: theme_skins theme_skins_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theme_skins
    ADD CONSTRAINT "theme_skins_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: weekly_stats weekly_stats_memberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weekly_stats
    ADD CONSTRAINT "weekly_stats_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES public.family_members(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict Sx2j4hSfVnFmq0s9qbDiq6tolFvKcT7z86rlqAbnb7q4dNngfn0cFsHuFPUgQ7b


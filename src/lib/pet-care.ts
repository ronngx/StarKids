import type { PetInteractionType, PetStatus } from "@prisma/client"

/**
 * Pet care is deliberately kept as a pure, server-side domain module. The page
 * may show a countdown, but only these rules are allowed to change a pet.
 */

export const PET_CARE_WARNING_LEVEL = 25
export const PET_DEATH_GRACE_HOURS = 24

export const PET_INTERACTION_CONFIG: Record<
  PetInteractionType,
  {
    label: string
    emoji: string
    cooldownMs: number
    effects: Partial<Record<"hunger" | "thirst" | "hygiene" | "energy" | "mood", number>>
    timestampField: "lastFedAt" | "lastWateredAt" | "lastBathedAt" | "lastPlayedAt" | null
  }
> = {
  FEED: {
    label: "喂食",
    emoji: "🍎",
    cooldownMs: 4 * 60 * 60 * 1000,
    effects: { hunger: 30, mood: 5 },
    timestampField: "lastFedAt",
  },
  DRINK: {
    label: "喝水",
    emoji: "💧",
    cooldownMs: 2 * 60 * 60 * 1000,
    effects: { thirst: 40, mood: 2 },
    timestampField: "lastWateredAt",
  },
  BATH: {
    label: "洗澡",
    emoji: "🛁",
    cooldownMs: 8 * 60 * 60 * 1000,
    effects: { hygiene: 35, mood: 8 },
    timestampField: "lastBathedAt",
  },
  PLAY: {
    label: "玩耍",
    emoji: "🎾",
    cooldownMs: 3 * 60 * 60 * 1000,
    effects: { mood: 25, energy: -15 },
    timestampField: "lastPlayedAt",
  },
  REST: {
    label: "休息",
    emoji: "😴",
    cooldownMs: 0,
    effects: { energy: 25, mood: 2 },
    timestampField: null,
  },
  REVIVE: {
    label: "恢复",
    emoji: "✨",
    cooldownMs: 0,
    effects: { hunger: 50, thirst: 50, hygiene: 50, energy: 50, mood: 50 },
    timestampField: null,
  },
}

const DECAY_PER_HOUR = {
  hunger: 0.6,
  thirst: 1,
  hygiene: 0.45,
  mood: 0.2,
}

const ENERGY_RECOVERY_PER_HOUR = 1.25
const CORE_NEEDS = ["hunger", "thirst", "hygiene"] as const

export type PetCareState = {
  hunger: number
  thirst: number
  hygiene: number
  energy: number
  mood: number
  status: PetStatus | string
  deathAt: Date | string | null
  deathReason: string | null
  criticalSince: Date | string | null
  lastSimulatedAt: Date | string | null
}

export type PetCareResult = PetCareState & {
  changed: boolean
  justDied: boolean
}

function asDate(value: Date | string | null | undefined, fallback: Date) {
  if (!value) return fallback
  const date = value instanceof Date ? value : new Date(value)
  return Number.isNaN(date.getTime()) ? fallback : date
}

function clamp(value: number) {
  return Math.max(0, Math.min(100, Math.round(value)))
}

function minCoreNeed(state: Pick<PetCareState, "hunger" | "thirst" | "hygiene">) {
  return Math.min(state.hunger, state.thirst, state.hygiene)
}

/** Advance needs from the last persisted point in time. */
export function advancePetState<T extends PetCareState>(pet: T, now = new Date()): PetCareResult {
  const last = asDate(pet.lastSimulatedAt, now)
  const elapsedHours = Math.max(0, Math.min(24 * 30, (now.getTime() - last.getTime()) / 3600000))

  if (pet.status === "DEAD") {
    return { ...pet, lastSimulatedAt: now, changed: last.getTime() !== now.getTime(), justDied: false }
  }

  const next = {
    hunger: clamp(pet.hunger - elapsedHours * DECAY_PER_HOUR.hunger),
    thirst: clamp(pet.thirst - elapsedHours * DECAY_PER_HOUR.thirst),
    hygiene: clamp(pet.hygiene - elapsedHours * DECAY_PER_HOUR.hygiene),
    energy: clamp(pet.energy + elapsedHours * ENERGY_RECOVERY_PER_HOUR),
    mood: clamp(pet.mood - elapsedHours * DECAY_PER_HOUR.mood),
  }

  let criticalSince = pet.criticalSince ? asDate(pet.criticalSince, now) : null
  if (minCoreNeed(next) <= 0) {
    if (!criticalSince) {
      const crossingHours = Math.min(
        pet.hunger / DECAY_PER_HOUR.hunger,
        pet.thirst / DECAY_PER_HOUR.thirst,
        pet.hygiene / DECAY_PER_HOUR.hygiene
      )
      criticalSince = new Date(last.getTime() + Math.max(0, crossingHours) * 3600000)
    }
  } else {
    criticalSince = null
  }

  const shouldDie = Boolean(criticalSince && now.getTime() - criticalSince.getTime() >= PET_DEATH_GRACE_HOURS * 3600000)
  const nextStatus = shouldDie
    ? "DEAD"
    : minCoreNeed(next) <= PET_CARE_WARNING_LEVEL || next.mood <= PET_CARE_WARNING_LEVEL
      ? "CRITICAL"
      : "ALIVE"

  const justDied = shouldDie && pet.status !== "DEAD"
  return {
    ...pet,
    ...next,
    status: nextStatus,
    criticalSince,
    deathAt: justDied ? now : pet.deathAt,
    deathReason: justDied ? getDeathReason(next) : pet.deathReason,
    lastSimulatedAt: now,
    changed:
      elapsedHours > 0 || nextStatus !== pet.status || Boolean(criticalSince) !== Boolean(pet.criticalSince),
    justDied,
  }
}

function getDeathReason(state: Pick<PetCareState, "hunger" | "thirst" | "hygiene">) {
  const reasons = [
    [state.thirst, "太久没有喝水"],
    [state.hunger, "太久没有吃东西"],
    [state.hygiene, "太久没有洗澡"],
  ] as const
  return [...reasons].sort((a, b) => a[0] - b[0])[0][1]
}

export function applyInteraction<T extends PetCareState>(
  pet: T,
  type: PetInteractionType,
  now = new Date()
): PetCareResult {
  const config = PET_INTERACTION_CONFIG[type]
  if (!config) throw new Error("不支持的宠物互动")

  const advanced = advancePetState(pet, now)
  const next = { ...advanced }
  for (const [key, amount] of Object.entries(config.effects)) {
    const field = key as keyof typeof config.effects
    const value = next[field as keyof typeof next]
    if (typeof value === "number") {
      ;(next as Record<string, unknown>)[field] = clamp(value + (amount || 0))
    }
  }

  if (type === "REVIVE") {
    next.status = "ALIVE"
    next.deathAt = null
    next.deathReason = null
    next.criticalSince = null
  } else if (next.status !== "DEAD") {
    next.status = minCoreNeed(next) <= PET_CARE_WARNING_LEVEL || next.mood <= PET_CARE_WARNING_LEVEL ? "CRITICAL" : "ALIVE"
  }

  return { ...next, lastSimulatedAt: now, changed: true, justDied: advanced.justDied }
}

export function getRemainingCooldown(
  lastAt: Date | string | null | undefined,
  type: PetInteractionType,
  now = new Date()
) {
  const config = PET_INTERACTION_CONFIG[type]
  if (!config || !lastAt || config.cooldownMs <= 0) return 0
  return Math.max(0, config.cooldownMs - (now.getTime() - asDate(lastAt, now).getTime()))
}

export function getPetCareWarning(pet: Pick<PetCareState, "hunger" | "thirst" | "hygiene" | "energy" | "mood" | "status">) {
  if (pet.status === "DEAD") return "宠物已经睡着了，需要家长帮忙恢复。"
  if (pet.thirst <= PET_CARE_WARNING_LEVEL) return "我好渴呀，给我喝点水吧！"
  if (pet.hunger <= PET_CARE_WARNING_LEVEL) return "我的肚子咕咕叫，想吃东西啦！"
  if (pet.hygiene <= PET_CARE_WARNING_LEVEL) return "我身上有点脏，想洗个澡啦！"
  if (pet.energy <= PET_CARE_WARNING_LEVEL) return "我有点累了，先休息一下吧。"
  if (pet.mood <= PET_CARE_WARNING_LEVEL) return "陪我玩一会儿，我会开心起来的！"
  return "照顾得很好，继续保持吧！"
}

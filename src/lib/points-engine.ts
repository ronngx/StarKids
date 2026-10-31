import { prisma } from "@/lib/db"
import { formatPoints, normalizePoints } from "@/lib/points"

type PointRuleParams = {
  days?: number
  bonus?: number
  multiplier?: number
  cap?: number
}

type BonusResult = {
  basePoints: number
  bonusPoints: number
  totalPoints: number
  breakdown: string[]
}

export async function calculatePoints(
  taskPoints: number,
  memberId: string,
  familyId: string,
  now = new Date(),
): Promise<BonusResult> {
  taskPoints = normalizePoints(taskPoints)
  const breakdown: string[] = [`基础积分: +${formatPoints(taskPoints)}⭐`]
  let bonusPoints = 0

  const [rules, member, config, family] = await Promise.all([
    prisma.pointRule.findMany({
      where: { familyId, isActive: true },
    }),
    prisma.familyMember.findUnique({
      where: { id: memberId },
      select: { birthdate: true },
    }),
    prisma.pointConfig.findFirst({
      where: { familyId },
    }),
    prisma.family.findUnique({
      where: { id: familyId },
      select: { timezone: true },
    }),
  ])

  // Older families can have weekendDouble enabled without a corresponding
  // PointRule row. The setting itself must still activate the bonus. When a
  // rule exists, its multiplier remains authoritative and this fallback is
  // skipped to avoid awarding the bonus twice.
  const hasWeekendRule = rules.some((rule) => rule.ruleType === "WEEKEND_DOUBLE")
  if (!hasWeekendRule && isWeekend(now, family?.timezone) && config?.weekendDouble) {
    const bonus = taskPoints
    bonusPoints = normalizePoints(bonusPoints + bonus)
    breakdown.push(`周末双倍积分: +${formatPoints(bonus)}⭐`)
  }

  for (const rule of rules) {
    const params = JSON.parse(rule.params) as PointRuleParams

    switch (rule.ruleType) {
      case "STREAK_BONUS": {
        const streakDays = await getStreakDays(memberId)
        if (params.days && streakDays >= params.days) {
          const bonus = normalizePoints(params.bonus || 0)
          bonusPoints += bonus
          breakdown.push(`${rule.name}: +${formatPoints(bonus)}⭐`)
        }
        break
      }

      case "WEEKEND_DOUBLE": {
        if (isWeekend(now, family?.timezone) && config?.weekendDouble) {
          const bonus = normalizePoints(taskPoints * ((params.multiplier || 2) - 1))
          bonusPoints = normalizePoints(bonusPoints + bonus)
          breakdown.push(`${rule.name}: +${formatPoints(bonus)}⭐`)
        }
        break
      }

      case "BIRTHDAY_TRIPLE": {
        if (member?.birthdate && isBirthday(member.birthdate) && config?.birthdayTriple) {
          const bonus = normalizePoints(taskPoints * ((params.multiplier || 3) - 1))
          bonusPoints = normalizePoints(bonusPoints + bonus)
          breakdown.push(`🎂 ${rule.name}: +${formatPoints(bonus)}⭐`)
        }
        break
      }

      case "DAILY_CAP": {
        const todayPoints = await getTodayPoints(memberId)
        const maxPoints = normalizePoints(params.cap || 0)
        const earnedBeforeCap = normalizePoints(todayPoints + taskPoints + bonusPoints)
        if (maxPoints > 0 && earnedBeforeCap > maxPoints) {
          const maxBonus = Math.max(0, normalizePoints(maxPoints - todayPoints - taskPoints))
          bonusPoints = normalizePoints(Math.min(bonusPoints, maxBonus))
          breakdown.push(`⚠️ 已达到每日积分上限`)
        }
        break
      }
    }
  }

  return {
    basePoints: taskPoints,
    bonusPoints: normalizePoints(bonusPoints),
    totalPoints: normalizePoints(taskPoints + bonusPoints),
    breakdown,
  }
}

async function getStreakDays(memberId: string): Promise<number> {
  const completions = await prisma.taskCompletion.findMany({
    where: {
      memberId,
      status: "APPROVED",
    },
    select: { date: true },
    orderBy: { date: "desc" },
    distinct: ["date"],
  })

  if (completions.length === 0) return 0

  let streak = 0
  const today = new Date()
  today.setHours(0, 0, 0, 0)

  for (let i = 0; i < completions.length; i++) {
    const expectedDate = new Date(today)
    expectedDate.setDate(expectedDate.getDate() - i)
    const compDate = new Date(completions[i].date)
    compDate.setHours(0, 0, 0, 0)

    if (compDate.getTime() === expectedDate.getTime()) {
      streak++
    } else if (i === 0) {
      const yesterday = new Date(today)
      yesterday.setDate(yesterday.getDate() - 1)
      if (compDate.getTime() !== yesterday.getTime()) break
      streak++
    } else {
      break
    }
  }

  return streak
}

async function getTodayPoints(memberId: string): Promise<number> {
  const today = new Date()
  today.setHours(0, 0, 0, 0)

  const completions = await prisma.taskCompletion.aggregate({
    where: {
      memberId,
      status: "APPROVED",
      date: { gte: today },
    },
    _sum: { pointsEarned: true },
  })

  return normalizePoints(completions._sum.pointsEarned)
}

function isWeekend(date: Date, timezone?: string | null): boolean {
  try {
    const weekday = new Intl.DateTimeFormat("en-US", {
      timeZone: timezone || "Asia/Shanghai",
      weekday: "short",
    }).format(date)
    return weekday === "Sat" || weekday === "Sun"
  } catch {
    // An invalid legacy timezone should not disable the bonus entirely.
    const day = date.getDay()
    return day === 0 || day === 6
  }
}

function isBirthday(birthday: Date | null): boolean {
  if (!birthday) return false
  const today = new Date()
  return (
    today.getMonth() === birthday.getMonth() &&
    today.getDate() === birthday.getDate()
  )
}

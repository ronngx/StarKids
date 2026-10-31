"use client"

import { useCallback, useEffect, useMemo, useState } from "react"
import { PageTransition } from "@/components/ui/PageTransition"
import { ListSkeleton } from "@/components/ui/Skeleton"
import { cn } from "@/lib/utils"
import { formatPoints } from "@/lib/points"

type PointDirection = "EARN" | "SPEND"
type PointStatus = "COMPLETED" | "PENDING" | "APPROVED" | "FULFILLED"
type PointFilter = "ALL" | PointDirection

type PointDetail = {
  id: string
  createdAt: string
  direction: PointDirection
  amount: number
  title: string
  icon: string
  status: PointStatus
}

type PointsData = {
  balance: number
  summary: { earned: number; spent: number }
  items: PointDetail[]
}

const STATUS_LABELS: Record<PointStatus, string> = {
  COMPLETED: "已完成",
  PENDING: "处理中",
  APPROVED: "已通过",
  FULFILLED: "已兑现",
}

function dateKey(date: string) {
  const value = new Date(date)
  return `${value.getFullYear()}-${value.getMonth()}-${value.getDate()}`
}

function formatDate(date: string) {
  return new Date(date).toLocaleDateString("zh-CN", {
    month: "long",
    day: "numeric",
    weekday: "short",
  })
}

function formatTime(date: string) {
  return new Date(date).toLocaleTimeString("zh-CN", {
    hour: "2-digit",
    minute: "2-digit",
  })
}

export default function KidsPointsPage() {
  const [data, setData] = useState<PointsData | null>(null)
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState<PointFilter>("ALL")
  const [error, setError] = useState("")

  const fetchData = useCallback(async () => {
    try {
      const response = await fetch("/api/kids/points")
      if (!response.ok) {
        setError(response.status === 404 ? "你还没有加入家庭，请先让家长邀请你加入家庭" : "积分明细加载失败，请稍后再试")
        return
      }
      setData(await response.json())
      setError("")
    } catch {
      setError("网络错误，请稍后再试")
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchData()
  }, [fetchData])

  const filteredItems = useMemo(
    () => data?.items.filter((item) => filter === "ALL" || item.direction === filter) || [],
    [data, filter],
  )

  const groupedItems = useMemo(() => {
    const groups: Array<{ key: string; label: string; items: PointDetail[] }> = []
    for (const item of filteredItems) {
      const key = dateKey(item.createdAt)
      const group = groups.find((candidate) => candidate.key === key)
      if (group) {
        group.items.push(item)
      } else {
        groups.push({ key, label: formatDate(item.createdAt), items: [item] })
      }
    }
    return groups
  }, [filteredItems])

  if (loading) {
    return (
      <PageTransition className="p-5 space-y-5">
        <h1 className="font-kids text-3xl text-candy-purple pt-4">🧾 积分明细</h1>
        <div className="bg-white rounded-card shadow-soft p-5 space-y-3">
          <div className="h-4 w-24 bg-warm-200 animate-pulse rounded" />
          <div className="h-12 w-40 bg-warm-200 animate-pulse rounded" />
        </div>
        <ListSkeleton count={5} />
      </PageTransition>
    )
  }

  if (!data || error) {
    return (
      <PageTransition className="p-5 space-y-5">
        <h1 className="font-kids text-3xl text-candy-purple pt-4">🧾 积分明细</h1>
        <div className="bg-white rounded-card shadow-soft p-8 text-center text-warm-400">
          <p className="text-4xl mb-3">⭐</p>
          <p>{error || "积分明细暂时无法加载"}</p>
        </div>
      </PageTransition>
    )
  }

  return (
    <PageTransition className="p-5 space-y-5">
      <div className="pt-4">
        <h1 className="font-kids text-3xl text-candy-purple">🧾 积分明细</h1>
        <p className="text-sm text-warm-400 mt-1">每一颗星星都记录着你的努力哦！</p>
      </div>

      <div className="bg-white rounded-card shadow-soft p-5 space-y-4">
        <div className="text-center">
          <p className="text-sm text-warm-400">💫 当前积分</p>
          <p className="font-kids text-5xl text-brand-500">{formatPoints(data.balance)} ⭐</p>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <div className="bg-green-50 rounded-xl p-3 text-center">
            <p className="text-xs text-candy-green">累计获取</p>
            <p className="font-kids text-2xl text-candy-green mt-1">+{formatPoints(data.summary.earned)}⭐</p>
          </div>
          <div className="bg-orange-50 rounded-xl p-3 text-center">
            <p className="text-xs text-candy-orange">累计消费</p>
            <p className="font-kids text-2xl text-candy-orange mt-1">-{formatPoints(data.summary.spent)}⭐</p>
          </div>
        </div>
      </div>

      <div className="flex gap-2 overflow-x-auto pb-1">
        {([
          ["ALL", "全部"],
          ["EARN", "获取"],
          ["SPEND", "消费"],
        ] as const).map(([value, label]) => (
          <button
            key={value}
            type="button"
            onClick={() => setFilter(value)}
            className={cn(
              "px-4 py-2 rounded-xl text-sm font-semibold whitespace-nowrap transition-colors",
              filter === value
                ? "bg-candy-blue text-white"
                : "bg-white text-warm-500 shadow-soft hover:bg-blue-50",
            )}
          >
            {label}
          </button>
        ))}
      </div>

      {groupedItems.length === 0 ? (
        <div className="bg-white rounded-card shadow-soft text-center py-12 text-warm-400">
          <p className="text-5xl mb-3">🌟</p>
          <p>{filter === "SPEND" ? "还没有消费积分哦～" : filter === "EARN" ? "完成任务就能获得积分啦！" : "还没有积分明细哦～"}</p>
        </div>
      ) : (
        <div className="space-y-5">
          {groupedItems.map((group) => (
            <section key={group.key}>
              <h2 className="font-kids text-lg text-warm-600 mb-2">{group.label}</h2>
              <div className="bg-white rounded-card shadow-soft divide-y divide-warm-100">
                {group.items.map((item) => {
                  const isEarn = item.direction === "EARN"
                  return (
                    <div key={item.id} className="flex items-center gap-3 p-4">
                      <div className={cn(
                        "w-11 h-11 rounded-2xl flex items-center justify-center text-xl shrink-0",
                        isEarn ? "bg-green-50" : "bg-orange-50",
                      )}>
                        {item.icon}
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-semibold text-warm-700 truncate">{item.title}</p>
                        <p className="text-xs text-warm-400 mt-1">
                          {formatTime(item.createdAt)} · {STATUS_LABELS[item.status]}
                        </p>
                      </div>
                      <p className={cn(
                        "text-base font-bold whitespace-nowrap",
                        isEarn ? "text-candy-green" : "text-candy-orange",
                      )}>
                        {isEarn ? "+" : "-"}{formatPoints(Math.abs(item.amount))}⭐
                      </p>
                    </div>
                  )
                })}
              </div>
            </section>
          ))}
        </div>
      )}
    </PageTransition>
  )
}

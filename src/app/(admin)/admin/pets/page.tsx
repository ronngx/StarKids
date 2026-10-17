"use client"

import { useState, useEffect, useCallback } from "react"
import { useRouter } from "next/navigation"
import { createOutfit, updateOutfit, deleteOutfit, unlockOutfit } from "@/lib/actions/outfits"
import { revivePet } from "@/lib/actions/pets"
import { cn } from "@/lib/utils"
import { CardSkeleton } from "@/components/ui/Skeleton"
import { useToast } from "@/components/ui/ToastProvider"
import { formatPoints } from "@/lib/points"

const SPECIES_OPTIONS = [
  { value: "ALL", label: "全部适用", emoji: "🐾" },
  { value: "CAT", label: "小猫", emoji: "🐱" },
  { value: "DOG", label: "小狗", emoji: "🐶" },
  { value: "FOX", label: "小狐狸", emoji: "🦊" },
  { value: "RABBIT", label: "小兔", emoji: "🐰" },
  { value: "DRAGON", label: "小龙", emoji: "🐲" },
  { value: "UNICORN", label: "独角兽", emoji: "🦄" },
  { value: "PANDA", label: "小熊猫", emoji: "🐼" },
  { value: "PENGUIN", label: "小企鹅", emoji: "🐧" },
]

type OutfitMemberInfo = {
  memberId: string
  nickname: string
  petName: string | null
  petSpecies: string | null
  isEquipped: boolean
  isGranted: boolean
}

type OutfitData = {
  id: string
  name: string
  description: string | null
  image: string | null
  species: string | null
  points: number
  isDefault: boolean
  sortOrder: number
  isGlobal: boolean
  members: OutfitMemberInfo[]
}

type MemberInfo = {
  id: string
  nickname: string
  pet: {
    name: string
    species: string
    status: "ALIVE" | "CRITICAL" | "DEAD"
    hunger: number
    thirst: number
    hygiene: number
    energy: number
    mood: number
    deathReason: string | null
  } | null
}

export default function AdminPetsPage() {
  const router = useRouter()
  const { toast } = useToast()
  const [outfits, setOutfits] = useState<OutfitData[]>([])
  const [members, setMembers] = useState<MemberInfo[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")
  const [showForm, setShowForm] = useState(false)
  const [editItem, setEditItem] = useState<OutfitData | null>(null)
  const [grantDialog, setGrantDialog] = useState<{ outfitId: string; outfitName: string; points: number } | null>(null)

  const fetchData = useCallback(async () => {
    try {
      const res = await fetch("/api/admin/outfits")
      if (res.ok) {
        const data = await res.json()
        setOutfits(data.outfits || [])
        setMembers(data.members || [])
      }
    } catch (e) {
      console.error(e)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchData()
  }, [fetchData])

  async function handleCreate(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setError("")
    const formData = new FormData(e.currentTarget)
    try {
      await createOutfit(formData)
      setShowForm(false)
      setEditItem(null)
      e.currentTarget.reset()
      fetchData()
      router.refresh()
    } catch (err: any) {
      setError(err.message)
    }
  }

  async function handleUpdate(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setError("")
    const formData = new FormData(e.currentTarget)
    try {
      await updateOutfit(formData)
      setShowForm(false)
      setEditItem(null)
      fetchData()
      router.refresh()
    } catch (err: any) {
      setError(err.message)
    }
  }

  async function handleDelete(id: string) {
    if (!confirm("确定要删除这个装扮吗？")) return
    await deleteOutfit(id)
    fetchData()
    router.refresh()
  }

  async function handleGrant(memberId: string) {
    if (!grantDialog) return
    const formData = new FormData()
    formData.set("outfitId", grantDialog.outfitId)
    formData.set("memberId", memberId)
    try {
      await unlockOutfit(formData)
      setGrantDialog(null)
      fetchData()
      router.refresh()
    } catch (err: any) {
      toast(err.message, "error")
    }
  }

  async function handleRevive(memberId: string) {
    try {
      await revivePet(memberId)
      toast("宠物已经恢复啦！", "success")
      fetchData()
      router.refresh()
    } catch (err: any) {
      toast(err.message || "恢复失败", "error")
    }
  }

  if (loading) {
    return (
      <div className="space-y-4">
        <h1 className="text-2xl font-bold text-warm-800">🐱 宠物管理</h1>
        <CardSkeleton />
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-warm-800">🐱 宠物管理</h1>
          <p className="text-sm text-warm-400 mt-1">管理宠物装扮和小朋友获取情况</p>
        </div>
        <button
          onClick={() => {
            setShowForm(!showForm)
            setEditItem(null)
          }}
          className="h-10 px-5 bg-admin-primary text-white rounded-xl text-sm font-semibold hover:brightness-110 transition-all"
        >
          + 添加装扮
        </button>
      </div>

      {showForm && (
        <OutfitForm
          onSubmit={editItem ? handleUpdate : handleCreate}
          onCancel={() => {
            setShowForm(false)
            setEditItem(null)
          }}
          editItem={editItem}
          error={error}
        />
      )}

      <div className="bg-white rounded-xl shadow-card p-5">
        <div className="flex items-center justify-between mb-3">
          <div>
            <h2 className="font-semibold text-warm-800">🐾 饲养状态</h2>
            <p className="text-xs text-warm-400 mt-1">查看宠物状态，帮助濒危宠物恢复</p>
          </div>
        </div>
        {members.length === 0 ? (
          <p className="text-sm text-warm-400">还没有小朋友。</p>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {members.map((member) => {
              const pet = member.pet
              if (!pet) return <div key={member.id} className="rounded-xl bg-warm-50 p-3 text-sm text-warm-400">{member.nickname} 暂无宠物</div>
              const needs = [pet.hunger, pet.thirst, pet.hygiene, pet.energy, pet.mood]
              const lowest = Math.min(...needs)
              const statusLabel = pet.status === "DEAD" ? "已死亡" : pet.status === "CRITICAL" ? "需要照顾" : "状态良好"
              return (
                <div key={member.id} className="rounded-xl border border-warm-100 p-3">
                  <div className="flex items-center justify-between gap-2">
                    <div>
                      <p className="text-sm font-semibold text-warm-700">{member.nickname} · {pet.name}</p>
                      <p className={cn("text-xs mt-1", pet.status === "DEAD" ? "text-candy-red" : pet.status === "CRITICAL" ? "text-candy-orange" : "text-candy-green")}>{statusLabel}</p>
                    </div>
                    {pet.status === "DEAD" && (
                      <button onClick={() => handleRevive(member.id)} className="px-3 py-1.5 rounded-lg bg-admin-primary text-white text-xs font-semibold hover:brightness-110">✨ 恢复</button>
                    )}
                  </div>
                  <div className="grid grid-cols-5 gap-1 mt-3 text-center text-[10px] text-warm-400">
                    {[["饱", pet.hunger], ["水", pet.thirst], ["洁", pet.hygiene], ["力", pet.energy], ["心", pet.mood]].map(([label, value]) => (
                      <div key={label as string}>
                        <div className={cn("font-semibold", Number(value) <= 25 ? "text-candy-red" : "text-warm-600")}>{value}</div>
                        <div>{label}</div>
                      </div>
                    ))}
                  </div>
                  {pet.status === "DEAD" && pet.deathReason && <p className="text-xs text-candy-red mt-2">原因：{pet.deathReason}</p>}
                  {lowest <= 25 && pet.status !== "DEAD" && <p className="text-xs text-candy-orange mt-2">这个宠物需要小朋友马上照顾。</p>}
                </div>
              )
            })}
          </div>
        )}
      </div>

      <div className="space-y-4">
        {outfits.length === 0 ? (
          <div className="text-center py-12 text-warm-400">
            <p className="text-4xl mb-2">👗</p>
            <p>还没有创建宠物装扮，快来创建吧！</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
            {outfits.map((outfit) => (
              <div key={outfit.id} className="bg-white rounded-xl shadow-card overflow-hidden">
                <div className="p-5">
                  <div className="flex items-start gap-4">
                    <div className="text-4xl">{outfit.image || "👗"}</div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 flex-wrap">
                        <h3 className="font-semibold text-warm-800">{outfit.name}</h3>
                        {outfit.isDefault && (
                          <span className="text-xs px-2 py-0.5 rounded-full bg-candy-green/10 text-candy-green">默认</span>
                        )}
                        {outfit.isGlobal && (
                          <span className="text-xs px-2 py-0.5 rounded-full bg-admin-primary/10 text-admin-primary">全局</span>
                        )}
                        {outfit.species && (
                          <span className="text-xs px-2 py-0.5 rounded-full bg-warm-100 text-warm-600">
                            {SPECIES_OPTIONS.find((s) => s.value === outfit.species)?.emoji} {SPECIES_OPTIONS.find((s) => s.value === outfit.species)?.label}
                          </span>
                        )}
                      </div>
                      {outfit.description && (
                        <p className="text-sm text-warm-400 mt-1">{outfit.description}</p>
                      )}
                      <div className="flex items-center gap-3 mt-2 text-sm">
                        {outfit.points > 0 && (
                          <span className="text-candy-orange font-semibold">{formatPoints(outfit.points)}⭐</span>
                        )}
                        {outfit.points === 0 && !outfit.isDefault && (
                          <span className="text-candy-green font-semibold">免费</span>
                        )}
                      </div>
                    </div>
                    <div className="flex items-center gap-1">
                      {!outfit.isDefault && (
                        <button
                          onClick={() => setGrantDialog({
                            outfitId: outfit.id,
                            outfitName: outfit.name,
                            points: outfit.points,
                          })}
                          className="h-8 w-8 flex items-center justify-center rounded-lg text-warm-400 hover:bg-candy-purple/10 hover:text-candy-purple transition-colors"
                          title="发放给小朋友"
                        >
                          🎁
                        </button>
                      )}
                      <button
                        onClick={() => {
                          setEditItem(outfit)
                          setShowForm(true)
                        }}
                        className="h-8 w-8 flex items-center justify-center rounded-lg text-warm-400 hover:bg-admin-primary/10 hover:text-admin-primary transition-colors"
                        title="编辑"
                      >
                        ✏️
                      </button>
                      <button
                        onClick={() => handleDelete(outfit.id)}
                        className="h-8 w-8 flex items-center justify-center rounded-lg text-warm-400 hover:bg-candy-red/10 hover:text-candy-red transition-colors"
                        title="删除"
                      >
                        🗑️
                      </button>
                    </div>
                  </div>
                </div>

                {outfit.members.length > 0 && (
                  <div className="border-t border-warm-100 px-5 py-3 bg-warm-50/50">
                    <p className="text-xs text-warm-400 mb-2">小朋友获取情况：</p>
                    <div className="flex flex-wrap gap-2">
                      {outfit.members.map((m) => (
                        <span
                          key={m.memberId}
                          className={cn(
                            "text-xs px-2 py-1 rounded-full",
                            m.isEquipped
                              ? "bg-candy-purple/10 text-candy-purple"
                              : m.isGranted
                              ? "bg-candy-green/10 text-candy-green"
                              : "bg-warm-100 text-warm-400"
                          )}
                        >
                          {m.nickname}
                          {!m.petName && " (无宠物)"}
                          {m.isEquipped && " 👗"}
                          {m.isGranted && !m.isEquipped && " ✅"}
                        </span>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {grantDialog && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/30" onClick={() => setGrantDialog(null)}>
          <div className="bg-white rounded-2xl shadow-elevated p-6 w-full max-w-sm space-y-4" onClick={(e) => e.stopPropagation()}>
            <h3 className="font-semibold text-warm-800">
              🎁 发放装扮: {grantDialog.outfitName}
            </h3>
            <p className="text-sm text-warm-500">
              选择要获得此装扮的小朋友
              {grantDialog.points > 0 && ` (消耗 ${formatPoints(grantDialog.points)}⭐)`}
            </p>
            <div className="space-y-2">
              {members.map((m) => (
                <button
                  key={m.id}
                  onClick={() => handleGrant(m.id)}
                  className="w-full p-3 rounded-xl border border-warm-200 text-left hover:border-admin-primary hover:bg-admin-primary/5 transition-all"
                >
                  <span className="text-sm font-medium text-warm-700">{m.nickname}</span>
                </button>
              ))}
            </div>
            <button
              onClick={() => setGrantDialog(null)}
              className="w-full h-10 bg-warm-100 text-warm-600 rounded-xl text-sm font-medium hover:bg-warm-200 transition-colors"
            >
              取消
            </button>
          </div>
        </div>
      )}
    </div>
  )
}

function OutfitForm({
  onSubmit,
  onCancel,
  editItem,
  error,
}: {
  onSubmit: (e: React.FormEvent<HTMLFormElement>) => void
  onCancel: () => void
  editItem?: OutfitData | null
  error?: string
}) {
  return (
    <form onSubmit={onSubmit} className="bg-white rounded-xl shadow-card p-5 space-y-4">
      <h3 className="font-semibold text-warm-700">{editItem ? "编辑装扮" : "添加新装扮"}</h3>

      {error && (
        <div className="bg-candy-red/10 text-candy-red text-sm rounded-xl p-3">{error}</div>
      )}

      {editItem && <input type="hidden" name="id" value={editItem.id} />}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-warm-600 mb-1">装扮名称 *</label>
          <input
            name="name"
            required
            defaultValue={editItem?.name || ""}
            placeholder="如：皇冠"
            className="w-full h-10 px-3 rounded-lg border border-warm-200 text-sm focus:border-admin-primary focus:outline-none"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-warm-600 mb-1">显示图标</label>
          <input
            name="image"
            defaultValue={editItem?.image || "👗"}
            placeholder="emoji图标"
            className="w-full h-10 px-3 rounded-lg border border-warm-200 text-sm focus:border-admin-primary focus:outline-none"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-warm-600 mb-1">适用宠物</label>
          <select
            name="species"
            defaultValue={editItem?.species || "ALL"}
            className="w-full h-10 px-3 rounded-lg border border-warm-200 text-sm focus:border-admin-primary focus:outline-none"
          >
            {SPECIES_OPTIONS.map((s) => (
              <option key={s.value} value={s.value}>{s.emoji} {s.label}</option>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-warm-600 mb-1">所需积分（最多两位小数，0=免费）</label>
          <input
            name="points"
            type="number"
            defaultValue={editItem?.points || 0}
            min={0}
            step={0.01}
            className="w-full h-10 px-3 rounded-lg border border-warm-200 text-sm"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-warm-600 mb-1">排序</label>
          <input
            name="sortOrder"
            type="number"
            defaultValue={editItem?.sortOrder || 0}
            className="w-full h-10 px-3 rounded-lg border border-warm-200 text-sm"
          />
        </div>
        <div className="md:col-span-2">
          <label className="block text-sm font-medium text-warm-600 mb-1">描述</label>
          <input
            name="description"
            defaultValue={editItem?.description || ""}
            placeholder="装扮描述..."
            className="w-full h-10 px-3 rounded-lg border border-warm-200 text-sm focus:border-admin-primary focus:outline-none"
          />
        </div>
      </div>

      <div className="flex items-center gap-2">
        <input
          type="checkbox"
          name="isDefault"
          value="true"
          defaultChecked={editItem?.isDefault}
          id="isDefault"
          className="rounded"
        />
        <label htmlFor="isDefault" className="text-sm text-warm-600">默认解锁</label>
      </div>

      <div className="flex gap-3">
        <button
          type="submit"
          className="h-10 px-5 bg-admin-primary text-white rounded-xl text-sm font-semibold hover:brightness-110 transition-all"
        >
          {editItem ? "保存修改" : "添加装扮"}
        </button>
        <button
          type="button"
          onClick={onCancel}
          className="h-10 px-5 bg-warm-100 text-warm-600 rounded-xl text-sm hover:bg-warm-200 transition-colors"
        >
          取消
        </button>
      </div>
    </form>
  )
}

"use client"

import { useState, useEffect, useCallback } from "react"
import { useRouter } from "next/navigation"
import { useSession } from "next-auth/react"
import { cn } from "@/lib/utils"
import { SPECIES_EMOJI, STAGE_LABELS } from "@/lib/constants"
import { CardSkeleton } from "@/components/ui/Skeleton"
import { useToast } from "@/components/ui/ToastProvider"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { memberUpdateSchema, usernameSchema, passwordSchema } from "@/lib/credentials"

type FamilyMember = {
  id: string
  nickname: string | null
  role: string
  userId: string
  user: { username: string }
  createdAt: string
  currentPoints: number
  pet: { name: string; species: string; stage: string } | null
}

type FamilyData = {
  name: string
  inviteCode: string
  createdAt: string
  canManageMembers: boolean
  members: FamilyMember[]
}

const addKidSchema = z.object({
  nickname: z.string().min(2, "昵称至少2个字符"),
  username: usernameSchema,
  password: passwordSchema,
})

type AddKidValues = z.infer<typeof addKidSchema>

const editMemberSchema = memberUpdateSchema.extend({
  confirmPassword: z.string(),
}).refine((values) => values.password === values.confirmPassword, {
  message: "两次输入的密码不一致",
  path: ["confirmPassword"],
})
type EditMemberValues = z.infer<typeof editMemberSchema>

function MemberEditForm({ member, saving, onCancel, onSave }: {
  member: FamilyMember
  saving: boolean
  onCancel: () => void
  onSave: (values: EditMemberValues) => Promise<void>
}) {
  const { register, handleSubmit, formState: { errors } } = useForm<EditMemberValues>({
    resolver: zodResolver(editMemberSchema),
    defaultValues: {
      nickname: member.nickname ?? "",
      username: member.user.username,
      password: "",
      confirmPassword: "",
    },
  })
  const fields = [
    { name: "nickname", label: "昵称", type: "text", placeholder: "至少2个字符", autoComplete: "off" },
    { name: "username", label: "用户名", type: "text", placeholder: "用于登录的用户名", autoComplete: "username" },
    { name: "password", label: "新密码（选填）", type: "password", placeholder: "留空保留原密码，修改时至少6位", autoComplete: "new-password" },
    { name: "confirmPassword", label: "确认新密码", type: "password", placeholder: "修改密码时请再次输入", autoComplete: "new-password" },
  ] as const

  return (
    <form onSubmit={handleSubmit(onSave)} className="border-t border-warm-100 mt-4 pt-4" aria-label={`编辑${member.nickname || member.user.username}`}>
      <h3 className="text-sm font-semibold text-warm-700 mb-2">编辑成员</h3>
      <p className="text-xs text-warm-500 mb-4">用户名用于登录。新密码留空则保留原密码。</p>
      <fieldset disabled={saving} className="space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {fields.map((field) => (
            <div key={field.name} className="min-w-0">
              <label htmlFor={`${member.id}-${field.name}`} className="block text-sm font-medium text-warm-600 mb-1">{field.label}</label>
              <input
                {...register(field.name)}
                id={`${member.id}-${field.name}`}
                type={field.type}
                autoComplete={field.autoComplete}
                autoCapitalize="none"
                spellCheck={false}
                placeholder={field.placeholder}
                aria-invalid={!!errors[field.name]}
                aria-describedby={errors[field.name] ? `${member.id}-${field.name}-error` : undefined}
                className="w-full h-11 px-3 rounded-xl border border-warm-200 bg-warm-50 text-warm-700 text-base sm:text-sm focus:border-admin-primary focus:outline-none disabled:opacity-60"
              />
              {errors[field.name] && <p id={`${member.id}-${field.name}-error`} className="text-candy-red text-xs mt-1" role="alert">{errors[field.name]?.message}</p>}
            </div>
          ))}
        </div>
        <div className="flex gap-2 sm:justify-end">
          <button type="button" onClick={onCancel} className="flex-1 sm:flex-none h-11 px-5 rounded-xl border border-warm-200 text-warm-600 text-sm font-semibold hover:bg-warm-100 disabled:opacity-50">取消</button>
          <button type="submit" className="flex-1 sm:flex-none h-11 px-5 rounded-xl bg-admin-primary text-white text-sm font-semibold hover:brightness-110 disabled:opacity-50">{saving ? "保存中..." : "保存修改"}</button>
        </div>
      </fieldset>
    </form>
  )
}

export default function AdminFamilyPage() {
  const router = useRouter()
  const { data: session, update: updateSession } = useSession()
  const { toast } = useToast()
  const [data, setData] = useState<FamilyData | null>(null)
  const [loading, setLoading] = useState(true)
  const [noFamily, setNoFamily] = useState(false)
  const [copied, setCopied] = useState(false)
  const [showAddKid, setShowAddKid] = useState(false)
  const [addingKid, setAddingKid] = useState(false)
  const [editingMemberId, setEditingMemberId] = useState<string | null>(null)
  const [savingMember, setSavingMember] = useState(false)

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<AddKidValues>({
    resolver: zodResolver(addKidSchema),
  })

  const fetchData = useCallback(async () => {
    try {
      const res = await fetch("/api/family/members")
      if (res.ok) {
        setData(await res.json())
      } else if (res.status === 404) {
        setNoFamily(true)
      }
    } catch {
      // keep empty state
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchData()
  }, [fetchData])

  async function copyInviteCode() {
    if (!data?.inviteCode) return
    try {
      await navigator.clipboard.writeText(data.inviteCode)
      setCopied(true)
      toast("邀请码已复制！", "success")
      setTimeout(() => setCopied(false), 2000)
    } catch {
      toast("复制失败，请手动复制", "error")
    }
  }

  async function onAddKid(values: AddKidValues) {
    setAddingKid(true)
    try {
      const fd = new FormData()
      fd.append("nickname", values.nickname)
      fd.append("username", values.username)
      fd.append("password", values.password)

      const res = await fetch("/api/family/add-kid", {
        method: "POST",
        body: fd,
      })

      const json = await res.json()
      if (res.ok && json.success) {
        toast(`小朋友「${json.kidNickname}」已加入家庭！`, "success")
        setShowAddKid(false)
        reset()
        fetchData()
      } else {
        toast(json.error || "添加失败", "error")
      }
    } catch {
      toast("网络错误，请稍后重试", "error")
    } finally {
      setAddingKid(false)
    }
  }

  async function onSaveMember(member: FamilyMember, values: EditMemberValues) {
    setSavingMember(true)
    try {
      const fd = new FormData()
      fd.set("memberId", member.id)
      fd.set("nickname", values.nickname)
      fd.set("username", values.username)
      fd.set("password", values.password)
      const res = await fetch("/api/family/members", { method: "PATCH", body: fd })
      const json = await res.json()
      if (!res.ok || !json.success) {
        toast(json.error || "修改失败", "error")
        return
      }
      toast(`成员「${json.nickname}」已更新`, "success")
      setEditingMemberId(null)
      await fetchData()
      if (member.userId === session?.user?.id) {
        await updateSession({}).catch(() => undefined)
      }
      router.refresh()
    } catch {
      toast("网络错误，请稍后重试", "error")
    } finally {
      setSavingMember(false)
    }
  }

  function renderMember(member: FamilyMember) {
    const isKid = member.role === "KID"
    const editing = editingMemberId === member.id
    return (
      <div key={member.id} className="bg-white rounded-xl shadow-card p-4">
        <div className="flex flex-wrap items-center gap-3 sm:gap-4">
          <div className={cn("w-12 h-12 shrink-0 rounded-full flex items-center justify-center text-2xl", isKid ? "bg-brand-50" : "bg-blue-50")}>
            {isKid ? (member.pet?.species ? SPECIES_EMOJI[member.pet.species] || "🌟" : "🌟") : "👑"}
          </div>
          <div className="min-w-0 flex-1">
            <p className="font-semibold text-sm text-warm-700 break-all">{member.nickname || member.user.username}</p>
            <p className="text-xs text-warm-500 break-all">用户名：{member.user.username}</p>
            <p className="text-xs text-warm-400">
              {isKid ? (member.pet ? `${member.pet.name} · ${STAGE_LABELS[member.pet.stage] || member.pet.stage}` : "暂无宠物") : `加入于 ${new Date(member.createdAt).toLocaleDateString("zh-CN")}`}
            </p>
          </div>
          <div className="flex flex-wrap items-center justify-end gap-3 w-full sm:w-auto">
            {isKid && <div className="text-right">
              <p className="text-sm font-kids text-candy-orange">{member.currentPoints || 0}⭐</p>
              <p className="text-xs text-warm-400">当前积分</p>
            </div>}
            {data?.canManageMembers && <button
              type="button"
              disabled={savingMember}
              aria-expanded={editing}
              aria-controls={`edit-member-${member.id}`}
              onClick={() => setEditingMemberId(editing ? null : member.id)}
              className="h-10 px-4 rounded-xl border border-warm-200 text-admin-primary text-sm font-semibold hover:bg-warm-50 disabled:opacity-50"
            >{editing ? "收起" : "编辑"}</button>}
          </div>
        </div>
        {editing && <div id={`edit-member-${member.id}`}>
          <MemberEditForm member={member} saving={savingMember} onCancel={() => setEditingMemberId(null)} onSave={(values) => onSaveMember(member, values)} />
        </div>}
      </div>
    )
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <h1 className="text-2xl font-bold text-warm-800">👨‍👩‍👧‍👦 家庭成员</h1>
        <CardSkeleton />
      </div>
    )
  }

  if (noFamily) {
    return (
      <div className="space-y-6">
        <h1 className="text-2xl font-bold text-warm-800">👨‍👩‍👧‍👦 家庭成员</h1>
        <div className="bg-admin-card rounded-xl shadow-card p-10 text-center">
          <p className="text-5xl mb-4">🏡</p>
          <h2 className="text-lg font-semibold text-warm-700 mb-2">还没有创建家庭</h2>
          <p className="text-sm text-warm-400 mb-6">
            创建一个家庭来邀请小朋友，开始游戏化教育之旅
          </p>
          <button
            onClick={() => router.push("/register")}
            className="inline-flex items-center gap-2 h-12 px-6 bg-candy-blue text-white font-bold font-kids rounded-btn hover:brightness-110 transition-all"
          >
            ✨ 创建家庭
          </button>
        </div>
      </div>
    )
  }

  if (!data) {
    return (
      <div className="space-y-6">
        <h1 className="text-2xl font-bold text-warm-800">👨‍👩‍👧‍👦 家庭成员</h1>
        <div className="bg-admin-card rounded-xl shadow-card p-10 text-center">
          <p className="text-4xl mb-3">😵</p>
          <p className="text-sm text-warm-400">加载失败，请刷新重试</p>
        </div>
      </div>
    )
  }

  const parents = data.members.filter((m) => m.role === "PARENT")
  const kids = data.members.filter((m) => m.role === "KID")

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-warm-800">👨‍👩‍👧‍👦 家庭成员</h1>
          <p className="text-sm text-warm-400 mt-1">
            {data.name} · {data.members.length} 位成员
          </p>
        </div>
        {data.canManageMembers && <button
          onClick={() => setShowAddKid(true)}
          className="flex items-center gap-2 h-10 px-4 bg-candy-green text-white font-semibold text-sm rounded-xl hover:brightness-110 transition-all"
        >
          <span>➕</span>
          <span>添加小朋友</span>
        </button>}
      </div>

      {showAddKid && (
        <div className="fixed inset-0 z-50 bg-black/40 flex items-center justify-center p-5">
          <div className="bg-white rounded-2xl shadow-elevated p-6 w-full max-w-md space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="font-kids text-xl text-warm-700">➕ 添加小朋友</h3>
              <button
                onClick={() => { setShowAddKid(false); reset() }}
                className="text-warm-400 hover:text-warm-600 text-xl"
              >
                ✕
              </button>
            </div>
            <p className="text-xs text-warm-400">
              为小朋友创建独立账号，直接加入当前家庭。小朋友可以使用该账号登录。
            </p>
            <form onSubmit={handleSubmit(onAddKid)} className="space-y-3">
              <div>
                <label className="block text-sm font-medium text-warm-600 mb-1">昵称</label>
                <input
                  {...register("nickname")}
                  placeholder="如：朵朵、小明"
                  className="w-full h-11 px-3 rounded-xl border border-warm-200 bg-warm-50 text-warm-700 text-sm focus:border-candy-green focus:outline-none"
                />
                {errors.nickname && <p className="text-candy-red text-xs mt-1">{errors.nickname.message}</p>}
              </div>
              <div>
                <label className="block text-sm font-medium text-warm-600 mb-1">用户名</label>
                <input
                  type="text"
                  {...register("username")}
                  placeholder="如：朵朵、duoduo"
                  autoComplete="username"
                  autoCapitalize="none"
                  spellCheck={false}
                  className="w-full h-11 px-3 rounded-xl border border-warm-200 bg-warm-50 text-warm-700 text-sm focus:border-candy-green focus:outline-none"
                />
                {errors.username && <p className="text-candy-red text-xs mt-1">{errors.username.message}</p>}
              </div>
              <div>
                <label className="block text-sm font-medium text-warm-600 mb-1">登录密码</label>
                <input
                  type="password"
                  {...register("password")}
                  placeholder="至少6位密码"
                  className="w-full h-11 px-3 rounded-xl border border-warm-200 bg-warm-50 text-warm-700 text-sm focus:border-candy-green focus:outline-none"
                />
                {errors.password && <p className="text-candy-red text-xs mt-1">{errors.password.message}</p>}
              </div>
              <div className="flex gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => { setShowAddKid(false); reset() }}
                  className="flex-1 h-11 rounded-xl border border-warm-200 text-warm-600 font-semibold text-sm hover:bg-warm-100 transition-colors"
                >
                  取消
                </button>
                <button
                  type="submit"
                  disabled={addingKid}
                  className="flex-1 h-11 bg-candy-green text-white font-bold font-kids text-sm rounded-xl hover:brightness-110 transition-all disabled:opacity-50"
                >
                  {addingKid ? "添加中..." : "✅ 添加小朋友"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <div className="bg-white rounded-xl shadow-card p-5 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <p className="text-xs text-warm-400 uppercase tracking-wide">邀请码</p>
          <p className="font-mono text-xl font-bold text-admin-primary tracking-widest mt-0.5">
            {data.inviteCode}
          </p>
        </div>
        <button
          onClick={copyInviteCode}
          className={cn(
            "h-10 px-5 rounded-xl text-sm font-semibold transition-all",
            copied
              ? "bg-candy-green text-white"
              : "bg-admin-primary text-white hover:brightness-110"
          )}
        >
          {copied ? "✅ 已复制" : "📋 复制"}
        </button>
      </div>

      {parents.length > 0 && (
        <div>
          <h2 className="font-semibold text-warm-700 mb-3">👑 家长 ({parents.length})</h2>
          <div className="space-y-2">
            {parents.map(renderMember)}
          </div>
        </div>
      )}

      {kids.length > 0 && (
        <div>
          <h2 className="font-semibold text-warm-700 mb-3">🌟 小朋友 ({kids.length})</h2>
          <div className="space-y-2">
            {kids.map(renderMember)}
          </div>
        </div>
      )}

      {data.members.length === 0 && (
        <div className="text-center py-12 text-warm-400">
          <p className="text-4xl mb-2">👨‍👩‍👧‍👦</p>
          <p>还没有家庭成员</p>
        </div>
      )}
    </div>
  )
}

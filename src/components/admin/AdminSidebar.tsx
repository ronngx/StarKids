"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { useEffect, useState } from "react"
import { cn } from "@/lib/utils"
import { signOut } from "next-auth/react"

const adminNavItems = [
  {
    section: "总览",
    items: [
      { href: "/admin", label: "管理仪表盘", icon: "📊" },
      { href: "/admin/notifications", label: "通知消息", icon: "🔔" },
    ],
  },
  {
    section: "管理",
    items: [
      { href: "/admin/family", label: "家庭成员", icon: "👨‍👩‍👧‍👦" },
      { href: "/admin/tasks", label: "任务管理", icon: "📋" },
      { href: "/admin/points", label: "积分规则", icon: "⭐" },
      { href: "/admin/shop", label: "积分商城", icon: "🛒" },
    ],
  },
  {
    section: "数据",
    items: [
      { href: "/admin/achievements", label: "成就系统", icon: "🏆" },
      { href: "/admin/pets", label: "宠物管理", icon: "🐱" },
      { href: "/admin/analytics", label: "统计分析", icon: "📈" },
    ],
  },
]

export function AdminSidebar() {
  const pathname = usePathname()
  const [mobileOpen, setMobileOpen] = useState(false)

  // Closing the drawer after navigation keeps the new page fully visible on mobile.
  useEffect(() => {
    setMobileOpen(false)
  }, [pathname])

  return (
    <>
      <div className="fixed inset-x-0 top-0 z-30 flex h-16 items-center justify-between border-b border-warm-200 bg-white px-4 md:hidden">
        <Link href="/admin" className="flex items-center gap-2" aria-label="返回管理仪表盘">
          <span className="text-2xl">🌟</span>
          <span className="font-kids text-xl text-candy-purple">StarKids</span>
        </Link>
        <button
          type="button"
          onClick={() => setMobileOpen((open) => !open)}
          className="flex h-10 w-10 items-center justify-center rounded-xl text-xl text-warm-600 hover:bg-warm-100"
          aria-label={mobileOpen ? "关闭管理菜单" : "打开管理菜单"}
          aria-expanded={mobileOpen}
        >
          {mobileOpen ? "✕" : "☰"}
        </button>
      </div>

      {mobileOpen && (
        <button
          type="button"
          className="fixed inset-0 z-40 bg-black/30 md:hidden"
          aria-label="关闭管理菜单"
          onClick={() => setMobileOpen(false)}
        />
      )}

      <aside
        className={cn(
          "fixed top-0 left-0 z-50 flex h-screen w-64 flex-col border-r border-warm-200 bg-white transition-transform duration-200",
          mobileOpen ? "translate-x-0" : "-translate-x-full md:translate-x-0"
        )}
      >
      <div className="h-16 flex items-center px-6 border-b border-warm-200">
        <Link href="/admin" className="flex items-center gap-2">
          <span className="text-2xl">🌟</span>
          <span className="font-kids text-xl text-candy-purple">StarKids</span>
        </Link>
      </div>

      <nav className="flex-1 overflow-y-auto py-4 px-3 space-y-6">
        {adminNavItems.map((section) => (
          <div key={section.section}>
            <h3 className="px-3 mb-2 text-xs font-semibold text-warm-400 uppercase tracking-wider">
              {section.section}
            </h3>
            <ul className="space-y-1">
              {section.items.map((item) => {
                const isActive = pathname === item.href
                return (
                  <li key={item.href}>
                    <Link
                      href={item.href}
                      className={cn(
                        "flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-colors",
                        isActive
                          ? "bg-admin-primary text-white"
                          : "text-warm-600 hover:bg-warm-100"
                      )}
                    >
                      <span className="text-lg">{item.icon}</span>
                      <span>{item.label}</span>
                    </Link>
                  </li>
                )
              })}
            </ul>
          </div>
        ))}
      </nav>

      <div className="border-t border-warm-200 p-4 space-y-2">
        <Link
          href="/"
          className="flex items-center gap-2 text-sm text-warm-400 hover:text-warm-600 transition-colors"
        >
          <span>←</span>
          <span>返回首页</span>
        </Link>
        <button
          onClick={() => signOut({ callbackUrl: "/login" })}
          className="flex items-center gap-2 text-sm text-warm-400 hover:text-candy-red transition-colors w-full"
        >
          <span>🚪</span>
          <span>退出登录</span>
        </button>
      </div>
      </aside>
    </>
  )
}

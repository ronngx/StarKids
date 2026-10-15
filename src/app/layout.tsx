import type { Metadata } from "next"
import "./fonts.css"
import "./globals.css"
import { ToastProvider } from "@/components/ui/ToastProvider"

export const metadata: Metadata = {
  title: "StarKids - 小朋友奖励乐园",
  description: "用游戏化的方式，让好习惯自然生长",
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="zh-CN">
      <head>
        <link rel="preload" href="/fonts/b4d22b1bb46a35b5-s.p.woff2" as="font" type="font/woff2" crossOrigin="anonymous" />
        <link rel="preload" href="/fonts/c0e0405d4c58da10-s.p.woff2" as="font" type="font/woff2" crossOrigin="anonymous" />
      </head>
      <body className="font-parent text-warm-700 bg-warm-50 antialiased">
        <ToastProvider>
          {children}
        </ToastProvider>
      </body>
    </html>
  )
}

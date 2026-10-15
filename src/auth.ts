import NextAuth from "next-auth"
import Credentials from "next-auth/providers/credentials"
import bcrypt from "bcryptjs"
import { prisma } from "@/lib/db"
import { credentialsSchema } from "@/lib/credentials"

export const { handlers, auth, signIn, signOut } = NextAuth({
  session: { strategy: "jwt" },
  providers: [
    Credentials({
      name: "credentials",
      credentials: {
        username: { label: "用户名", type: "text" },
        password: { label: "密码", type: "password" },
      },
      async authorize(credentials) {
        const parsed = credentialsSchema.safeParse(credentials)
        if (!parsed.success) return null
        const { username, password } = parsed.data

        const user = await prisma.user.findUnique({
          where: { username },
        })

        if (!user || !user.isActive || !user.passwordHash) {
          return null
        }

        const isValid = await bcrypt.compare(password, user.passwordHash)
        if (!isValid) return null

        await prisma.user.update({
          where: { id: user.id },
          data: { lastLoginAt: new Date() },
        })

        return {
          id: user.id,
          username: user.username,
          name: user.name,
          role: user.role,
        }
      },
    }),
  ],
  pages: {
    signIn: "/login",
    error: "/login/error",
  },
  callbacks: {
    async jwt({ token, user, trigger }) {
      if (user) {
        token.id = user.id!
        token.role = user.role
        token.username = user.username
      }
      if (trigger === "update" && typeof token.id === "string") {
        // Read profile changes from the database; never accept client-supplied identity or roles.
        const profile = await prisma.user.findUnique({
          where: { id: token.id },
          select: { username: true, name: true },
        })
        if (profile) {
          token.username = profile.username
          token.name = profile.name
        }
      }
      return token
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.id as string
        session.user.role = token.role as string
        session.user.username = typeof token.username === "string" ? token.username : ""
        session.user.name = token.name ?? null
      }
      return session
    },
  },
})

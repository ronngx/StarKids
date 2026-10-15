import { z } from "zod"

export const usernameSchema = z.string()
  .trim()
  .toLowerCase()
  .min(2, "用户名至少2个字符")
  .max(64, "用户名最多64个字符")
  .regex(/^[\p{L}\p{N}_.-]+$/u, "用户名只能包含中文、字母、数字、下划线、短横线和点")

export const passwordSchema = z.string().min(6, "密码至少6位")

export const credentialsSchema = z.object({
  username: usernameSchema,
  password: passwordSchema,
})

export const registrationSchema = credentialsSchema.extend({
  nickname: z.string().trim().min(2, "昵称至少2个字符"),
  role: z.enum(["PARENT", "KID"], { error: "无效的角色选择" }),
})

export const memberUpdateSchema = z.object({
  nickname: registrationSchema.shape.nickname,
  username: usernameSchema,
  // An empty value means keep the current password. Password whitespace matters.
  password: z.union([z.literal(""), passwordSchema]),
})

/**
 * 积分统一使用最多两位小数。
 * 所有来自表单、JSON 或数据库的积分值都应经过这里解析/规整，避免
 * parseInt 截断小数以及 JavaScript 浮点运算产生长尾小数。
 */
export const POINT_DECIMAL_PLACES = 2
export const POINT_FACTOR = 10 ** POINT_DECIMAL_PLACES

export type PointParseOptions = {
  min?: number
  defaultValue?: number
  fieldName?: string
}

export function roundPoints(value: number): number {
  if (!Number.isFinite(value)) return value
  return Math.round((value + Number.EPSILON) * POINT_FACTOR) / POINT_FACTOR
}

export function parsePoints(value: unknown, options: PointParseOptions = {}): number {
  const { min = 0, defaultValue, fieldName = "积分" } = options

  if (value === null || value === undefined || (typeof value === "string" && value.trim() === "")) {
    if (defaultValue !== undefined) {
      const normalizedDefault = roundPoints(defaultValue)
      if (normalizedDefault < min) {
        throw new Error(`${fieldName}不能小于 ${formatPoints(min)}`)
      }
      return normalizedDefault
    }
    throw new Error(`${fieldName}不能为空`)
  }

  const raw = typeof value === "string" ? value.trim() : String(value)
  // 只接受普通十进制写法，避免 1e2、Infinity 等绕过小数位限制。
  if (!/^\d+(?:\.\d{1,2})?$/.test(raw)) {
    throw new Error(`${fieldName}必须是非负数字，且最多两位小数`)
  }

  const parsed = Number(raw)
  if (!Number.isFinite(parsed)) throw new Error(`${fieldName}格式不正确`)

  const normalized = roundPoints(parsed)
  if (normalized < min) {
    throw new Error(`${fieldName}不能小于 ${formatPoints(min)}`)
  }
  return normalized
}

export function normalizePoints(value: number | null | undefined): number {
  if (value === null || value === undefined) return 0
  const parsed = typeof value === "number" ? value : Number(value)
  return Number.isFinite(parsed) ? roundPoints(parsed) : 0
}

export function formatPoints(value: number | null | undefined): string {
  const normalized = normalizePoints(value)
  return normalized.toFixed(2).replace(/\.00$/, "").replace(/(\.\d)0$/, "$1")
}


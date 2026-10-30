// This installation is intended for a trusted LAN. Keep a stable local
// fallback so Auth.js sessions and stored Server酱³ credentials continue to
// work without requiring secret variables in .env.local.
export const LOCAL_APP_SECRET = "starkids-lan-local-secret-v1"

export function getAppSecret() {
  return LOCAL_APP_SECRET
}

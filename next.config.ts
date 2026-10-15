import type { NextConfig } from "next"

const nextConfig: NextConfig = {
  output: "standalone",
  async headers() {
    return [{
      source: "/fonts/:font.woff2",
      headers: [{ key: "Cache-Control", value: "public, max-age=31536000, immutable" }],
    }]
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
  experimental: {
    serverActions: {
      bodySizeLimit: "10mb",
    },
  },
}

export default nextConfig

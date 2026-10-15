# syntax=docker/dockerfile:1

FROM node:22-alpine AS base

FROM base AS deps
RUN apk add --no-cache libc6-compat python3 make g++
WORKDIR /app

COPY package.json package-lock.json ./
RUN --mount=type=cache,id=starkids-npm,target=/root/.npm,sharing=locked \
    npm ci --prefer-offline --no-audit --no-fund

# Generate the client only when dependencies or the Prisma schema/config change.
FROM deps AS prisma-client
COPY prisma ./prisma
COPY docker/prisma.config.ts ./prisma.config.ts
RUN sed -i 's/provider = "sqlite"/provider = "postgresql"/' prisma/schema.prisma
RUN DATABASE_URL=postgresql://build:build@localhost:5432/starkids npx prisma generate

# Reuse the installed dependencies instead of compiling native modules twice.
FROM deps AS production-deps
RUN --mount=type=cache,id=starkids-npm,target=/root/.npm,sharing=locked \
    npm prune --omit=dev --prefer-offline --no-audit --no-fund

FROM prisma-client AS builder
ENV NEXT_TELEMETRY_DISABLED=1
ARG NEXT_PUBLIC_APP_URL=http://localhost:3000
ENV NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL

# Copy only build inputs so deployment scripts and local files do not bust caches.
COPY src ./src
COPY public ./public
COPY next.config.ts next-env.d.ts tsconfig.json postcss.config.mjs ./
# Keep compilation caches between source changes. Build-time placeholders
# allow route analysis without depending on a running DB or runtime credentials.
RUN --mount=type=cache,id=starkids-next,target=/app/.next/cache,sharing=locked \
    DATABASE_URL=postgresql://build:build@localhost:5432/starkids \
    AUTH_SECRET=starkids-build-only-placeholder npm run build

FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Keep large, stable runtime layers ahead of frequently changing build output.
COPY --from=production-deps /app/node_modules ./node_modules
COPY --from=prisma-client /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=prisma-client /app/prisma ./prisma
COPY --from=prisma-client /app/prisma.config.ts ./prisma.config.ts

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "server.js"]

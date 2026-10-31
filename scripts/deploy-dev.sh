#!/usr/bin/env bash

# Prepare the local SQLite database and start a background Next.js dev server.

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
PID_FILE="${STAR_KIDS_PID_FILE:-${APP_ROOT}/.starkids-dev.pid}"
LOG_FILE="${STAR_KIDS_LOG_FILE:-${APP_ROOT}/.starkids-dev.log}"
HOST="${STAR_KIDS_DEV_HOST:-0.0.0.0}"
PORT="${STAR_KIDS_DEV_PORT:-${PORT:-3000}}"

die() {
  printf '开发部署失败：%s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'USAGE'
用法：bash scripts/deploy-dev.sh [选项]

准备开发环境并在后台启动 Next.js 开发服务器：
  1. 安装锁定版本依赖（npm ci）
  2. 生成 Prisma Client
  3. 使用 db:push 同步本地 SQLite Schema
  4. 后台启动 next dev

选项：
  --host HOST       监听地址，默认 0.0.0.0
  --port PORT       监听端口，默认 PORT 环境变量或 3000
  --env-file FILE   使用指定环境文件，默认 .env.local
  -h, --help        显示帮助

环境变量：
  STAR_KIDS_PID_FILE  PID 文件路径，默认 .starkids-dev.pid
  STAR_KIDS_LOG_FILE  日志文件路径，默认 .starkids-dev.log
  STAR_KIDS_DEV_HOST  默认监听地址
  STAR_KIDS_DEV_PORT  默认监听端口
USAGE
}

ENV_FILE="${APP_ROOT}/.env.local"
while (($# > 0)); do
  case "$1" in
    --host)
      (($# >= 2)) || die "--host 需要地址"
      HOST="$2"
      shift 2
      ;;
    --port)
      (($# >= 2)) || die "--port 需要端口号"
      PORT="$2"
      shift 2
      ;;
    --env-file|--env)
      (($# >= 2)) || die "--env-file 需要文件路径"
      ENV_FILE="$2"
      [[ "$ENV_FILE" = /* ]] || ENV_FILE="${APP_ROOT}/${ENV_FILE}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "未知选项：$1（使用 --help 查看用法）"
      ;;
  esac
done

cd "$APP_ROOT"
[[ -f package.json ]] || die "未找到 package.json：${APP_ROOT}"
[[ -f package-lock.json ]] || die "未找到 package-lock.json"
[[ -f prisma/schema.prisma ]] || die "未找到 prisma/schema.prisma"
[[ -f "$ENV_FILE" ]] || die "未找到环境文件：${ENV_FILE}"
[[ "$PORT" =~ ^[0-9]{1,5}$ ]] || die "端口必须是 1–65535 的整数"
PORT=$((10#$PORT))
((PORT >= 1 && PORT <= 65535)) || die "端口必须是 1–65535 的整数"
command -v node >/dev/null 2>&1 || die "未找到 Node.js"
command -v npm >/dev/null 2>&1 || die "未找到 npm"

if [[ -f "$PID_FILE" ]]; then
  PID="$(<"$PID_FILE")"
  if [[ "$PID" =~ ^[0-9]+$ ]] && kill -0 "$PID" 2>/dev/null; then
    die "开发服务器已经运行（PID ${PID}），请先运行 npm run stop 或 bash scripts/stop.sh"
  fi
  rm -f -- "$PID_FILE"
fi

# Prisma and Next.js both read this dotenv file. Exporting it also makes the
# selected database explicit for db:push and the background process.
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

printf '\n==> 安装锁定版本依赖\n'
npm ci

printf '\n==> 生成 Prisma Client\n'
npm run db:generate

printf '\n==> 同步开发数据库 Schema\n'
npm run db:push

printf '\n==> 启动开发服务器（%s:%s）\n' "$HOST" "$PORT"
mkdir -p "$(dirname -- "$PID_FILE")" "$(dirname -- "$LOG_FILE")"
nohup setsid npm run dev -- --hostname "$HOST" --port "$PORT" >"$LOG_FILE" 2>&1 &
SERVER_PID=$!
printf '%s\n' "$SERVER_PID" > "$PID_FILE"

# Give the process a moment to fail fast on invalid configuration or a busy port.
sleep 1
if ! kill -0 "$SERVER_PID" 2>/dev/null; then
  rm -f -- "$PID_FILE"
  die "开发服务器启动失败，请查看日志：${LOG_FILE}"
fi

printf '开发服务器已启动：PID %s\n' "$SERVER_PID"
printf '访问地址：http://%s:%s\n' "$HOST" "$PORT"
printf '日志文件：%s\n' "$LOG_FILE"

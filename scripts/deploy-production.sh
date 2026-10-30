#!/usr/bin/env bash

# StarKids production deployment helper.
# By default this prepares the release and restarts the project's user systemd
# starkids.service when present; otherwise it starts `next start` in the
# foreground. Use --no-start for another supervisor or --restart-service to
# select a different user systemd service.

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${STAR_KIDS_ENV_FILE:-${APP_ROOT}/.env.local}"
BACKUP_DIR="${STAR_KIDS_BACKUP_DIR:-${APP_ROOT}/backups}"
START_SERVER=true
SKIP_INSTALL=false
RESTART_SERVICE=""
START_PORT=""

usage() {
  cat <<'USAGE'
用法：bash scripts/deploy-production.sh [选项]

执行生产部署：
  1. 检查 Node.js、.env.local 和生产环境变量
  2. 安装锁定版本依赖（npm ci）
  3. 备份 SQLite 数据库
  4. 生成 Prisma Client 并应用迁移
  5. 构建 Next.js 生产版本
  6. 自动重启当前项目的用户级 starkids.service；未检测到时前台启动

选项：
  --no-start       只完成部署准备，不启动应用（交给 systemd/PM2 等）
  --skip-install   跳过 npm ci（仅适合依赖已由外部流程安装的情况）
  --restart-service UNIT
                   部署后重启指定的用户级 systemd 服务，例如 starkids.service
  --port PORT      前台启动端口，默认 PORT 环境变量或 3000
  --env FILE       使用指定环境文件，默认 .env.local
  --backup-dir DIR 数据库备份目录，默认 ./backups
  -h, --help       显示帮助

环境变量：
  STAR_KIDS_ENV_FILE
  STAR_KIDS_BACKUP_DIR
USAGE
}

die() {
  printf '部署失败：%s\n' "$*" >&2
  exit 1
}

log() {
  printf '\n==> %s\n' "$*"
}

require_env_value() {
  local name="$1"
  local value
  value="${!name:-}"
  [[ -n "$value" ]] || die "${ENV_FILE} 缺少 ${name}"
  [[ "$value" != *"替换为"* ]] || die "${name} 仍是示例占位值"
  printf '%s' "$value"
}

database_file_from_url() {
  local database_url="$1"
  case "$database_url" in
    file:./*) printf '%s/%s' "$APP_ROOT" "${database_url#file:./}" ;;
    file:/*) printf '%s' "${database_url#file:}" ;;
    "") printf '%s/dev.db' "$APP_ROOT" ;;
    *) die "当前部署脚本只支持 SQLite DATABASE_URL（收到非 file: URL）" ;;
  esac
}

while (($# > 0)); do
  case "$1" in
    --no-start)
      START_SERVER=false
      shift
      ;;
    --skip-install)
      SKIP_INSTALL=true
      shift
      ;;
    --restart-service)
      (($# >= 2)) || die "--restart-service 需要服务名称"
      RESTART_SERVICE="$2"
      shift 2
      ;;
    --port)
      (($# >= 2)) || die "--port 需要端口号"
      START_PORT="$2"
      shift 2
      ;;
    --env)
      (($# >= 2)) || die "--env 需要文件路径"
      ENV_FILE="$2"
      [[ "$ENV_FILE" = /* ]] || ENV_FILE="${APP_ROOT}/${ENV_FILE}"
      shift 2
      ;;
    --backup-dir)
      (($# >= 2)) || die "--backup-dir 需要目录路径"
      BACKUP_DIR="$2"
      [[ "$BACKUP_DIR" = /* ]] || BACKUP_DIR="${APP_ROOT}/${BACKUP_DIR}"
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

if [[ -n "$RESTART_SERVICE" ]]; then
  [[ "$START_SERVER" == true ]] || die "--restart-service 不能与 --no-start 同时使用"
  [[ -z "$START_PORT" ]] || die "systemd 服务的端口由服务配置管理，不能同时使用 --port"
  [[ "$RESTART_SERVICE" =~ ^[a-zA-Z0-9_.@-]+\.service$ ]] || die "请提供有效的 systemd .service 名称"
fi

cd "$APP_ROOT"

[[ -f package.json ]] || die "未找到 package.json：${APP_ROOT}"
[[ -f package-lock.json ]] || die "未找到 package-lock.json，无法执行 npm ci"
[[ -f prisma/schema.prisma ]] || die "未找到 prisma/schema.prisma"
[[ -d prisma/migrations ]] || die "未找到 prisma/migrations"
[[ -f "$ENV_FILE" ]] || die "未找到环境文件：${ENV_FILE}"

# Keep the environment available to Prisma, Next.js, and the started process.
# The deployment environment file is operator-controlled and follows the usual
# shell-compatible dotenv syntax used by Next.js.
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

command -v node >/dev/null 2>&1 || die "未找到 Node.js"
command -v npm >/dev/null 2>&1 || die "未找到 npm"

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[[ "$NODE_MAJOR" =~ ^[0-9]+$ && "$NODE_MAJOR" -ge 22 ]] || die "需要 Node.js 22 或更高版本，当前为 $(node --version)"

# Only infer the service when no explicit startup mode was requested. A unit
# with the same name in another checkout must never be restarted implicitly.
if [[ "$START_SERVER" == true && -z "$RESTART_SERVICE" && -z "$START_PORT" ]] \
  && command -v systemctl >/dev/null 2>&1; then
  DETECTED_SERVICE_DIRECTORY="$(systemctl --user show starkids.service --property=WorkingDirectory --value 2>/dev/null || true)"
  if [[ -n "$DETECTED_SERVICE_DIRECTORY" && -d "$DETECTED_SERVICE_DIRECTORY" ]] \
    && [[ "$(cd -- "$DETECTED_SERVICE_DIRECTORY" && pwd -P)" == "$(pwd -P)" ]]; then
    RESTART_SERVICE="starkids.service"
    log "检测到当前项目的用户级 starkids.service，部署后将重启现有服务"
  fi
fi

START_PORT="${START_PORT:-${PORT:-3000}}"
[[ "$START_PORT" =~ ^[0-9]{1,5}$ ]] || die "端口必须是 1–65535 的整数"
START_PORT=$((10#$START_PORT))
((START_PORT >= 1 && START_PORT <= 65535)) || die "端口必须是 1–65535 的整数"

if [[ -n "$RESTART_SERVICE" ]]; then
  command -v systemctl >/dev/null 2>&1 || die "未找到 systemctl"
  SERVICE_DIRECTORY="$(systemctl --user show "$RESTART_SERVICE" --property=WorkingDirectory --value)"
  [[ -n "$SERVICE_DIRECTORY" && -d "$SERVICE_DIRECTORY" ]] || die "用户服务不存在或没有 WorkingDirectory：${RESTART_SERVICE}"
  [[ "$(cd -- "$SERVICE_DIRECTORY" && pwd -P)" == "$(pwd -P)" ]] || die "服务 ${RESTART_SERVICE} 的工作目录不是当前项目"
elif [[ "$START_SERVER" == true ]]; then
  # Probe before installing dependencies, migrating, or rebuilding a live app.
  node - "$START_PORT" <<'NODE' || exit 1
const net = require("node:net")
const port = Number(process.argv[2])
const server = net.createServer()
server.once("error", (error) => {
  if (error.code === "EADDRINUSE") {
    console.error(`部署失败：端口 ${port} 已被占用。`)
    console.error("若由用户级 systemd 管理：npm run deploy:production -- --restart-service starkids.service")
    console.error("由其他进程管理器管理时使用 --no-start；另开实例可使用 --port 3001。")
  } else {
    console.error(`部署失败：无法监听端口 ${port}（${error.code}）`)
  }
  process.exitCode = 1
})
server.listen(port, () => server.close())
NODE
fi

NEXT_PUBLIC_APP_URL_VALUE="$(require_env_value NEXT_PUBLIC_APP_URL)"
AUTH_URL_VALUE="$(require_env_value AUTH_URL)"
DATABASE_URL_VALUE="${DATABASE_URL:-}"
DATABASE_FILE="$(database_file_from_url "$DATABASE_URL_VALUE")"

export AUTH_URL="$AUTH_URL_VALUE"
export NEXT_PUBLIC_APP_URL="$NEXT_PUBLIC_APP_URL_VALUE"
if [[ -n "$DATABASE_URL_VALUE" ]]; then
  export DATABASE_URL="$DATABASE_URL_VALUE"
else
  unset DATABASE_URL
fi

case "$NEXT_PUBLIC_APP_URL_VALUE" in
  http://localhost:*|http://127.0.0.1:*|https://localhost:*|https://127.0.0.1:*)
    printf '警告：NEXT_PUBLIC_APP_URL 当前为本机地址：%s\n' "$NEXT_PUBLIC_APP_URL_VALUE" >&2
    ;;
esac

log "环境检查通过（${ENV_FILE}）"
printf '应用地址：%s\n认证地址：%s\n数据库：%s\n' \
  "$NEXT_PUBLIC_APP_URL_VALUE" "$AUTH_URL_VALUE" "$DATABASE_FILE"

if [[ "$SKIP_INSTALL" == false ]]; then
  log "安装锁定版本依赖"
  npm ci
else
  log "跳过 npm ci"
fi

if [[ ! -f "$DATABASE_FILE" ]]; then
  log "创建 SQLite 数据库文件"
  mkdir -p "$(dirname -- "$DATABASE_FILE")"
  touch "$DATABASE_FILE"
fi

log "备份 SQLite 数据库"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="${BACKUP_DIR}/starkids-$(date -u +%Y%m%d-%H%M%S).db"
cp -- "$DATABASE_FILE" "$BACKUP_FILE"
printf '备份已保存：%s\n' "$BACKUP_FILE"

log "生成 Prisma Client"
npm run db:generate

log "应用 Prisma 生产迁移"
DATABASE_URL="$DATABASE_URL_VALUE" npx prisma migrate deploy

log "构建 Next.js 生产版本"
npm run build

if [[ "$START_SERVER" == false ]]; then
  log "部署准备完成"
  printf '可使用以下命令启动：npm run start\n'
  exit 0
fi

if [[ -n "$RESTART_SERVICE" ]]; then
  log "重启用户级 systemd 服务：${RESTART_SERVICE}"
  systemctl --user restart "$RESTART_SERVICE"
  systemctl --user is-active --quiet "$RESTART_SERVICE" || die "服务启动失败，请查看 journalctl --user -u ${RESTART_SERVICE} -n 50"
  log "生产服务已重启"
  exit 0
fi

log "启动 Next.js 生产服务器（端口 ${START_PORT}）"
exec npm run start -- --port "$START_PORT"

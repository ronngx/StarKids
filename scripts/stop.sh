#!/usr/bin/env bash

# Stop this project's development server and matching user-level systemd service.

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
PID_FILE="${STAR_KIDS_PID_FILE:-${APP_ROOT}/.starkids-dev.pid}"
SERVICE_NAME="${STAR_KIDS_SERVICE:-starkids.service}"
STOP_DEV=true
STOP_PRODUCTION=true
FAILED=false

usage() {
  cat <<'USAGE'
用法：bash scripts/stop.sh [选项]

停止当前项目的服务：
  默认同时处理：
  - scripts/deploy-dev.sh 启动的开发服务器
  - 工作目录属于当前项目的用户级 systemd 生产服务

选项：
  --dev-only          只停止开发服务器
  --production-only   只停止生产 systemd 服务
  --service UNIT      指定生产 systemd 服务，默认 starkids.service
  -h, --help          显示帮助

环境变量：
  STAR_KIDS_PID_FILE  开发服务器 PID 文件路径
  STAR_KIDS_SERVICE   生产 systemd 服务名称
USAGE
}

while (($# > 0)); do
  case "$1" in
    --dev-only)
      STOP_DEV=true
      STOP_PRODUCTION=false
      shift
      ;;
    --production-only)
      STOP_DEV=false
      STOP_PRODUCTION=true
      shift
      ;;
    --service)
      (($# >= 2)) || { printf '%s\n' "--service 需要服务名称" >&2; exit 1; }
      SERVICE_NAME="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf '未知选项：%s（使用 --help 查看用法）\n' "$1" >&2
      exit 1
      ;;
  esac
done

if [[ ! "$SERVICE_NAME" =~ ^[a-zA-Z0-9_.@-]+\.service$ ]]; then
  printf '无效的 systemd 服务名称：%s\n' "$SERVICE_NAME" >&2
  exit 1
fi

stop_dev_server() {
  if [[ ! -f "$PID_FILE" ]]; then
    printf '%s\n' "开发服务器未运行（没有 PID 文件）"
    return 0
  fi

  local pid command_line process_cwd
  pid="$(<"$PID_FILE")"
  if [[ ! "$pid" =~ ^[0-9]+$ || "$pid" -le 1 ]]; then
    rm -f -- "$PID_FILE"
    printf '%s\n' "已清理无效的开发服务器 PID 文件"
    return 0
  fi

  if ! kill -0 "$pid" 2>/dev/null; then
    rm -f -- "$PID_FILE"
    printf '%s\n' "开发服务器已经停止"
    return 0
  fi

  # Only stop a process whose command line and working directory belong to
  # this project's dev server. A stale PID must never kill another process.
  command_line="$(tr '\0' ' ' < "/proc/${pid}/cmdline" 2>/dev/null || true)"
  process_cwd="$(readlink "/proc/${pid}/cwd" 2>/dev/null || true)"
  if [[ "$process_cwd" != "$APP_ROOT" ]] || [[ "$command_line" != *"npm run dev"* && "$command_line" != *"next dev"* ]]; then
    printf 'PID %s 不是当前项目的开发服务器，已保留 PID 文件供人工检查\n' "$pid" >&2
    return 1
  fi

  printf '停止开发服务器（PID %s）\n' "$pid"
  # deploy-dev starts a dedicated session, so terminate the whole process group.
  kill -TERM -- "-${pid}" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true

  for _ in {1..30}; do
    if ! kill -0 "$pid" 2>/dev/null; then
      rm -f -- "$PID_FILE"
      printf '%s\n' "开发服务器已停止"
      return 0
    fi
    sleep 0.2
  done

  printf '%s\n' "开发服务器未在 6 秒内退出，强制停止"
  kill -KILL -- "-${pid}" 2>/dev/null || kill -KILL "$pid" 2>/dev/null || true
  rm -f -- "$PID_FILE"
}

stop_production_service() {
  if ! command -v systemctl >/dev/null 2>&1; then
    printf '%s\n' "未找到 systemctl，跳过生产 systemd 服务"
    return 0
  fi

  local service_directory project_directory
  service_directory="$(systemctl --user show "$SERVICE_NAME" --property=WorkingDirectory --value 2>/dev/null || true)"
  if [[ -z "$service_directory" || ! -d "$service_directory" ]]; then
    printf '未找到属于当前项目的用户级服务：%s\n' "$SERVICE_NAME"
    return 0
  fi

  project_directory="$(cd -- "$service_directory" && pwd -P)"
  if [[ "$project_directory" != "$APP_ROOT" ]]; then
    printf '跳过服务 %s：工作目录不是当前项目（%s）\n' "$SERVICE_NAME" "$service_directory"
    return 0
  fi

  if ! systemctl --user is-active --quiet "$SERVICE_NAME"; then
    printf '生产服务已经停止：%s\n' "$SERVICE_NAME"
    return 0
  fi

  printf '停止生产 systemd 服务：%s\n' "$SERVICE_NAME"
  if ! systemctl --user stop "$SERVICE_NAME"; then
    printf '停止生产服务失败：%s\n' "$SERVICE_NAME" >&2
    return 1
  fi

  if systemctl --user is-active --quiet "$SERVICE_NAME"; then
    printf '生产服务停止后仍处于 active 状态：%s\n' "$SERVICE_NAME" >&2
    return 1
  fi
  printf '生产服务已停止：%s\n' "$SERVICE_NAME"
}

if [[ "$STOP_DEV" == true ]]; then
  stop_dev_server || FAILED=true
fi

if [[ "$STOP_PRODUCTION" == true ]]; then
  stop_production_service || FAILED=true
fi

if [[ "$FAILED" == true ]]; then
  exit 1
fi

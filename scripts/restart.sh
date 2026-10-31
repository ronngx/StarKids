#!/usr/bin/env bash

# Restart the development server managed by deploy-dev.sh.

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Restart is the development workflow; leave a separately managed production
# systemd service running.
"${SCRIPT_DIR}/stop.sh" --dev-only || true
exec "${SCRIPT_DIR}/deploy-dev.sh" "$@"

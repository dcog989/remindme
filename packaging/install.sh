#!/usr/bin/env bash
#
# Build and install remindme, then restart KRunner so it picks up the runner.
#
#   packaging/install.sh            # install into ~/.local (no sudo)
#   packaging/install.sh --system   # install into /usr (uses sudo)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

preset="user"
sudo=""
for arg in "$@"; do
    case "$arg" in
        --system)
            preset="system"
            sudo="sudo"
            ;;
        --user)
            preset="user"
            sudo=""
            ;;
        -h|--help)
            sed -n '3,9p' "$0"
            exit 0
            ;;
        *)
            echo "unknown option: $arg" >&2
            exit 2
            ;;
    esac
done

cmake --preset "$preset"
cmake --build --preset "$preset"
# shellcheck disable=SC2086
$sudo cmake --install "build/$preset"

echo "==> Installed ($preset). Restarting KRunner"
if command -v kquitapp6 >/dev/null 2>&1; then
    kquitapp6 krunner >/dev/null 2>&1 || true
fi
if command -v krunner >/dev/null 2>&1; then
    krunner >/dev/null 2>&1 &
fi
echo "Try: rme 5  |  rme list  |  rme cancel 3"

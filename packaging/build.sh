#!/usr/bin/env bash
#
# Configure and build a preset. Usage: packaging/build.sh [user|release|system|asan]
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

preset="${1:-user}"
cmake --preset "$preset"
cmake --build --preset "$preset"
echo "==> Built '$preset' in build/$preset"

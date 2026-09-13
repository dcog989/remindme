#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 David Laws
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Configure and build a preset. Usage: packaging/build.sh [user|release|system|asan]
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

preset="${1:-user}"
cmake --preset "$preset"
cmake --build --preset "$preset"
echo "==> Built '$preset' in build/$preset"

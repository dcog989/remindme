#!/usr/bin/env bash
#
# Build the KRunner "Get New Plugins" payload. Run from any directory; output lands in dist/.
#
# The archive is a git-archive snapshot of the tracked sources with the top-level
# krunner-plugininstallerrc that KRunner's krunner-plugininstaller reads to install the runner.
# It ships sources, so the recipient builds the plugin on first activation via
# packaging/kns/krunner-remindme-launcher.sh.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

version="$(git describe --tags --abbrev=0 2>/dev/null || true)"
version="${version#v}"
if [ -z "$version" ]; then
    version="$(sed -n 's/^project(remindme VERSION \([0-9.]*\).*/\1/p' CMakeLists.txt)"
fi
name="remindme-$version"
out="dist/$name.tar.gz"

if ! git ls-files --error-unmatch krunner-plugininstallerrc >/dev/null 2>&1; then
    echo "krunner-plugininstallerrc is not committed; commit it before packaging" >&2
    exit 1
fi

mkdir -p dist
git archive --format=tar.gz --prefix="$name/" -o "$out" HEAD
echo "==> $out"

#!/usr/bin/env bash
#
# Build the KDE Store source archive. Run from any directory; output lands in dist/.
# The archive contains the tracked sources plus packaging/install.sh and packaging/uninstall.sh,
# so recipients compile it locally (a terminal build, since the plugin is C++).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

version="$(git describe --tags --abbrev=0 2>/dev/null || echo 0.1.0)"
version="${version#v}"
name="remindme-$version"
out="dist/$name.tar.gz"

mkdir -p dist
git archive --format=tar.gz --prefix="$name/" -o "$out" HEAD
echo "==> $out"

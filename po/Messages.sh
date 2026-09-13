#! /usr/bin/env bash
# SPDX-FileCopyrightText: 2026 David Laws
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Extracts translatable strings. KDE's build system defines $XGETTEXT and $podir.
$XGETTEXT "$(dirname "$0")"/../src/engine/*.cpp "$(dirname "$0")"/../src/runner/*.cpp -o "$podir/krunner_remindme.pot"

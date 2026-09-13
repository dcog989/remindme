#! /usr/bin/env bash
#
# Extracts translatable strings. KDE's build system defines $XGETTEXT and $podir.
$XGETTEXT "$(dirname "$0")"/../src/engine/*.cpp "$(dirname "$0")"/../src/runner/*.cpp -o "$podir/krunner_remindme.pot"

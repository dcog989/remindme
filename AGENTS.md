# Agent Directives

## Project Specifics

- Name: remindme
- Description: A third-party (user) KRunner plugin for KDE Plasma 6. Adds a timer function: type a trigger word followed by a duration (and optional message) to start a countdown; when time is up, a dedicated alarm window pops up with Snooze (+1 min) and Dismiss. Active timers can be listed and cancelled from KRunner, and they survive KRunner restarts.
- Goal: a **standalone, third-party user plugin** distributed through the [KDE Store](https://store.kde.org/) and installable via KRunner's **Get New Plugins** flow; not part of KDE Plasma.
- Status: migrating from an in-tree plasma-workspace plugin (`plasma-workspace/runners/remindme/`, kept locally as the gitignored extraction source) into this standalone repository.
- Tech: C++20, Qt 6.9+, KDE Frameworks 6, CMake 3.29+, Extra CMake Modules (ECM)
- License: **GPL-3.0-or-later** for all C++/build sources; CC0-1.0 for data files (`.json` metadata, `.notifyrc`, D-Bus XML) where marked. Per-file SPDX headers are authoritative. Relicensing from the old LGPL-2.0-or-later headers is part of the migration.

### File Access

- Repo root: `/home/bubba/Projects/remindme`
- Legacy extraction source (read-only, gitignored): `plasma-workspace/runners/remindme/`
- Scratch: `/tmp/*`
- Read-only: `.env*`, `.git/`

### Target Layout

```text
remindme/
├── CMakeLists.txt                       # top-level project (ECM, KF6, options, subdirs)
├── src/
│   ├── common/                          # shared by both targets → remindme_common
│   │   ├── remindmedbus.{h,cpp}         # D-Bus marshalling for Remindme::TimerInfo
│   │   ├── remindmetime.{h,cpp}         # duration parser
│   │   └── org.kde.remindme.xml         # D-Bus interface
│   ├── runner/                          # KRunner plugin (remindme.so)
│   │   ├── remindmerunner.{h,cpp}       # AbstractRunner
│   │   ├── remindmeclient.{h,cpp}
│   │   └── plasma-runner-remindme.json  # embedded KPlugin metadata
│   └── helper/                          # krunner-remindme D-Bus helper
│       ├── remindmeengine.{h,cpp}       # timer engine
│       ├── remindmehelpermain.cpp       # helper entry point
│       ├── remindmealarmdialog.{h,cpp}  # Snooze/Dismiss window
│       ├── remindmeautostart.{h,cpp}    # session autostart toggling
│       └── krunner-remindme.notifyrc
├── autotests/                           # ctest: remindmetimetest, remindmeenginetest, remindmeautostarttest, remindmeintegrationtest
├── po/                                  # translations (Messages.sh + catalogs)
├── packaging/                           # build.sh / install.sh / package.sh / org.kde.remindme.service.in
├── LICENSES/                            # REUSE license texts
├── REUSE.toml
└── README.md
```

### Workflow

- Task runner: `just` (see `justfile`; `just` lists recipes). Never hand-roll configure/build commands when a recipe exists.
- Configure/build/test: `just ci` (runs `cmake --workflow --preset user`). Individual steps: `just configure`, `just build`, `just test`.
- Presets live in `CMakePresets.json`: `user` (`~/.local`, Debug), `release`, `system`, `asan`. `CMAKE_EXPORT_COMPILE_COMMANDS` is on.
- Install: `just install` (or `cmake --install build/<preset>`).
- Format: `just format` (clang-format + shfmt); verify with `just format-check` — `KDEClangFormat` must not regenerate the committed `.clang-format`.
- Lint: `just lint`; missing tools are skipped. `just doctor` reports gaps.
- Static analysis: `just tidy` (clang-tidy, config in `.clang-tidy`).
- Git hooks: `lefthook.yml`; install once with `lefthook install`. Pre-commit formats/lints, `commit-msg` runs `cog verify`, pre-push builds and tests.
- Releases: `cog bump --auto` (`cog.toml`) updates `CHANGELOG.md`, bumps the version and tags `v*`.
- CI: `.github/workflows/ci.yml` (Arch container: build + test + lint).

### Rules

- The code is standalone: do **not** modify anything under `plasma-workspace/` — it is a read-only extraction source. Port code into `src/` instead.
- Keep the component split in Target Layout: `common/` is shared by both targets; never duplicate shared sources into `runner/` or `helper/`.
- Tooling is committed at the repo root (`CMakePresets.json`, `justfile`, `lefthook.yml`, `cog.toml`, `.clang-format`, `.clang-tidy`, `.yamllint`, `.ecrc`). Keep it working when targets or file types change; don't add a second task runner or hook manager.
- Commit messages follow Conventional Commits (`cog verify`). Do not bypass hooks (`--no-verify`).
- Follow KRunner/KF6 plugin conventions: SPDX headers, `#pragma once`, `KRunner::AbstractRunner`, `KPluginFactory`/`KPluginMetaData`, `QStringLiteral`, `i18n()`.
- Use ECM install-dir variables (`KDE_INSTALL_*`) rather than hardcoded paths, so user- and system-prefix installs both work.
- Emulate existing test procedures: pure-logic unit tests, and D-Bus/plugin integration tests via a real subprocess (`krunner_configure_test` + `AbstractRunnerTest`). Don't invent new patterns where an existing one fits.
- Run targeted tests, not the full `ctest` suite, on trivial changes.
- Require confirmation for: adding/removing dependencies, and any operation outside the project root.

---

## General Guidelines

### Code Changes

- For non-trivial work, propose an approach and confirm before implementing.
- Keep modifications minimal and scoped; prefer incremental improvements over rewrites. Ask before architectural changes.
- Use explicit types and named constants (no magic numbers).
- Return explicit error types; do not suppress exceptions.
- Decompose files over 400 lines if they mix concerns.
- Use clear naming over comments; reserve comments for complex workarounds or non-obvious issues — why, not what.
- Never run git mutations (commit, push, reset, rebase, amend) unless explicitly instructed.
- Do not create documentation files unless explicitly requested.
- Do not delete files or make destructive changes without confirmation.

### Verification

- Do not run test, lint, format, or type-check commands; the user builds, tests, and lints manually.
- Run them only when the user explicitly asks.

### Author Environment

- CachyOS, KDE Plasma 6, Wayland, Btrfs.
- fish shell, Ghostty terminal, Fresh TUI editor, yay package manager, bun npm manager, Firefox, and Zed code editor.

### Testing

- Only add tests for genuinely unit-testable logic worth guarding; skip trivial changes and untestable behavior (e.g. UI layout/click mapping).

### Definition of Done

- Logic fully implemented.
- Existing docs updated if public interfaces changed.
- On completion, print a concise conventional commit message in a fenced code block.
- All source headers carry the correct SPDX license (`GPL-3.0-or-later`).
- Affected tests pass.
- New/modified features have tests.

### Communication Style

- Provide concise, actionable responses.
- Ask clarifying questions when requirements are ambiguous.
- Flag potential risks or edge cases proactively.
- Be direct: no empathy claims, hedging, disclaimers, or meta-commentary.

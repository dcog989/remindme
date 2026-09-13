# Agent Directives

## Project Specifics

- Name: remindme
- Description: A third-party (user) KRunner plugin for KDE Plasma 6. Adds a timer function: type a trigger word followed by a duration (and optional message) to start a countdown; when time is up, a dedicated alarm window pops up with Snooze (+1 min) and Dismiss. Active timers can be listed and cancelled from KRunner, and they survive KRunner restarts.
- Goal: a **standalone, third-party user plugin** distributed through the [KDE Store](https://store.kde.org/) and installable via KRunner's **Get New Plugins** flow.
- Status: migrating from an in-tree plasma-workspace plugin (`plasma-workspace/runners/remindme/`, kept locally as the gitignored extraction source) into this standalone repository.
- Tech: C++20, Qt 6.9+, KDE Frameworks 6, CMake 3.29+, Extra CMake Modules (ECM)
- License: **GPL-3.0-or-later** for all C++/build sources; CC0-1.0 for data files (`.json` metadata, `.notifyrc`, D-Bus XML) where marked. Per-file SPDX headers are authoritative. Relicensing from the old LGPL-2.0-or-later headers is part of the migration.

### File Access

- Repo root: `/home/bubba/Projects/remindme`
- Legacy extraction source (read-only reference, gitignored): `plasma-workspace/runners/remindme/`
- Working references: `.docs/`, `AGENTS.md`
- `/tmp/*`
- Read-Only: `.env*`, `.git/`.

### Target Layout

```text
remindme/
├── CMakeLists.txt              # top-level project (ECM, KF6, options, subdirs)
├── src/
│   ├── common/                 # shared by runner + helper → remindme_common
│   │   ├── remindmedbus.{h,cpp}
│   │   ├── remindmetime.{h,cpp}
│   │   └── org.kde.remindme.xml
│   ├── runner/                 # KRunner plugin target (remindme.so)
│   │   ├── remindmerunner.{h,cpp}
│   │   ├── remindmeclient.{h,cpp}
│   │   └── plasma-runner-remindme.json
│   └── helper/                 # krunner-remindme D-Bus helper executable
│       ├── remindmeengine.{h,cpp}
│       ├── remindmehelpermain.cpp
│       ├── remindmealarmdialog.{h,cpp}
│       ├── remindmeautostart.{h,cpp}
│       └── krunner-remindme.notifyrc
├── autotests/                  # ctest suite
├── po/                         # translations (Messages.sh + catalogs)
├── packaging/                  # build.sh / install.sh / org.kde.remindme.service.in
├── LICENSES/                   # REUSE license texts
├── REUSE.toml
└── README.md
```

Component boundaries: `common/` holds code shared by both build targets; `runner/` is what KRunner loads; `helper/` is the D-Bus-activated engine process. Keep this split — don't duplicate shared sources into the targets.

### Key Files

- `src/common/remindmetime.{h,cpp}` — duration parser.
- `src/common/remindmedbus.{h,cpp}` + `src/common/org.kde.remindme.xml` — D-Bus marshalling for `Remindme::TimerInfo` and the D-Bus interface.
- `src/runner/remindmerunner.{h,cpp}` + `src/runner/plasma-runner-remindme.json` — KRunner `AbstractRunner` plugin and its embedded metadata.
- `src/helper/remindmeengine.{h,cpp}`, `src/helper/remindmehelpermain.cpp` — timer engine and helper entry point.
- `src/helper/remindmealarmdialog.{h,cpp}` — alarm window (Snooze/Dismiss).
- `src/helper/remindmeautostart.{h,cpp}` — session autostart toggling while timers are pending.
- `autotests/` — `remindmetimetest`, `remindmeenginetest`, `remindmeautostarttest`, `remindmeintegrationtest`.

### Workflow

- Task runner: `just` (see `justfile`; `just` lists recipes). Never hand-roll configure/build commands when a recipe exists.
- Configure/build/test: `just ci` (runs `cmake --workflow --preset user`). Individual steps: `just configure`, `just build`, `just test`.
- Presets live in `CMakePresets.json`: `user` (`~/.local`, Debug), `release`, `system`, `asan`. `CMAKE_EXPORT_COMPILE_COMMANDS` is on.
- Install: `just install` (or `cmake --install build/<preset>`).
- Format: `just format` (clang-format + shfmt); verify with `just format-check` — do not rely on `KDEClangFormat` regenerating `.clang-format` (a committed one now exists).
- Lint: `just lint`; missing tools are skipped. `just doctor` reports gaps.
- Static analysis: `just tidy` (clang-tidy, config in `.clang-tidy`).
- Git hooks: managed by `lefthook.yml`; install once with `lefthook install`. Pre-commit formats/lints, `commit-msg` runs `cog verify`, pre-push builds and tests.
- Releases: `cog bump --auto` (config in `cog.toml`) updates `CHANGELOG.md`, bumps the version and tags `v*`.
- CI: `.github/workflows/ci.yml` (Arch container: build + lint). Also keep REUSE and XML lint clean.

### Rules

- The code is now standalone: do **not** modify anything under `plasma-workspace/` — that tree is a read-only extraction source. Port code into `src/` instead.
- Tooling is committed at the repo root (`CMakePresets.json`, `justfile`, `lefthook.yml`, `cog.toml`, `.clang-format`, `.clang-tidy`, `.yamllint`, `.ecrc`). Keep it working when targets or file types change; don't add a second task runner or hook manager.
- Commit messages follow Conventional Commits (`cog verify`). Do not use `git commit --no-verify` or otherwise bypass the hooks.
- Follow KRunner/KF6 plugin conventions: SPDX headers, `#pragma once`, `KRunner::AbstractRunner`, `KPluginFactory`/`KPluginMetaData`, `QStringLiteral`, `i18n()`.
- Use ECM install-dir variables (`KDE_INSTALL_*`) rather than hardcoded paths, so user- and system-prefix installs both work.
- Emulate existing test procedures: pure-logic unit tests, and D-Bus/plugin integration tests via a real subprocess (`krunner_configure_test` + `AbstractRunnerTest`). Do not invent new patterns where an existing one fits.
- Do not run the full `ctest` suite on trivial changes; run targeted tests only.
- Require confirmation: adding/removing dependencies, any operation outside project root.

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

- Do not create test files for trivial changes, or for behavior that is not reliably unit-testable in the test environment (e.g. UI layout/click mapping). Prefer no new files; only add a test when the logic is genuinely testable and worth guarding.

### Definition of Done

- Logic fully implemented.
- Existing docs updated if public interfaces changed.
- When required by the `Verification` rules, run the corresponding `Workflow` command.
- On completion of an update or fix, print a concise conventional commit message in a fenced code block.
- All source headers carry the correct SPDX license (`GPL-3.0-or-later`).
- Affected tests pass.
- New/modified features have tests.

### Communication Style

- Provide concise, actionable responses.
- Ask clarifying questions when requirements are ambiguous.
- Flag potential risks or edge cases proactively.
- Do not pretend to understand how the user feels.
- Never editorialise your answer. No "to be honest", "honestly", hedging, disclaimers, or meta-commentary — just answer.

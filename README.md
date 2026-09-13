# remindme

A third-party (user) [KRunner](https://userbase.kde.org/Plasma/Krunner) plugin for
KDE Plasma 6 that adds timers. Type a trigger word (`remindme` or `rme`) followed
by a duration and an optional message to start a countdown. When the time is up a
dedicated alarm window pops up with **Snooze (+1 min)** and **Dismiss**. Active
timers can be listed and cancelled from KRunner, and they survive KRunner
restarts.

`remindme` is distributed through the [KDE Store](https://store.kde.org/) and is
installable from KRunner's **Get New Plugins** flow. It is **not** part of KDE
Plasma and is **not** shipped by the Plasma release; the plugin lives entirely in
this standalone repository.

## Usage

Trigger words: `remindme`, `rme` (case-insensitive).

| Input         | Meaning                                  |
| ------------- | ---------------------------------------- |
| `5`           | 5 minutes                                |
| `5.5`         | 5 minutes 30 seconds                     |
| `.5`          | 0.5 minutes = 30 seconds                 |
| `0:20`        | 20 seconds                               |
| `20s`         | 20 seconds                               |
| `4h`          | 4 hours                                  |
| `5:30`        | 5 minutes 30 seconds                     |
| `4:15:30`     | 4 hours 15 minutes 30 seconds            |
| `8 message`   | 8 minutes with the message `message`     |

- A bare number means minutes. Fractional values (`.5`, `.5m`, `.5h`, …) are
  accepted for bare numbers and unit forms, rounded to whole seconds.
- `0` (or any non-positive) duration is invalid; the maximum is `99:59:59`.
- The message is everything after the duration and may contain spaces.

| Action                  | Query                 |
| ----------------------- | --------------------- |
| Create timer            | `rme 5`, `rme 8 msg`  |
| List active timers      | `rme list`            |
| Cancel by id            | `rme cancel 3`        |
| Cancel by message       | `rme cancel meeting`  |
| List timers to cancel   | `rme cancel`          |
| Usage / help            | `rme`                 |

- Pressing Enter on a create match starts the timer. `rme list` shows each active
  timer with its `#id` and reminder time; activating a timer pops up its alarm,
  while its `✕` action cancels it. `rme cancel` with no target lists every timer
  so one can be picked and cancelled.
- "Cancel by message" matches the message *exactly* (case-sensitive), so a short
  typo cannot cancel a large set of timers. Use `rme cancel <id>` or
  `rme cancel #<id>` for a specific timer.
- On expiry the helper opens an alarm window with the message plus Snooze and
  Dismiss, and plays the looping alarm sound until the window is closed.
- Timers survive KRunner restarts and session logout: the engine runs in a D-Bus
  helper process, persists timers to disk, and uses wall-clock deadlines (epoch),
  so suspend and restart are handled naturally.

## Install

### From the KDE Store

1. Open **System Settings → Search → Plasma Search**.
2. Click **Get New Plugins…**.
3. Search for **Remind me** and install it.
4. Restart KRunner: `kquitapp6 krunner && krunner &` (or log out and back in).

### From source

Build dependencies: a C++20 compiler, CMake 3.29+, Qt 6.9+, and KDE Frameworks 6
(`Runner`, `CoreAddons`, `I18n`, `Notifications`, `ConfigCore`), plus
[Extra CMake Modules](https://invent.kde.org/frameworks/extra-cmake-modules).

The build is driven by [CMake presets](CMakePresets.json), with a thin
[`justfile`](justfile) for convenience. If you have
[`just`](https://github.com/casey/just) installed:

```sh
just configure          # cmake --preset user
just build              # cmake --build --preset user
just install            # install into ~/.local
```

Without `just`:

```sh
cmake --preset user
cmake --build --preset user
cmake --install build/user
```

Presets: `user` (`~/.local`, Debug), `release`, `system` (`/usr`),
`asan` (ASan + UBSan). Configure, build and test in one go with
`just ci <preset>` or `cmake --workflow --preset user`.

The packaging helpers wrap the same steps and print launch instructions:

```sh
packaging/build.sh
packaging/install.sh
```

`-DKDE_INSTALL_USE_QT_SYS_PATHS=OFF` keeps the plugin under the chosen prefix
(e.g. `~/.local/lib/plugins/kf6/krunner/`). Installing into a user prefix means
KRunner must be told where the plugin lives:

```sh
kquitapp6 krunner
QT_PLUGIN_PATH="$HOME/.local/lib/plugins" krunner &
```

Installing system-wide (with a system prefix, or `KDE_INSTALL_USE_QT_SYS_PATHS=ON`)
avoids the `QT_PLUGIN_PATH` requirement, since KRunner then finds the plugin in
the standard Qt plugin directory.

## Tech Stack

- C++20, Qt 6.9+, KDE Frameworks 6, CMake 3.29+, Extra CMake Modules.
- `RemindmeRunner` is a standard KRunner C++ plugin loaded via
  `KPluginMetaData`/`KPluginFactory`.
- The timer engine runs in a separate D-Bus-activated helper process
  (`krunner-remindme`) so timers keep ticking with KRunner closed.

## Project Layout

```text
remindme/
├── CMakeLists.txt              # top-level project (ECM, KF6, options, subdirs)
├── src/
│   ├── common/                 # shared by runner + helper → remindme_common
│   │   ├── remindmedbus.{h,cpp}        # D-Bus marshalling for TimerInfo
│   │   ├── remindmetime.{h,cpp}        # duration parser
│   │   └── org.kde.remindme.xml        # D-Bus interface definition
│   ├── runner/                 # KRunner plugin (remindme.so)
│   │   ├── remindmerunner.{h,cpp}
│   │   ├── remindmeclient.{h,cpp}
│   │   └── plasma-runner-remindme.json # embedded KPlugin metadata
│   └── helper/                 # krunner-remindme D-Bus helper executable
│       ├── remindmeengine.{h,cpp}
│       ├── remindmehelpermain.cpp
│       ├── remindmealarmdialog.{h,cpp}
│       ├── remindmeautostart.{h,cpp}
│       └── krunner-remindme.notifyrc
├── autotests/                  # ctest suite
├── po/                         # translations (Messages.sh + catalogs)
├── packaging/                  # build.sh / install.sh / D-Bus service template
├── LICENSES/                   # REUSE license texts
├── REUSE.toml
└── README.md
```

## Development

- Configure, build and test: `just ci` (or `cmake --workflow --preset user`).
- Test only: `just test` (or `ctest --preset user`).
- Format C++ and shell sources: `just format`; verify with `just format-check`.
- Lint everything available: `just lint` (REUSE, typos, shellcheck, yamllint,
  editorconfig-checker, clang-format). `just doctor` lists missing tools.
- Static analysis: `just tidy` (`clang-tidy` over the configured build).
- Rebuild, reinstall and relaunch KRunner: `just reload`.
- Package for the KDE Store: `just package`.

### Git hooks

Hooks are managed with [lefthook](https://lefthook.dev/) and installed once per
clone:

```sh
lefthook install
```

Pre-commit formats C++ and shell files (re-staging the result) and runs the
available linters; `commit-msg` enforces
[Conventional Commits](https://www.conventionalcommits.org/) via
[cocogitto](https://docs.cocogitto.io/) (`cog verify`); pre-push builds and tests.
Hooks for tools that are not installed are skipped, so a partial toolchain still
works.

Releases use the same convention: `cog bump --auto` updates `CHANGELOG.md`,
bumps the version and creates a `v*` tag.

Handy Arch packages:

```sh
paru -S just lefthook cocogitto reuse typos shellcheck shfmt yamllint \
        gitleaks editorconfig-checker clang
```

## License

GPL-3.0-or-later. Data files (plugin metadata, notification config, D-Bus
interface XML) are CC0-1.0 where marked; per-file SPDX headers are authoritative.

## Links

- Inspiration: <https://store.kde.org/p/1081014/>
- KRunner plugin development: <https://develop.kde.org/docs/plasma/krunner/>
- Discussion: <https://discuss.kde.org/t/is-there-a-krunner-timer/49132>

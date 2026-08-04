# Agent Directives

## Project Context

- Name: <project-name>
- Description: <brief core goals and functionality>
- Tech: <languages, frameworks, databases, core tools>

## Key Files

- `<path>` — entry point
- `<path>` — state
- `<path>` — tests

## Development Workflow

- <install>
- <dev>
- <test>
- <lint>
- <format>
- <build>

## Dev Environment

- CachyOS, Limine bootloader, KDE Plasma 6, Wayland, and Btrfs.
- fish shell, Ghostty terminal, Fresh TUI editor, yay package manager, bun npm manager, Firefox, and Zed code editor.

## File System Access

- Root: `<project root>`
- Allowed: All subdirectories, `/tmp/<project-name>`
- Read-Only: `.env*`, `.git/`
- Disallowed: system dirs, user config, other projects
- Require confirmation: adding/removing dependencies, changes outside `src/`, any operation outside project root

## Rules

- Keep modifications minimal and scoped. Ask before architectural changes.
- Do not delete files or make destructive changes without confirmation.
- Do not create documentation files unless explicitly requested.
- Prefer incremental improvements over rewrites.
- Use explicit types and named constants (no magic numbers).
- Return explicit error types; do not suppress exceptions.
- Follow standard repository linting and formatting configs (Biome, rustfmt, .editorconfig).
- Decompose files over 400 lines if they mix concerns.
- Never run git mutations (commit, push, reset, rebase, amend) unless explicitly asked.
- Self-documenting code via clear naming. Use comments only for complex workarounds or issues that need noting.
- Do not run full `bun run check`/`bun run test` on trivial changes (constant tweaks, one-line edits, CSS value changes). Run `bunx biome check --write <file>` on the touched file, or nothing if the change is a simple value edit. Only run the full suite on real logic changes.

## Communication Style

- Provide concise, actionable responses.
- Ask clarifying questions when requirements are ambiguous.
- Flag potential risks or edge cases proactively.
- Do not pretend to understand how the user feels.
- On completion of an update or fix, provide a singe line, concise commit message in a code block so the user can copy it easily.

## Definition of Done

- Logic fully implemented.
- `<test>` and `<lint>` pass with zero errors.
- New/modified features have tests.
- Existing docs updated if public interfaces changed.

# AGENTS.md

Conventions of nxgt-flutter, a Flutter package monorepo (pub workspace + Melos 8).
The owner's global rules (worktrees, commits, merges, sessions) are in
`~/.claude/CLAUDE.md`; this file is what is specific to this repository.

## Layout

```
packages/nxgt_material/   the component package (publishable)
apps/widgetbook/          Widgetbook catalogue (not published; GitHub Pages)
bricks/                   Mason bricks: package, component
tool/                     Dart scripts used by Melos scripts
.github/workflows/        ci.yml, release.yml, pages.yml
```

Root `pubspec.yaml` holds the `workspace:` list and the `melos:` config. Each
member has `resolution: workspace`; there is a single root `pubspec.lock`.

## Toolchain

- Flutter is pinned by FVM in `.fvmrc` (3.47.8, Dart 3.13.7). CI reads the same
  file. Bump it in one PR, with the lockfile.
- Lints: `very_good_analysis`, included from the root `analysis_options.yaml`.
  Analysis is run with `--fatal-infos`; fix an info, do not ignore it.
- Commands: `dart run melos run analyze | format | test | coverage | goldens | goldens:update | gen`.
  Heavy ones run with `nice -n 10`, one at a time.

## Component rules (`nxgt_material`)

- **No `nxgt` prefix.** A component is named for its intent: `StatCard`,
  `EmailField`, `ConfirmDialog`.
- **Never redefine an M3 widget name.** Flutter's Material 3 widgets are the
  base: no `Button`, `Card` or `TextField` wrapper under the same name. Check
  Material 3 first; add only what it lacks, under an intent name.
- **One Dart library per category** (`actions`, `collections`, `dates`,
  `display`, `feedback`, `fields`, `forms`, `layout`, `media`, `overlays`,
  `selection`, `theme`), exporting from `lib/src/<category>/`, plus the barrel
  `nxgt_material.dart`.
- **A new component is made with the Mason brick**, never by hand:
  `mason make component --name StatCard --category display` from the root. It
  writes the widget, the Widgetbook use-case, an Alchemist golden test, a
  widget + semantics test and the docs page; then add the export line it
  prints and run `melos run gen`. A new package: `mason make package`.
- Theme: `ColorScheme.fromSeed` plus `ThemeExtension`s (tones, radius, motifs),
  same presets and names as `@nxgt/material` `defineTheme`.
- Icons: Material Symbols. Forms: Flutter `Form`/`FormField`, no form library.
- i18n: `gen-l10n`, fr and en, inside `nxgt_material`.
- Six platforms: Android, iOS, web, macOS, Windows, Linux.

## Tests

- Every component has widget tests and semantics tests (labels, roles, 48 dp
  targets, state). Coverage must stay at or above 80 % per package.
- Alchemist goldens: only the CI variant is generated (platform goldens are
  disabled in `test/flutter_test_config.dart`), tagged `golden`, compared on
  Linux in CI. Regenerate on Linux (`melos run goldens:update`); never commit
  goldens made elsewhere.
- Goldens are regenerated on Linux through the `goldens-update` workflow
  (`gh workflow run goldens-update.yml -f ref=<branch>`), available once it is
  merged into `develop`. It refuses `develop` and `main`. Its push is made with
  `GITHUB_TOKEN` and does not trigger CI, so re-run CI on the branch afterwards.
- Browser or full-platform builds are not run in CI beyond the Pages web build.

## Git

- Conventional Commits (`type(scope): description`); the scope is the package
  (`feat(nxgt_material): …`). `melos version` reads them to bump independent
  versions and write changelogs.
- PRs target `develop`. `main` is fast-forwarded to `develop` after a merge,
  never written to otherwise. An effort with several slices uses an integration
  branch `feat/<slug>` (see the global rules).
- One worktree per piece of work, under `~/workspace/worktrees/nxgt-flutter/`.

## Releases

- Tag `<package>-v<version>` triggers `release.yml` (pub.dev OIDC, GitHub
  environment `pub-dev`).
- **The first publish of a package is manual, by the owner**: pub.dev needs the
  package to exist before automated publishing can be enabled. After that, the
  owner enables automated publishing on pub.dev (repository, tag pattern
  `{{package}}-v{{version}}`, environment `pub-dev`).

## Docs

README per package (the pub.dev page) and `docs/` (guides, `components/`,
troubleshooting, roadmap). Document a component in the same change that adds it.

# nxgt-flutter

Flutter packages by softistx, in one [pub workspace](https://dart.dev/tools/pub/workspaces)
managed with [Melos](https://melos.invertase.dev). Published on pub.dev.

## Packages

| Package | What it is |
| --- | --- |
| [`nxgt_material`](packages/nxgt_material) | Material 3 components Flutter does not ship: adaptive layout, fields and forms, feedback states, themes. Same catalogue as `@nxgt/material` (React). |

Other directories:

- [`apps/widgetbook`](apps/widgetbook): the Widgetbook catalogue of the
  components, published to GitHub Pages from `develop`.
- [`bricks/`](bricks): local [Mason](https://github.com/felangel/mason) bricks
  (`package`, `component`).
- `tool/`: small Dart scripts used by the Melos scripts.

## Set up

1. Install [FVM](https://fvm.app) and the pinned Flutter (`.fvmrc`):

   ```sh
   fvm install
   fvm use   # links .fvm/flutter_sdk
   ```

2. Resolve the workspace (one `pubspec.lock` at the root):

   ```sh
   fvm dart pub get
   fvm dart run melos bootstrap
   ```

   Put `fvm`'s Dart on your `PATH` (or prefix commands with `fvm`) so
   `dart run melos` uses the pinned SDK.

3. For the bricks: `dart pub global activate mason_cli 0.1.4`, then `mason get`.

## Scripts

Run with `dart run melos run <name>` (or `melos run <name>` with Melos
activated globally).

| Script | What it does |
| --- | --- |
| `analyze` | `flutter analyze --fatal-infos` in every package |
| `format` | checks formatting, writes nothing (`dart format .` fixes it) |
| `test` | `flutter test --coverage` in the Flutter packages only, goldens excluded |
| `test:dart` | `dart test` in the pure Dart packages (no Flutter SDK) |
| `coverage` | fails when a package's line coverage is under 80 % (skipped while a package has no code) |
| `goldens` | Alchemist golden tests |
| `goldens:update` | regenerates goldens; run on Linux so CI matches |
| `gen` | `build_runner`, then `flutter gen-l10n`, where a package uses them |

Release: `melos version` (conventional commits, independent versions) tags
`<package>-v<version>`; the tag triggers `release.yml`, which publishes to
pub.dev over OIDC. The first publish of a package is done by hand.

See [AGENTS.md](AGENTS.md) for the conventions.

## License

MIT, see [LICENSE](LICENSE).

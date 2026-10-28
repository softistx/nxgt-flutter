# CLAUDE.md

**Read [AGENTS.md](AGENTS.md) first**: layout, commands, component rules and
conventions. The notes below are Claude Code specific.

- The machine is shared (16 GiB laptop, several sessions). Prefix heavy
  commands (`melos run test`, `goldens`, `flutter build`, `build_runner`) with
  `nice -n 10`, run one at a time, and check `uptime` first. Test only the
  package you changed (`melos exec --scope=<pkg> -- flutter test <file>`).
- Use `fvm dart` / `fvm flutter`, or put `~/fvm/versions/3.47.8/bin` on `PATH`;
  never the system Flutter.
- Redirect long output to a file and read its tail; never trust a piped exit
  code.
- Do not run `flutter build ios|macos|windows|linux|apk`. `flutter build web`
  of `apps/widgetbook` only when load allows.
- New component: the `component` Mason brick, not hand-written files.

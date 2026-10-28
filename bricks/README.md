# Bricks

Local [Mason](https://github.com/felangel/mason) bricks, registered in the
root `mason.yaml`. Run them from the repository root.

```sh
dart pub global activate mason_cli 0.1.4
mason get
mason make package --name nxgt_http --description "HTTP client on dio"
mason make component --name StatCard --category display
```

- `package`: a new publishable workspace package (add it to the root
  `workspace:` list afterwards).
- `component`: widget, Widgetbook use-case, Alchemist golden test, widget and
  semantics test, and doc page for a `nxgt_material` component. The hook
  prints the two steps left (the export line, `melos run gen`); the category's
  library `lib/<category>.dart` does not exist until its first component, so
  create it then and export it from the barrel.

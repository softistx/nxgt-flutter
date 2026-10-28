# ResponsiveGrid

Library: `package:nxgt_material/layout.dart`

Tiles in as many columns as fit tiles at least `minItemWidth` wide, sharing the
width equally. The columns follow the width the grid is given, like
`ResponsiveGrid` of `@nxgt/material`.

## When to use it

For a board of cards, stats or shortcuts that should gain columns on a wide
window instead of stretching. It sizes to its content, so it sits in a scroll
view. For a long list built lazily use `GridView` with
`SliverGridDelegateWithMaxCrossAxisExtent`.

## Example

```dart
SingleChildScrollView(
  child: ResponsiveGrid(
    minItemWidth: 200,
    spacing: 12,
    children: [for (final s in stats) StatTile(s)],
  ),
)
```

## Limits

It follows the width it is *given*, not the window: in a horizontal scroll view
or an unconstrained `Row` it has no width to follow and lays out one tile
width per child; give it a bounded width. Inside an `IntrinsicWidth` or a
`Table` it fails, see [troubleshooting](../troubleshooting.md).

## Accessibility

It adds no semantics: each tile keeps its own label, role and 48 dp target,
and reading order is the order of `children`.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `children` | `List<Widget>` | The tiles. |
| `minItemWidth` | `double` | The narrowest a tile gets. Defaults to 224 (14 rem). |
| `spacing` | `double` | Space between tiles, both ways. Defaults to 8. |

# PageBody

Library: `package:nxgt_material/layout.dart`

The content of a screen, centred, no wider than `maxWidth`, with side gutters
that grow with the window: 16 dp on compact, 24 on medium and expanded, 32 on
large and extraLarge.

## When to use it

Around the content of every screen, instead of a hand-made `Padding` and
`ConstrainedBox`, so margins agree and a form does not stretch across a wide
monitor. It does not scroll; put it in a scroll view or give it a scrollable
child.

## Example

```dart
Scaffold(
  body: SingleChildScrollView(
    child: PageBody(child: InvoiceForm()),
  ),
)

PageBody(maxWidth: 720, gutter: 20, child: Article())
```

## Accessibility

It adds no semantics. Gutters mirror in right-to-left locales.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `child` | `Widget` | The page content. |
| `maxWidth` | `double` | The widest the content gets, gutters included. Defaults to 1200. |
| `gutter` | `double?` | The side gutter; defaults to the one of the window's `WindowSize`. |
| `PageBody.gutterFor(size)` | `double` | The default gutter of a window size. |

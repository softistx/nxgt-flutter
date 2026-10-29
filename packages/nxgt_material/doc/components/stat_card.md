# StatCard

Library: `package:nxgt_material/display.dart`

A key figure in a card: a label, its value and how it moved, on a Material 3
`Card`.

## When to use it

A dashboard tile: revenue, open tickets, response time. The `delta` is a pill
tinted by the `trend` (success up, error down, neutral flat); with
`positiveIsUp: false`, for a cost or a delay, a rise is error and a fall is
success. For a row in a list use `ListTile`; for a status word use
[StatusIndicator](status_indicator.md).

## Example

```dart
StatCard(
  label: 'Revenue',
  value: '1 200',
  delta: '4 %',
  trend: StatTrend.up,
  icon: Icons.payments_outlined,
)

// A cost: a rise is bad. Tappable.
StatCard(
  label: 'Costs',
  value: '340',
  delta: '2 %',
  trend: StatTrend.up,
  positiveIsUp: false,
  onTap: openCosts,
)
```

`value` and `delta` are strings you format (number, currency, locale).

## Accessibility

One merged node: "Revenue, 1 200, up 4 %" ("Revenue, 1 200, en hausse 4 %" in
French). The trend is drawn as an icon and spoken as a word (`displayTrendUp`,
`displayTrendDown`, `displayTrendFlat`, rewordable through
`NxgtMaterialLocalizationsWrapper`), so colour is never the only signal; the
pill colours are AA-solved tone colours. The `icon` is decorative and hidden
from screen readers.

Without `onTap` the card is not focusable. With it the whole card is a button
(semantics `button`, tap action) of at least 48 dp, with the `InkWell` focus,
hover and ripple. Padding and the label row follow the text direction.

## Properties

| Name | Type | Description |
| --- | --- | --- |
| `label` | `String` | What the figure measures. |
| `value` | `String` | The figure, already formatted. |
| `delta` | `String?` | The change, already formatted, in a pill. |
| `trend` | `StatTrend?` | `up`, `down` or `flat`: icon, spoken word and tone. |
| `positiveIsUp` | `bool` | Whether a rise is good (default `true`); swaps success and error. |
| `icon` | `IconData?` | A decorative icon at the end of the label row. |
| `onTap` | `VoidCallback?` | Makes the card a button. |

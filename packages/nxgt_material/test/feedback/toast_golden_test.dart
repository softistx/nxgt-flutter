import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:nxgt_material/feedback.dart';
import 'package:nxgt_material/theme.dart';

class _Shown extends StatefulWidget {
  const new(this.tone);

  final FeedbackTone? tone;

  @override
  State<_Shown> createState() => _ShownState();
}

class _ShownState extends State<_Shown> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.showToast(
        'Changes saved',
        tone: widget.tone,
        actionLabel: 'Undo',
        onAction: () {},
        duration: const Duration(days: 1),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

Future<void> main() async {
  await goldenTest(
    'Toast looks right in every tone, light and dark',
    fileName: 'toast',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final brightness in Brightness.values)
          for (final tone in [null, ...FeedbackTone.values])
            GoldenTestScenario(
              name: '${brightness.name} ${tone?.name ?? 'plain'}',
              child: Theme(
                data: brightness == Brightness.light
                    ? ThemePresets.ocean.light()
                    : ThemePresets.ocean.dark(),
                child: SizedBox(
                  width: 360,
                  height: 110,
                  child: ScaffoldMessenger(child: Scaffold(body: _Shown(tone))),
                ),
              ),
            ),
      ],
    ),
  );
}

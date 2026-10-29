import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/display.dart';

import 'package:nxgt_material/theme.dart';

import '../support/host.dart';

class _FailingImage extends ImageProvider<_FailingImage> {
  @override
  Future<_FailingImage> obtainKey(ImageConfiguration configuration) =>
      Future.value(this);

  @override
  ImageStreamCompleter loadImage(
    _FailingImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(
    Future<ImageInfo>.error(Exception('cannot load')),
  );
}

/// Exact palette picks of the FNV-1a hash; the web test pins the same ones.
const pinnedTones = [
  ('Ada Lovelace', 'tertiary'),
  ('eve  adams', 'secondary'),
  ('Chloé Durand', 'success'),
];

Color _fill(WidgetTester tester) =>
    tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundColor!;

void main() {
  testWidgets('UserAvatar shows the first and last initials', (tester) async {
    await tester.pumpApp(
      themedHost(const UserAvatar(name: 'ada king lovelace')),
    );

    expect(find.text('AL'), findsOneWidget);
  });

  testWidgets('UserAvatar shows one initial for a single word', (tester) async {
    await tester.pumpApp(themedHost(const UserAvatar(name: ' grace ')));

    expect(find.text('G'), findsOneWidget);
  });

  testWidgets('UserAvatar gives the same name the same tone', (tester) async {
    await tester.pumpApp(themedHost(const UserAvatar(name: 'Ada Lovelace')));
    final first = _fill(tester);
    await tester.pumpApp(themedHost(const UserAvatar(name: 'ada  lovelace ')));

    expect(_fill(tester), first);
  });

  testWidgets('UserAvatar spreads names over several tones', (tester) async {
    final fills = <Color>{};
    for (final name in ['Ada', 'Bob', 'Chloe', 'Dan', 'Eve', 'Farid', 'Gus']) {
      await tester.pumpApp(themedHost(UserAvatar(name: name)));
      fills.add(_fill(tester));
    }

    expect(fills.length, greaterThan(2));
  });

  testWidgets('UserAvatar text meets AA contrast on its fill', (tester) async {
    for (final brightness in Brightness.values) {
      for (final name in ['Ada', 'Bob', 'Chloe', 'Dan', 'Eve', 'Farid']) {
        await tester.pumpApp(
          themedHost(UserAvatar(name: name), brightness: brightness),
        );
        final text = tester.widget<Text>(find.byType(Text));
        final ratio = _contrast(text.style!.color!, _fill(tester));
        expect(ratio, greaterThanOrEqualTo(4.5), reason: '$name $brightness');
      }
    }
  });

  testWidgets('UserAvatar falls back to the initials when the image fails', (
    tester,
  ) async {
    await tester.pumpApp(
      themedHost(UserAvatar(name: 'Ada Lovelace', image: _FailingImage())),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('AL'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('UserAvatar draws the image once it loaded', (tester) async {
    final image = await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      ui.Canvas(
        recorder,
      ).drawRect(const Rect.fromLTWH(0, 0, 4, 4), Paint()..color = Colors.red);
      final picture = recorder.endRecording();
      final decoded = await picture.toImage(4, 4);
      final data = await decoded.toByteData(format: ui.ImageByteFormat.png);
      return MemoryImage(data!.buffer.asUint8List());
    });
    await tester.pumpApp(
      themedHost(UserAvatar(name: 'Ada Lovelace', image: image)),
    );
    await tester.runAsync(() => precacheImageFor(tester, image!));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('UserAvatar draws a person icon for an empty name', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(themedHost(const UserAvatar(name: '  ')));

    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byType(Text), findsNothing);
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('UserAvatar speaks the name and hides the image', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      themedHost(UserAvatar(name: 'Ada Lovelace', image: _FailingImage())),
    );

    expect(find.bySemanticsLabel('Ada Lovelace'), findsOneWidget);
    expect(find.bySemanticsLabel('AL'), findsNothing);
    handle.dispose();
  });

  for (final (presence, en, fr) in [
    (AvatarPresence.online, 'Online', 'En ligne'),
    (AvatarPresence.away, 'Away', 'Absent'),
    (AvatarPresence.busy, 'Busy', 'Occupé'),
    (AvatarPresence.offline, 'Offline', 'Hors ligne'),
  ]) {
    testWidgets('UserAvatar speaks ${presence.name} in English and French', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        themedHost(UserAvatar(name: 'Ada', presence: presence)),
      );
      expect(find.bySemanticsLabel('Ada, $en'), findsOneWidget);

      await tester.pumpApp(
        themedHost(
          UserAvatar(name: 'Ada', presence: presence),
          locale: const Locale('fr'),
        ),
      );
      expect(find.bySemanticsLabel('Ada, $fr'), findsOneWidget);
      handle.dispose();
    });
  }

  testWidgets('UserAvatar speaks only the name without presence', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(themedHost(const UserAvatar(name: 'Ada')));

    expect(find.bySemanticsLabel('Ada'), findsOneWidget);
    expect(find.byType(PositionedDirectional), findsNothing);
    expect(find.byType(Positioned), findsOneWidget);
    await tester.pumpApp(
      themedHost(const UserAvatar(name: 'Ada', presence: AvatarPresence.busy)),
    );
    expect(find.byType(Positioned), findsNWidgets(2));
    handle.dispose();
  });

  testWidgets('UserAvatar speaks only the presence for an empty name', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      themedHost(const UserAvatar(name: '', presence: AvatarPresence.online)),
    );

    expect(find.bySemanticsLabel('Online'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('UserAvatar has no label for an empty name and no presence', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(themedHost(const UserAvatar(name: '')));

    final node = tester.getSemantics(find.byType(UserAvatar));
    expect(node.label, isEmpty);
    handle.dispose();
  });

  testWidgets('UserAvatar person icon meets AA contrast on the neutral tone', (
    tester,
  ) async {
    for (final brightness in Brightness.values) {
      await tester.pumpApp(
        themedHost(const UserAvatar(name: ''), brightness: brightness),
      );
      final icon = tester.widget<Icon>(find.byIcon(Icons.person));
      expect(
        _fill(tester),
        tester.element(find.byType(UserAvatar)).tones.neutral.container,
      );
      expect(_contrast(icon.color!, _fill(tester)), greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('UserAvatar sizes the presence dot between 8 and 16', (
    tester,
  ) async {
    Future<double> dot(double size) async {
      await tester.pumpApp(
        themedHost(
          Center(
            child: UserAvatar(
              name: 'Ada',
              size: size,
              presence: AvatarPresence.online,
            ),
          ),
        ),
      );
      return tester
          .getSize(
            find.descendant(
              of: find.byType(PositionedDirectional),
              matching: find.byType(SizedBox),
            ),
          )
          .width;
    }

    expect(await dot(20), 8);
    expect(await dot(40), closeTo(12, 0.001));
    expect(await dot(100), 16);
  });

  testWidgets('UserAvatar puts the presence dot at the end in RTL', (
    tester,
  ) async {
    Future<double> dotX(TextDirection direction) async {
      await tester.pumpApp(
        themedHost(
          Directionality(
            textDirection: direction,
            child: const Center(
              child: UserAvatar(name: 'Ada', presence: AvatarPresence.online),
            ),
          ),
        ),
      );
      final avatar = tester.getCenter(find.byType(CircleAvatar)).dx;
      final dot = tester
          .getCenter(
            find.descendant(
              of: find.byType(PositionedDirectional),
              matching: find.byType(SizedBox),
            ),
          )
          .dx;
      return dot - avatar;
    }

    expect(await dotX(TextDirection.ltr), greaterThan(0));
    expect(await dotX(TextDirection.rtl), lessThan(0));
  });

  testWidgets('UserAvatar pins the tone picked for fixed names', (
    tester,
  ) async {
    for (final (name, tone) in pinnedTones) {
      await tester.pumpApp(themedHost(UserAvatar(name: name)));
      final tones = tester.element(find.byType(UserAvatar)).tones;
      expect(_fill(tester), tones[tone]!.container, reason: name);
    }
  });

  testWidgets('UserAvatar honours size', (tester) async {
    await tester.pumpApp(themedHost(const UserAvatar(name: 'Ada', size: 64)));

    expect(tester.getSize(find.byType(UserAvatar)), const Size.square(64));
  });

  test('UserAvatar asserts a non-positive size', () {
    expect(
      () => UserAvatar(name: 'Ada', size: 0),
      throwsA(
        isA<AssertionError>().having(
          (e) => e.message,
          'message',
          'UserAvatar.size must be positive.',
        ),
      ),
    );
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

Future<void> precacheImageFor(WidgetTester tester, ImageProvider image) async {
  final stream = image.resolve(ImageConfiguration.empty);
  final done = Completer<void>();
  late ImageStreamListener listener;
  listener = ImageStreamListener((_, _) {
    done.complete();
    stream.removeListener(listener);
  });
  stream.addListener(listener);
  await done.future;
}

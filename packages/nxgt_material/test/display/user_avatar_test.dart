import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/display.dart';

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

  testWidgets('UserAvatar has no presence dot by default', (tester) async {
    await tester.pumpApp(themedHost(const UserAvatar(name: 'Ada')));

    expect(find.byType(Positioned), findsOneWidget);
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

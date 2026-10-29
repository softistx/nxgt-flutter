import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/fields.dart';
import 'package:nxgt_material/src/l10n/generated/nxgt_material_localizations_en.dart';
import 'package:nxgt_material/src/l10n/generated/nxgt_material_localizations_fr.dart';

import '../support/host.dart';

/// Builds [Validators] for [locale] the way an app does, from a context.
Future<Validators> validatorsFor(WidgetTester tester, String locale) async {
  late Validators found;
  await tester.pumpWidget(
    formHost([
      Builder(
        builder: (context) {
          found = Validators.of(context);
          return const SizedBox();
        },
      ),
    ], locale: Locale(locale)),
  );
  await tester.pumpAndSettle();
  return found;
}

void main() {
  group('en', () {
    late Validators v;
    setUp(() => v = Validators(NxgtMaterialLocalizationsEn()));

    test('required rejects null and blank', () {
      expect(v.required()(null), 'This field is required');
      expect(v.required()('   '), 'This field is required');
      expect(v.required()('a'), isNull);
    });

    test('url', () {
      for (final ok in [
        'example.com',
        'https://example.com',
        'http://sub.example.co.uk/path?q=1#frag',
        'https://example.com:8080/a',
        'HTTP://Example.COM',
        '  example.com  ',
        '',
        '   ',
      ]) {
        expect(v.url()(ok), isNull, reason: ok);
      }
      expect(v.url()(null), isNull);
      for (final bad in [
        'ftp://x.com',
        'localhost',
        'http://',
        'https://localhost',
        'not a url',
        'example',
        'example..com',
        '-a.com',
        'http://exa mple.com',
        'mailto:a@b.co',
      ]) {
        expect(v.url()(bad), 'Enter a valid web address', reason: bad);
      }
      expect(v.compose([v.required(), v.url()])(''), 'This field is required');
    });

    test('email', () {
      for (final ok in ['a@b.co', 'first.last+tag@sub.example.org']) {
        expect(v.email()(ok), isNull, reason: ok);
      }
      for (final bad in [
        'a',
        'a@b',
        '@b.co',
        'a b@c.de',
        'a@b..co',
        'a@-b.co',
      ]) {
        expect(v.email()(bad), 'Enter a valid email address', reason: bad);
      }
      expect(v.email()(''), isNull);
      expect(v.email()(null), isNull);
      expect(v.email()('  a@b.co '), isNull);
    });

    test('minLength', () {
      expect(v.minLength(3)('ab'), 'Enter at least 3 characters');
      expect(v.minLength(1)('a'), isNull);
      expect(v.minLength(3)('abc'), isNull);
      expect(v.minLength(3)(''), isNull);
      expect(v.minLength(3)(null), isNull);
    });

    test('maxLength', () {
      expect(v.maxLength(2)('abc'), 'Enter at most 2 characters');
      expect(v.maxLength(1)('ab'), 'Enter at most 1 character');
      expect(v.maxLength(2)('ab'), isNull);
      expect(v.maxLength(2)(null), isNull);
    });

    test('phone', () {
      for (final ok in ['0612345678', '+33 6 12 34 56 78', '(555) 123-4567']) {
        expect(v.phone()(ok), isNull, reason: ok);
      }
      for (final bad in [
        '123',
        'abcdefghij',
        '06+12345678',
        '1234567890123456',
      ]) {
        expect(v.phone()(bad), 'Enter a valid phone number', reason: bad);
      }
      expect(v.phone()(''), isNull);
    });

    test('number', () {
      expect(v.number()('12'), isNull);
      expect(v.number()('-1,5'), isNull);
      expect(v.number()(''), isNull);
      expect(v.number()('abc'), 'Enter a valid number');
      expect(v.number()('NaN'), 'Enter a valid number');
      expect(v.number(min: 1)('0'), 'Enter a value of at least 1');
      expect(v.number(max: 1.5)('2'), 'Enter a value of at most 1.5');
      expect(v.number(min: 1, max: 3)('2'), isNull);
    });

    test('NumberField.parse is strict', () {
      expect(NumberField.parse('0x1A'), isNull);
      expect(NumberField.parse('1e3'), isNull);
      expect(NumberField.parse('1,234'), 1.234);
      expect(NumberField.parse('1,234.5'), isNull);
      expect(NumberField.parse('.5'), 0.5);
      expect(NumberField.parse(',5'), 0.5);
      expect(NumberField.parse('-2'), -2);
      expect(NumberField.parse('1.'), isNull);
      expect(NumberField.parse('--1'), isNull);
      expect(v.number()('0x1A'), 'Enter a valid number');
      expect(v.number()('1e3'), 'Enter a valid number');
    });

    test('NumberField.parse reads a comma and rejects the rest', () {
      expect(NumberField.parse('2,5'), 2.5);
      expect(NumberField.parse(' 7 '), 7);
      expect(NumberField.parse(''), isNull);
      expect(NumberField.parse(null), isNull);
      expect(NumberField.parse('1e999'), isNull);
    });

    test('compose returns the first message and skips nulls', () {
      final composed = v.compose([
        null,
        v.required(),
        v.email(),
        v.minLength(20),
      ]);

      expect(composed(''), 'This field is required');
      expect(composed('nope'), 'Enter a valid email address');
      expect(composed('a@b.co'), 'Enter at least 20 characters');
      expect(composed('a-very-long-address@example.org'), isNull);
      expect(v.compose(const [])('anything'), isNull);
    });
  });

  group('table-driven edge cases', () {
    final v = Validators(NxgtMaterialLocalizationsEn());

    final emails = {
      'a@b': false,
      'a@b.c': true,
      'a b@c.de': false,
      'a@b c.de': false,
      ' a@b.co ': true,
      'a@b.co ': true,
    };
    for (final MapEntry(key: input, value: valid) in emails.entries) {
      test('email "$input" is ${valid ? 'valid' : 'invalid'}', () {
        expect(v.email()(input), valid ? isNull : isNotNull);
      });
    }

    final phones = {
      '123456': false,
      '1234567': true,
      '123456789012345': true,
      '1234567890123456': false,
    };
    for (final MapEntry(key: input, value: valid) in phones.entries) {
      test(
        'phone with ${input.length} digits is ${valid ? 'valid' : 'invalid'}',
        () {
          expect(v.phone()(input), valid ? isNull : isNotNull);
        },
      );
    }

    final validators = <String, FormFieldValidator<String>>{
      'email': v.email(),
      'minLength': v.minLength(3),
      'maxLength': v.maxLength(3),
      'phone': v.phone(),
      'number': v.number(min: 1, max: 2),
    };
    for (final MapEntry(key: name, value: validator) in validators.entries) {
      test('$name accepts an empty value', () {
        expect(validator(''), isNull);
        expect(validator(null), isNull);
      });
    }

    test('only required rejects an empty value', () {
      expect(v.required()(''), isNotNull);
    });

    test('the length messages use the plural form', () {
      expect(v.l10n.fieldsMinLength(1), 'Enter at least 1 character');
      expect(v.l10n.fieldsMinLength(2), 'Enter at least 2 characters');
      expect(v.l10n.fieldsMaxLength(1), 'Enter at most 1 character');
      expect(v.l10n.fieldsMaxLength(10), 'Enter at most 10 characters');
    });

    test('compose runs in order and skips null validators', () {
      final calls = <String>[];
      FormFieldValidator<String> spy(String name, String? result) => (_) {
        calls.add(name);
        return result;
      };
      final composed = v.compose([
        spy('a', null),
        null,
        spy('b', 'second'),
        spy('c', 'third'),
      ]);

      expect(composed('x'), 'second');
      expect(calls, ['a', 'b']);
    });
  });

  group('fr', () {
    late Validators v;
    setUp(() => v = Validators(NxgtMaterialLocalizationsFr()));

    test('messages are in French', () {
      expect(v.required()(''), 'Ce champ est obligatoire');
      expect(v.email()('x'), 'Saisissez une adresse e-mail valide');
      expect(v.minLength(1)(''), isNull);
      expect(v.minLength(3)('a'), 'Saisissez au moins 3 caractères');
      expect(v.maxLength(1)('ab'), 'Saisissez au plus 1 caractère');
      expect(v.phone()('12'), 'Saisissez un numéro de téléphone valide');
      expect(v.number()('x'), 'Saisissez un nombre valide');
      expect(v.number(min: 1.5)('1'), 'Saisissez une valeur d’au moins 1,5');
      expect(
        v.number(max: 1000)('2000'),
        matches(RegExp(r'^Saisissez une valeur d’au plus 1\s000$')),
      );
    });
  });

  testWidgets('Validators.of follows the locale above the context', (
    tester,
  ) async {
    expect(
      (await validatorsFor(tester, 'en')).required()(''),
      'This field is required',
    );
    expect(
      (await validatorsFor(tester, 'fr')).required()(''),
      'Ce champ est obligatoire',
    );
  });

  testWidgets('Validators.of falls back to English without the delegate', (
    tester,
  ) async {
    late Validators found;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            found = Validators.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(found.required()(''), 'This field is required');
  });
}

{{#flutter}}import 'package:flutter_test/flutter_test.dart';
{{/flutter}}// The import is the test: the library must compile.
// ignore: unused_import
import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}.dart';
{{^flutter}}import 'package:test/test.dart';
{{/flutter}}
void main() {
  test('the library compiles', () {
    expect(true, isTrue);
  });
}

{{#flutter}}import 'package:flutter_test/flutter_test.dart';
{{/flutter}}{{^flutter}}import 'package:test/test.dart';
{{/flutter}}
// The export is the test: the library must compile. An export (rather than an
// import) sorts after every import, so `directives_ordering` holds whatever
// the package name is.
export 'package:{{name.snakeCase()}}/{{name.snakeCase()}}.dart';

void main() {
  test('the library compiles', () {
    expect(true, isTrue);
  });
}

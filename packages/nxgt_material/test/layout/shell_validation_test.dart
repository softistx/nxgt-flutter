import 'package:flutter_test/flutter_test.dart';
import 'package:nxgt_material/src/layout/shell_validation.dart';

void main() {
  test('shellIndex keeps a valid index and clamps the others', () {
    expect(shellIndex(1, 3), 1);
    expect(shellIndex(7, 3), 2);
    expect(shellIndex(-2, 3), 0);
    expect(shellIndex(5, 0), 0);
  });

  test('shellHasNavigation needs two destinations', () {
    expect(shellHasNavigation(0), isFalse);
    expect(shellHasNavigation(1), isFalse);
    expect(shellHasNavigation(2), isTrue);
  });
}

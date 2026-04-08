import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepts local development email domains', () {
      expect(Validators.email('parent01@ranch.local'), isNull);
    });

    test('accepts regular production email domains', () {
      expect(Validators.email('parent@example.com'), isNull);
    });

    test('rejects malformed email values', () {
      expect(Validators.email('parent01'), 'Noto\'g\'ri email');
    });
  });
}

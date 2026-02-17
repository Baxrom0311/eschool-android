import 'package:flutter_test/flutter_test.dart';

import 'package:parent_school_app/main.dart';

void main() {
  test('ParentSchoolApp smoke test', () {
    const app = ParentSchoolApp();
    expect(app, isNotNull);
  });
}

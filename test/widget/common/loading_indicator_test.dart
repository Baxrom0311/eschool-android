import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parent_school_app/presentation/widgets/common/loading_indicator.dart';

void main() {
  testWidgets('loading indicator renders message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LoadingIndicator(message: 'Yuklanmoqda')),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Yuklanmoqda'), findsOneWidget);
  });
}

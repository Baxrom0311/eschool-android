import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:parent_school_app/data/models/absence_model.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/presentation/providers/absence_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/absence/absence_excuse_screen.dart';

class MockAbsenceNotifier extends StateNotifier<AbsenceState>
    with Mock
    implements AbsenceNotifier {
  MockAbsenceNotifier(super.state);
}

void main() {
  late MockAbsenceNotifier mockAbsenceNotifier;

  const testChild = ChildModel(
    id: 1,
    fullName: 'Ali',
    className: '5-A',
    classId: 10,
  );

  setUp(() {
    mockAbsenceNotifier = MockAbsenceNotifier(
      const AbsenceState(
        excuses: [
          AbsenceExcuseModel(
            id: 1,
            dateFrom: '2026-04-05',
            dateTo: '2026-04-06',
            reason: 'Kasal bo\'ldi',
            status: 'pending',
          ),
        ],
      ),
    );
  });

  Widget createWidgetUnderTest() {
    when(() => mockAbsenceNotifier.loadExcuses(1)).thenAnswer((_) async {});

    return ProviderScope(
      overrides: [
        absenceProvider.overrideWith((ref) => mockAbsenceNotifier),
        selectedChildProvider.overrideWithValue(testChild),
      ],
      child: const MaterialApp(home: AbsenceExcuseScreen()),
    );
  }

  testWidgets('renders submitted excuses and action button', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('E-Murojaat (Davomat)'), findsOneWidget);
    expect(find.text('Kasal bo\'ldi'), findsOneWidget);
    expect(find.text('Murojaat qoldirish'), findsOneWidget);
    verify(() => mockAbsenceNotifier.loadExcuses(1)).called(1);
  });
}

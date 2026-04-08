import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/data/models/conference_model.dart';
import 'package:parent_school_app/presentation/providers/conference_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/conference/conference_screen.dart';

class MockConferenceNotifier extends StateNotifier<ConferenceState>
    with Mock
    implements ConferenceNotifier {
  MockConferenceNotifier(super.state);
}

void main() {
  late MockConferenceNotifier mockConferenceNotifier;

  const testChild = ChildModel(
    id: 1,
    fullName: 'Ali',
    className: '5-A',
    classId: 10,
  );

  setUp(() {
    mockConferenceNotifier = MockConferenceNotifier(
      const ConferenceState(
        bookings: [
          ConferenceModel(
            id: 1,
            slotId: 11,
            date: '2026-04-07',
            time: '09:00 - 09:20',
            teacherName: 'Matematika domla',
            status: 'booked',
            location: '101-xona',
          ),
        ],
        availableSlots: [
          ConferenceModel(
            id: 11,
            slotId: 11,
            date: '2026-04-08',
            time: '10:00 - 10:20',
            teacherName: 'Fizika domla',
            status: 'available',
          ),
        ],
      ),
    );
  });

  Widget createWidgetUnderTest() {
    when(() => mockConferenceNotifier.loadBookings(1)).thenAnswer((_) async {});

    return ProviderScope(
      overrides: [
        conferenceProvider.overrideWith((ref) => mockConferenceNotifier),
        selectedChildProvider.overrideWithValue(testChild),
      ],
      child: MaterialApp(
        locale: const Locale('uz'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const ConferenceScreen(),
      ),
    );
  }

  testWidgets('renders bookings and available slot count', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Ota-onalar majlisi'), findsOneWidget);
    expect(find.text('Matematika domla bilan uchrashuv'), findsOneWidget);
    expect(find.text('1 ta bo\'sh vaqt'), findsOneWidget);
    verify(() => mockConferenceNotifier.loadBookings(1)).called(1);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/core/storage/shared_prefs_service.dart';
import 'package:parent_school_app/data/models/assignment_model.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/data/repositories/academic_repository.dart';
import 'package:parent_school_app/data/repositories/user_repository.dart';
import 'package:parent_school_app/presentation/providers/academic_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/academics/assignments_screen.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockAcademicRepository extends Mock implements AcademicRepository {}

void main() {
  late MockUserRepository mockUserRepository;
  late MockAcademicRepository mockAcademicRepository;

  setUp(() async {
    mockUserRepository = MockUserRepository();
    mockAcademicRepository = MockAcademicRepository();

    SharedPreferences.setMockInitialValues({});
    await SharedPrefsService.init();

    const child = ChildModel(
      id: 1,
      fullName: 'Ali Valiyev',
      className: '5-A',
      classId: 10,
    );
    const user = UserModel(
      id: 1,
      fullName: 'Valiyev',
      phone: '+998901234567',
      children: [child],
    );

    when(
      () => mockUserRepository.getProfile(),
    ).thenAnswer((_) async => user);
  });

  Widget createWidgetUnderTest() {
    const child = ChildModel(
      id: 1,
      fullName: 'Ali Valiyev',
      className: '5-A',
      classId: 10,
    );

    return ProviderScope(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
        academicRepositoryProvider.overrideWithValue(mockAcademicRepository),
        selectedChildProvider.overrideWithValue(child),
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
        home: const AssignmentsScreen(),
      ),
    );
  }

  testWidgets('assignments screen renders localized filters and status', (
    tester,
  ) async {
    final assignments = [
      const AssignmentModel(
        id: 1,
        title: 'Matematika vazifasi',
        description: '1-10 misollar',
        subjectName: 'Matematika',
        teacherName: 'Domla',
        status: AssignmentStatus.pending,
        dueDate: '2026-04-10T00:00:00',
        createdAt: '2026-04-01T00:00:00',
      ),
    ];

    when(
      () => mockAcademicRepository.getAssignments(
        any(),
        status: any(named: 'status'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => assignments);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Vazifalar'), findsWidgets);
    expect(find.text('Yangi vazifalar'), findsOneWidget);
    expect(find.text('Barchasi'), findsOneWidget);
    expect(find.text('Matematika vazifasi'), findsOneWidget);
    expect(find.text('Kutilmoqda'), findsOneWidget);
    expect(find.text('Yuborish'), findsOneWidget);
  });
}

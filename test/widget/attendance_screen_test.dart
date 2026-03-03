import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parent_school_app/core/error/failures.dart';
import 'package:parent_school_app/core/storage/shared_prefs_service.dart';
import 'package:parent_school_app/data/models/attendance_model.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/data/repositories/academic_repository.dart';
import 'package:parent_school_app/data/repositories/user_repository.dart';
import 'package:parent_school_app/presentation/providers/academic_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/academics/attendance_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockAcademicRepository extends Mock implements AcademicRepository {}

void main() {
  late MockUserRepository mockUserRepository;
  late MockAcademicRepository mockAcademicRepository;

  setUpAll(() async {
    await initializeDateFormatting();
  });

  setUp(() async {
    mockUserRepository = MockUserRepository();
    mockAcademicRepository = MockAcademicRepository();

    SharedPreferences.setMockInitialValues({});
    await SharedPrefsService.init();
    
    // Default success mocks
    final tChild = const ChildModel(id: 1, fullName: 'John Jr', className: '5A', classId: 10);
    final tUser = UserModel(id: 1, fullName: 'John Doe', phone: '+998901234567', children: [tChild]);
    
    when(() => mockUserRepository.getProfile()).thenAnswer((_) async => Right(tUser));
  });

  Widget createWidgetUnderTest() {
    final tChild = const ChildModel(id: 1, fullName: 'John Jr', className: '5A', classId: 10);
    return ProviderScope(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
        academicRepositoryProvider.overrideWithValue(mockAcademicRepository),
        selectedChildProvider.overrideWithValue(tChild),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: AttendanceScreen(),
      ),
    );
  }

  group('AttendanceScreen Widget Tests', () {
    testWidgets('shows loading state initially', (WidgetTester tester) async {
      final completer = Completer<Either<Failure, List<AttendanceModel>>>();
      when(() => mockAcademicRepository.getAttendance(any(), month: any(named: 'month')))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty stats when data is empty', (WidgetTester tester) async {
      when(() => mockAcademicRepository.getAttendance(any(), month: any(named: 'month')))
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      expect(find.text('Jami darslar'), findsOneWidget);
      // Wait, there are 3 stats columns but they display '-' when summary is empty or 0
      expect(find.text('0'), findsNWidgets(3));
      // Ensure calendar is shown
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    testWidgets('shows populated stats and logic when data is available', (WidgetTester tester) async {
      // Create date today
      final today = DateTime.now();
      final dateStr = "\${today.year}-\${today.month.toString().padLeft(2, '0')}-\${today.day.toString().padLeft(2, '0')}T00:00:00.000000Z";
      
      final List<AttendanceModel> tRecords = [
        AttendanceModel(id: 1, date: dateStr, status: AttendanceStatus.present),
        AttendanceModel(id: 2, date: '2023-11-02T00:00:00.000000Z', status: AttendanceStatus.absent),
      ];

      when(() => mockAcademicRepository.getAttendance(any(), month: any(named: 'month')))
          .thenAnswer((_) async => Right(tRecords));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Jami darslar'), findsOneWidget);
      
      // Because length = 2, present = 1, absent = 1
      expect(find.text('2'), findsWidgets); // Jami darslar
      expect(find.text('1'), findsWidgets); // Qatnashdi or Sababsiz
      
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    testWidgets('shows error state when API fails', (WidgetTester tester) async {
      when(() => mockAcademicRepository.getAttendance(any(), month: any(named: 'month')))
          .thenAnswer((_) async => const Left(ServerFailure('Tarmoq xatosi')));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // UI uses error.toString(), so it will be "Exception: Tarmoq xatosi"
      expect(find.textContaining('Tarmoq xatosi'), findsOneWidget);
    });
  });
}

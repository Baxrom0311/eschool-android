import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parent_school_app/core/error/failures.dart';
import 'package:parent_school_app/core/storage/shared_prefs_service.dart';
import 'package:parent_school_app/data/models/attendance_model.dart';
import 'package:parent_school_app/data/models/child_model.dart';
import 'package:parent_school_app/data/models/grade_model.dart';
import 'package:parent_school_app/data/models/user_model.dart';
import 'package:parent_school_app/data/repositories/academic_repository.dart';
import 'package:parent_school_app/data/repositories/user_repository.dart';
import 'package:parent_school_app/presentation/providers/academic_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/screens/academics/grades_screen.dart';

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
    
    // Default success mocks
    final tChild = const ChildModel(id: 1, fullName: 'John Jr', className: '5A', classId: 10);
    final tUser = UserModel(id: 1, fullName: 'John Doe', phone: '+998901234567', children: [tChild]);
    
    when(() => mockUserRepository.getProfile()).thenAnswer((_) async => Right(tUser));
    
    when(() => mockAcademicRepository.getAttendance(any(), month: any(named: 'month'))).thenAnswer((_) async => const Right([]));
    when(() => mockAcademicRepository.getAttendance(any())).thenAnswer((_) async => const Right([]));
    
    when(() => mockAcademicRepository.getAttendanceSummary(any())).thenAnswer((_) async => const Right(AttendanceSummary(totalDays: 10, presentDays: 10, absentDays: 0, attendancePercentage: 100)));
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
        home: GradesScreen(),
      ),
    );
  }

  group('GradesScreen Widget Tests', () {
    testWidgets('shows loading state initially', (WidgetTester tester) async {
      final gradeCompleter = Completer<Either<Failure, List<GradeModel>>>();
      final summaryCompleter = Completer<Either<Failure, List<SubjectGradeSummary>>>();

      when(() => mockAcademicRepository.getGrades(any(), quarter: any(named: 'quarter')))
          .thenAnswer((_) => gradeCompleter.future);
      when(() => mockAcademicRepository.getGrades(any()))
          .thenAnswer((_) => gradeCompleter.future);
      when(() => mockAcademicRepository.getGradeSummary(any()))
          .thenAnswer((_) => summaryCompleter.future);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty grades message when data is empty', (WidgetTester tester) async {
      when(() => mockAcademicRepository.getGrades(any(), quarter: any(named: 'quarter'))).thenAnswer((_) async => const Right([]));
      when(() => mockAcademicRepository.getGrades(any())).thenAnswer((_) async => const Right([]));
      when(() => mockAcademicRepository.getGradeSummary(any())).thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      expect(find.text('Baholar mavjud emas'), findsOneWidget);
    });

    testWidgets('shows grade items and overall stats when data is available', (WidgetTester tester) async {
      final List<GradeModel> tGrades = [
        const GradeModel(id: 1, subjectName: 'Matematika', grade: 5, createdAt: '2023-11-01', teacherName: 'Domla'),
      ];
      final List<SubjectGradeSummary> tSummary = [
        const SubjectGradeSummary(subjectName: 'Matematika', averageGrade: 5.0, totalGrades: 1),
      ];

      when(() => mockAcademicRepository.getGrades(any(), quarter: any(named: 'quarter'))).thenAnswer((_) async => Right(tGrades));
      when(() => mockAcademicRepository.getGrades(any())).thenAnswer((_) async => Right(tGrades));
      when(() => mockAcademicRepository.getGradeSummary(any())).thenAnswer((_) async => Right(tSummary));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Fanlar bo\'yicha'), findsOneWidget);
      expect(find.text('Matematika'), findsWidgets); // Grade card
      // "5.0" overall gpa in the overall stats
      expect(find.text('5.0'), findsWidgets); 
    });

    testWidgets('shows error state when API fails', (WidgetTester tester) async {
      when(() => mockAcademicRepository.getGrades(any(), quarter: any(named: 'quarter')))
          .thenAnswer((_) async => const Left(ServerFailure('Tarmoq xatosi')));
      when(() => mockAcademicRepository.getGrades(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Tarmoq xatosi')));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.textContaining('Tarmoq xatosi'), findsOneWidget);
      expect(find.text('Qayta urinish'), findsOneWidget);
    });
  });
}

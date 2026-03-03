import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parent_school_app/core/error/failures.dart';
import 'package:parent_school_app/core/storage/shared_prefs_service.dart';
import 'package:parent_school_app/data/models/assignment_model.dart';
import 'package:parent_school_app/data/models/attendance_model.dart';
import 'package:parent_school_app/data/models/grade_model.dart';
import 'package:parent_school_app/data/models/schedule_model.dart';
import 'package:parent_school_app/data/repositories/academic_repository.dart';
import 'package:parent_school_app/presentation/providers/academic_provider.dart';

class MockAcademicRepository extends Mock implements AcademicRepository {}

void main() {
  late MockAcademicRepository mockRepository;

  setUp(() async {
    mockRepository = MockAcademicRepository();
    SharedPreferences.setMockInitialValues({});
    await SharedPrefsService.init();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        academicRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('GradesNotifier', () {
    const tChildId = 1;
    final tGrades = <GradeModel>[
      const GradeModel(
        id: 1,
        createdAt: '2025-01-01',
        grade: 5,
        gradeType: 'exam',
        subjectName: 'Math',
        teacherName: 'John',
      )
    ];
    final tSummary = <SubjectGradeSummary>[
      const SubjectGradeSummary(
        subjectName: 'Math',
        averageGrade: 5.0,
        totalGrades: 1,
        teacherName: 'John',
      )
    ];

    test('initial state is empty AsyncData', () {
      final container = createContainer();
      final state = container.read(gradesProvider);
      expect(state, const AsyncData(GradesData()));
    });

    test('loadGrades updates state on success', () async {
      final container = createContainer();
      when(() => mockRepository.getGrades(tChildId, quarter: 1))
          .thenAnswer((_) async => Right(tGrades));
      when(() => mockRepository.getGradeSummary(tChildId))
          .thenAnswer((_) async => Right(tSummary));

      final future = container.read(gradesProvider.notifier).loadGrades(tChildId);
      
      // Loading state check
      expect(container.read(gradesProvider).isLoading, true);

      await future;

      // Data state check
      final state = container.read(gradesProvider);
      expect(state.hasValue, true);
      expect(state.value!.grades, tGrades);
      expect(state.value!.summary, tSummary);
      expect(state.value!.selectedQuarter, 1);
    });

    test('selectQuarter updates selectedQuarter in state', () async {
      final container = createContainer();
      // Setup initial data
      when(() => mockRepository.getGrades(tChildId, quarter: 1))
          .thenAnswer((_) async => Right(tGrades));
      when(() => mockRepository.getGradeSummary(tChildId))
          .thenAnswer((_) async => Right(tSummary));
      
      await container.read(gradesProvider.notifier).loadGrades(tChildId);
      
      // Select quarter 2
      container.read(gradesProvider.notifier).selectQuarter(2);

      final state = container.read(gradesProvider);
      expect(state.value!.selectedQuarter, 2);
    });
  });

  group('ScheduleNotifier', () {
    const tChildId = 1;
    final tSchedule = <ScheduleModel>[
      const ScheduleModel(
        id: 1,
        subjectName: 'Math',
        teacherName: 'John',
        startTime: '08:00',
        endTime: '08:45',
        dayOfWeek: 1,
        lessonNumber: 1,
      )
    ];

    test('loadSchedule updates state on success', () async {
      final container = createContainer();
      when(() => mockRepository.getSchedule(tChildId))
          .thenAnswer((_) async => Right(tSchedule));

      await container.read(scheduleProvider.notifier).loadSchedule(tChildId);

      final state = container.read(scheduleProvider);
      expect(state.hasValue, true);
      expect(state.value!.fullSchedule, tSchedule);
    });
  });

  group('AssignmentsNotifier', () {
    const tChildId = 1;
    final tAssignments = <AssignmentModel>[
      const AssignmentModel(
        id: 1,
        title: 'Math Homework',
        description: 'Solve page 10',
        dueDate: '2025-01-01',
        createdAt: '2025-01-01',
        status: AssignmentStatus.pending,
        subjectName: 'Math',
        teacherName: 'John',
      )
    ];

    test('loadAssignments updates state on success', () async {
      final container = createContainer();
      when(() => mockRepository.getAssignments(tChildId, status: null))
          .thenAnswer((_) async => Right(tAssignments));

      await container.read(assignmentsProvider.notifier).loadAssignments(tChildId);

      final state = container.read(assignmentsProvider);
      expect(state.hasValue, true);
      expect(state.value!.assignments, tAssignments);
    });
  });

  group('AttendanceNotifier', () {
    const tChildId = 1;
    final tAttendance = <AttendanceModel>[
      const AttendanceModel(
        id: 1,
        date: '2025-01-01',
        status: AttendanceStatus.present,
        subjectName: 'Math',
        reason: null,
      )
    ];

    test('loadAttendance updates state and computes summary', () async {
      final container = createContainer();
      when(() => mockRepository.getAttendance(tChildId, month: null))
          .thenAnswer((_) async => Right(tAttendance));

      await container.read(attendanceProvider.notifier).loadAttendance(tChildId);

      final state = container.read(attendanceProvider);
      expect(state.hasValue, true);
      expect(state.value!.records, tAttendance);
      expect(state.value!.summary, isNotNull);
      expect(state.value!.summary!.presentDays, 1);
      expect(state.value!.summary!.totalDays, 1);
      expect(state.value!.summary!.attendancePercentage, 100.0);
    });
  });
}

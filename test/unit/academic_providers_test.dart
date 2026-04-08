import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parent_school_app/core/storage/shared_prefs_service.dart';
import 'package:parent_school_app/data/models/assignment_model.dart';
import 'package:parent_school_app/data/models/attendance_model.dart';
import 'package:parent_school_app/data/models/grade_model.dart';
import 'package:parent_school_app/data/models/schedule_model.dart';
import 'package:parent_school_app/data/repositories/academic_repository.dart';
import 'package:parent_school_app/presentation/providers/academic_provider.dart';

class MockAcademicRepository extends Mock implements AcademicRepository {}

void main() {
  late ProviderContainer container;
  late MockAcademicRepository mockRepository;

  setUp(() async {
    mockRepository = MockAcademicRepository();
    SharedPreferences.setMockInitialValues({});
    await SharedPrefsService.init();

    when(
      () => mockRepository.getGrades(any(), quarter: any(named: 'quarter')),
    ).thenAnswer(
      (_) async => const [
        GradeModel(
          id: 1,
          subjectName: 'Math',
          grade: 5,
          createdAt: '2023-10-10',
          comment: 'Good',
          quarter: 1,
          gradeType: '5',
        ),
      ],
    );
    when(
      () => mockRepository.getGradeSummary(any()),
    ).thenAnswer(
      (_) async => const [
        SubjectGradeSummary(
          subjectName: 'Math',
          averageGrade: 4.5,
          totalGrades: 10,
          teacherName: 'Mr. Smith',
        ),
      ],
    );
    when(
      () => mockRepository.getSchedule(any()),
    ).thenAnswer(
      (_) async => const [
        ScheduleModel(
          id: 1,
          subjectName: 'Math',
          dayOfWeek: 1,
          startTime: '08:00',
          endTime: '09:00',
          roomNumber: '101',
          teacherName: 'Mr. Smith',
          lessonNumber: 1,
        ),
      ],
    );
    when(
      () => mockRepository.getAssignments(
        any(),
        status: any(named: 'status'),
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => const [
        AssignmentModel(
          id: 1,
          subjectName: 'Math',
          title: 'Homework 1',
          dueDate: '2023-10-15',
          status: AssignmentStatus.pending,
          teacherName: 'Mr. Smith',
          createdAt: '2023-10-10',
        ),
      ],
    );
    when(
      () => mockRepository.submitAssignment(
        any(),
        text: any(named: 'text'),
        filePath: any(named: 'filePath'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockRepository.getAttendance(any(), month: any(named: 'month')),
    ).thenAnswer(
      (_) async => const [
        AttendanceModel(
          id: 1,
          date: '2023-10-01',
          status: AttendanceStatus.present,
          subjectName: 'Math',
          markedBy: 'Teacher',
        ),
      ],
    );

    container = ProviderContainer(
      overrides: [academicRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('GradesNotifier', () {
    test('initial state is data(empty)', () {
      final state = container.read(gradesProvider);
      expect(state.isLoading, false);
      expect(state.value?.grades, isEmpty);
    });

    test('loadGrades updates state with data', () async {
      final notifier = container.read(gradesProvider.notifier);
      await notifier.loadGrades(1);

      final state = container.read(gradesProvider);
      expect(state.hasValue, true);
      expect(state.value!.grades.length, 1);
      expect(state.value!.summary.length, 1);
      expect(state.value!.grades.first.subjectName, 'Math');
    });

    test('loadGrades sets error state on failure', () async {
      when(
        () => mockRepository.getGrades(1, quarter: any(named: 'quarter')),
      ).thenThrow(Exception('Grades load failed'));

      final notifier = container.read(gradesProvider.notifier);
      await notifier.loadGrades(1);

      final state = container.read(gradesProvider);
      expect(state.hasError, true);
    });

    test('selectQuarter updates selectedQuarter', () {
      expect(container.read(gradesProvider).value?.selectedQuarter, 1);

      final notifier = container.read(gradesProvider.notifier);
      notifier.selectQuarter(2);
      expect(container.read(gradesProvider).value?.selectedQuarter, 2);
    });
  });

  group('ScheduleNotifier', () {
    test('loadSchedule updates state', () async {
      final notifier = container.read(scheduleProvider.notifier);
      await notifier.loadSchedule(1);

      final state = container.read(scheduleProvider);
      expect(state.hasValue, true);
      expect(state.value!.fullSchedule.length, 1);
    });
  });

  group('AssignmentsNotifier', () {
    test('loadAssignments updates state', () async {
      final notifier = container.read(assignmentsProvider.notifier);
      await notifier.loadAssignments(1);

      final state = container.read(assignmentsProvider);
      expect(state.hasValue, true);
      expect(state.value!.assignments.length, 1);
    });

    test('submitAssignment returns true on success', () async {
      final notifier = container.read(assignmentsProvider.notifier);
      final success = await notifier.submitAssignment(1);

      expect(success, true);
    });
  });

  group('AttendanceNotifier', () {
    test('loadAttendance updates state', () async {
      final notifier = container.read(attendanceProvider.notifier);
      await notifier.loadAttendance(1);

      final state = container.read(attendanceProvider);
      expect(state.hasValue, true);
      expect(state.value!.records.length, 1);
      expect(state.value!.summary?.presentDays, 1);
    });
  });
}

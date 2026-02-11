import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

// Imports from the app
import 'package:parent_school_app/presentation/providers/academic_provider.dart';
import 'package:parent_school_app/data/repositories/academic_repository.dart';
import 'package:parent_school_app/data/models/grade_model.dart';
import 'package:parent_school_app/data/models/schedule_model.dart';
import 'package:parent_school_app/data/models/assignment_model.dart';
import 'package:parent_school_app/data/models/attendance_model.dart';
import 'package:parent_school_app/core/error/failures.dart';

// ─── MOCK REPOSITORY ───
class MockAcademicRepository implements AcademicRepository {
  bool shouldReturnError = false;

  MockAcademicRepository();

  @override
  Future<Either<Failure, List<GradeModel>>> getGrades(int childId, {int? quarter}) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Grades load failed'));
    }
    return const Right([
      GradeModel(id: 1, subjectName: 'Math', grade: 5, createdAt: '2023-10-10', comment: 'Good', quarter: 1, gradeType: '5'),
    ]);
  }

  @override
  Future<Either<Failure, List<SubjectGradeSummary>>> getGradeSummary(int childId) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Summary load failed'));
    }
    return const Right([
      SubjectGradeSummary(subjectName: 'Math', averageGrade: 4.5, totalGrades: 10, teacherName: 'Mr. Smith'),
    ]);
  }

  @override
  Future<Either<Failure, List<ScheduleModel>>> getSchedule(int childId) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Schedule load failed'));
    }
    return const Right([
      ScheduleModel(id: 1, subjectName: 'Math', dayOfWeek: 1, startTime: '08:00', endTime: '09:00', roomNumber: '101', teacherName: 'Mr. Smith', lessonNumber: 1),
    ]);
  }

  @override
  Future<Either<Failure, List<AssignmentModel>>> getAssignments(int childId, {String? status, int? page}) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Assignments load failed'));
    }
    return const Right([
      AssignmentModel(id: 1, subjectName: 'Math', title: 'Homework 1', dueDate: '2023-10-15', status: AssignmentStatus.pending, teacherName: 'Mr. Smith', createdAt: '2023-10-10'),
    ]);
  }

  @override
  Future<Either<Failure, AssignmentModel>> getAssignmentDetails(int assignmentId) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Assignment details failed'));
    }
    return const Right(AssignmentModel(id: 1, subjectName: 'Math', title: 'Homework 1', dueDate: '2023-10-15', status: AssignmentStatus.pending, teacherName: 'Mr. Smith', createdAt: '2023-10-10', description: 'Solve problems 1-10'));
  }

  @override
  Future<Either<Failure, void>> submitAssignment(int assignmentId, {String? text, String? filePath}) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Submission failed'));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, AttachmentModel>> uploadAssignmentFile(int assignmentId, String filePath) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Upload failed'));
    }
    return const Right(AttachmentModel(id: 1, name: 'file.pdf', url: 'http://example.com/file.pdf', fileSize: 1024, mimeType: 'application/pdf'));
  }

  @override
  Future<Either<Failure, List<AttendanceModel>>> getAttendance(int childId, {String? month}) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Attendance load failed'));
    }
    return const Right([
      AttendanceModel(id: 1, date: '2023-10-01', status: AttendanceStatus.present, subjectName: 'Math', markedBy: 'Teacher'),
    ]);
  }

  @override
  Future<Either<Failure, AttendanceSummary>> getAttendanceSummary(int childId) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Attendance summary failed'));
    }
    return const Right(AttendanceSummary(presentDays: 20, absentDays: 2, lateDays: 1, excusedDays: 0, totalDays: 23, attendancePercentage: 95.0));
  }
}

// ─── TESTS ───
void main() {
  late ProviderContainer container;
  late MockAcademicRepository mockRepository;

  setUp(() {
    mockRepository = MockAcademicRepository();
    container = ProviderContainer(
      overrides: [
        academicRepositoryProvider.overrideWithValue(mockRepository),
      ],
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
      mockRepository.shouldReturnError = true;
      final notifier = container.read(gradesProvider.notifier);
      
      try {
        await notifier.loadGrades(1);
      } catch (_) {}

      final state = container.read(gradesProvider);
      expect(state.hasError, true);
    });

    test('selectQuarter updates selectedQuarter', () {
      // Default state is GradesData()
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
      expect(state.value!.summary?.presentDays, 20);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/presentation/providers/academic_provider.dart';
import 'package:parent_school_app/data/repositories/academic_repository.dart';
import 'package:parent_school_app/data/models/grade_model.dart';
import 'package:parent_school_app/data/models/schedule_model.dart';
import 'package:parent_school_app/data/models/assignment_model.dart';
import 'package:parent_school_app/data/models/attendance_model.dart';
import 'package:parent_school_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

// Mock AcademicRepository
class MockAcademicRepository implements AcademicRepository {
  bool shouldReturnError = false;

  @override
  Future<Either<Failure, List<GradeModel>>> getGrades(int childId, {int? quarter}) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Grades load failed'));
    }
    return const Right([
      GradeModel(id: 1, subjectName: 'Math', grade: 5, createdAt: '2023-10-10', comment: 'Good', quarter: 1),
    ]);
  }

  @override
  Future<Either<Failure, List<SubjectGradeSummary>>> getGradeSummary(int childId) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Summary load failed'));
    }
    return const Right([
      SubjectGradeSummary(subjectName: 'Math', averageGrade: 4.5, totalGrades: 10),
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
    return const Right(AttachmentModel(id: 1, name: 'file.pdf', url: 'http://example.com/file.pdf'));
  }

  @override
  Future<Either<Failure, List<AttendanceModel>>> getAttendance(int childId, {String? month}) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Attendance load failed'));
    }
    return const Right([
      AttendanceModel(id: 1, date: '2023-10-01', status: AttendanceStatus.present),
    ]);
  }

  @override
  Future<Either<Failure, AttendanceSummary>> getAttendanceSummary(int childId) async {
    if (shouldReturnError) {
      return const Left(ServerFailure('Attendance summary failed'));
    }
    return const Right(AttendanceSummary(presentDays: 20, absentDays: 2, lateDays: 1, excusedDays: 0));
  }
}

void main() {
  late MockAcademicRepository mockRepository;
  late GradesNotifier gradesNotifier;
  late ScheduleNotifier scheduleNotifier;
  late AssignmentsNotifier assignmentsNotifier;
  late AttendanceNotifier attendanceNotifier;

  setUp(() {
    mockRepository = MockAcademicRepository();
    gradesNotifier = GradesNotifier(repository: mockRepository);
    scheduleNotifier = ScheduleNotifier(repository: mockRepository);
    assignmentsNotifier = AssignmentsNotifier(repository: mockRepository);
    attendanceNotifier = AttendanceNotifier(repository: mockRepository);
  });

  group('GradesNotifier Tests', () {
    test('loadGrades success', () async {
      await gradesNotifier.loadGrades(1);
      expect(gradesNotifier.state.isLoading, false);
      expect(gradesNotifier.state.grades.length, 1);
      expect(gradesNotifier.state.summary.length, 1);
      expect(gradesNotifier.state.error, null);
    });

    test('loadGrades failure', () async {
      mockRepository.shouldReturnError = true;
      await gradesNotifier.loadGrades(1);
      expect(gradesNotifier.state.isLoading, false);
      expect(gradesNotifier.state.error, 'Grades load failed');
    });
    
    test('selectQuarter updates state', () {
      gradesNotifier.selectQuarter(2);
      expect(gradesNotifier.state.selectedQuarter, 2);
    });
  });

  group('ScheduleNotifier Tests', () {
    test('loadSchedule success', () async {
      await scheduleNotifier.loadSchedule(1);
      expect(scheduleNotifier.state.isLoading, false);
      expect(scheduleNotifier.state.schedule.length, 1);
      expect(scheduleNotifier.state.error, null);
    });

    test('selectDay updates state', () {
      scheduleNotifier.selectDay(2);
      expect(scheduleNotifier.state.selectedDay, 2);
    });
  });

  group('AssignmentsNotifier Tests', () {
    test('loadAssignments success', () async {
      await assignmentsNotifier.loadAssignments(1);
      expect(assignmentsNotifier.state.isLoading, false);
      expect(assignmentsNotifier.state.assignments.length, 1);
    });

    test('submitAssignment success', () async {
      final success = await assignmentsNotifier.submitAssignment(1, text: 'Done');
      expect(success, true);
      expect(assignmentsNotifier.state.isLoading, false);
    });

    test('submitAssignment failure', () async {
      mockRepository.shouldReturnError = true;
      final success = await assignmentsNotifier.submitAssignment(1, text: 'Done');
      expect(success, false);
      expect(assignmentsNotifier.state.error, 'Submission failed');
    });
  });

  group('AttendanceNotifier Tests', () {
    test('loadAttendance success', () async {
      await attendanceNotifier.loadAttendance(1);
      expect(attendanceNotifier.state.isLoading, false);
      expect(attendanceNotifier.state.records.length, 1);
      expect(attendanceNotifier.state.summary?.presentDays, 20);
    });
  });
}

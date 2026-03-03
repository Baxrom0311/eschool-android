import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/error/failures.dart';
import 'package:parent_school_app/core/error/exceptions.dart';
import 'package:parent_school_app/data/datasources/remote/academic_api.dart';
import 'package:parent_school_app/data/models/assignment_model.dart';
import 'package:parent_school_app/data/models/attendance_model.dart';
import 'package:parent_school_app/data/models/grade_model.dart';
import 'package:parent_school_app/data/models/schedule_model.dart';
import 'package:parent_school_app/data/repositories/academic_repository.dart';

class MockAcademicApi extends Mock implements AcademicApi {}

void main() {
  late AcademicRepository repository;
  late MockAcademicApi mockAcademicApi;

  setUp(() {
    mockAcademicApi = MockAcademicApi();
    repository = AcademicRepository(academicApi: mockAcademicApi);
  });

  group('AcademicRepository', () {
    const tChildId = 1;
    const tAssignmentId = 123;
    final List<SubjectGradeSummary> tGradeSummary = [
      const SubjectGradeSummary(subjectName: 'Math', averageGrade: 4.5, totalGrades: 10)
    ];
    final List<ScheduleModel> tScheduleList = [
      const ScheduleModel(
        id: 1,
        subjectName: 'Math',
        teacherName: 'John Doe',
        startTime: '08:00:00',
        endTime: '09:20:00',
        dayOfWeek: 1,
        lessonNumber: 1,
        roomNumber: '101A',
      )
    ];

    test('getGradeSummary returns Right data on success', () async {
      // Arrange
      when(() => mockAcademicApi.getGradeSummary(tChildId))
          .thenAnswer((_) async => tGradeSummary);

      // Act
      final result = await repository.getGradeSummary(tChildId);

      // Assert
      expect(result, Right(tGradeSummary));
      verify(() => mockAcademicApi.getGradeSummary(tChildId)).called(1);
    });

    test('getGradeSummary returns Left on ServerException', () async {
      // Arrange
      when(() => mockAcademicApi.getGradeSummary(tChildId))
          .thenThrow(const ServerException(message: 'Server Error'));

      // Act
      final result = await repository.getGradeSummary(tChildId);

      // Assert
      expect(result, left(const ServerFailure('Server Error')));
    });

    test('getSchedule returns Right data on success', () async {
      // Arrange
      when(() => mockAcademicApi.getSchedule(tChildId))
          .thenAnswer((_) async => tScheduleList);

      // Act
      final result = await repository.getSchedule(tChildId);

      // Assert
      expect(result, Right(tScheduleList));
      verify(() => mockAcademicApi.getSchedule(tChildId)).called(1);
    });

    test('submitAssignment returns Right on success', () async {
      // Arrange
      when(() => mockAcademicApi.submitAssignment(
            tAssignmentId,
            text: any(named: 'text'),
            filePath: any(named: 'filePath'),
          )).thenAnswer((_) async {});

      // Act
      final result = await repository.submitAssignment(
        tAssignmentId,
        text: 'My homework',
      );

      // Assert
      expect(result, const Right(null));
      verify(() => mockAcademicApi.submitAssignment(
            tAssignmentId,
            text: 'My homework',
          )).called(1);
    });
    
    test('getAttendance returns Left on NetworkException', () async {
      // Arrange
      when(() => mockAcademicApi.getAttendance(tChildId, month: '2025-01'))
          .thenThrow(const NetworkException(message: 'No internet'));

      // Act
      final result = await repository.getAttendance(tChildId, month: '2025-01');

      // Assert
      expect(result, left(const NetworkFailure('No internet')));
    });
  });
}

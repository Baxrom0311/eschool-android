import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/error/exceptions.dart';
import 'package:parent_school_app/core/localization/app_locale.dart';
import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/data/datasources/remote/academic_api.dart';
import 'package:parent_school_app/data/models/grade_model.dart';
import 'package:parent_school_app/data/models/schedule_model.dart';
import 'package:parent_school_app/data/repositories/academic_repository.dart';

class MockAcademicApi extends Mock implements AcademicApi {}

void main() {
  late AcademicRepository repository;
  late MockAcademicApi mockAcademicApi;

  setUp(() {
    mockAcademicApi = MockAcademicApi();
    AppLocalizations.updateCurrent(AppLocalizations(AppLocale.uz));
    repository = AcademicRepository(academicApi: mockAcademicApi);
  });

  group('AcademicRepository', () {
    const tChildId = 1;
    const tAssignmentId = 123;
    final List<SubjectGradeSummary> tGradeSummary = [
      const SubjectGradeSummary(
        subjectName: 'Math',
        averageGrade: 4.5,
        totalGrades: 10,
      ),
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
      ),
    ];

    test('getGradeSummary returns data on success', () async {
      // Arrange
      when(
        () => mockAcademicApi.getGradeSummary(tChildId),
      ).thenAnswer((_) async => tGradeSummary);

      // Act
      final result = await repository.getGradeSummary(tChildId);

      // Assert
      expect(result, tGradeSummary);
      verify(() => mockAcademicApi.getGradeSummary(tChildId)).called(1);
    });

    test('getGradeSummary throws ServerException on failure', () async {
      // Arrange
      when(
        () => mockAcademicApi.getGradeSummary(tChildId),
      ).thenThrow(const ServerException(message: 'Server Error'));

      // Act & Assert
      expect(
        () => repository.getGradeSummary(tChildId),
        throwsA(isA<ServerException>()),
      );
    });

    test('getSchedule returns data on success', () async {
      // Arrange
      when(
        () => mockAcademicApi.getSchedule(tChildId),
      ).thenAnswer((_) async => tScheduleList);

      // Act
      final result = await repository.getSchedule(tChildId);

      // Assert
      expect(result, tScheduleList);
      verify(() => mockAcademicApi.getSchedule(tChildId)).called(1);
    });

    test('submitAssignment returns void on success', () async {
      // Arrange
      when(
        () => mockAcademicApi.submitAssignment(
          tAssignmentId,
          text: any(named: 'text'),
          filePath: any(named: 'filePath'),
        ),
      ).thenAnswer((_) async {});

      // Act
      await repository.submitAssignment(
        tAssignmentId,
        text: 'My homework',
      );

      // Assert
      verify(
        () => mockAcademicApi.submitAssignment(
          tAssignmentId,
          text: 'My homework',
        ),
      ).called(1);
    });

    test('getAttendance throws NetworkException on failure', () async {
      // Arrange
      when(
        () => mockAcademicApi.getAttendance(tChildId, month: '2025-01'),
      ).thenThrow(const NetworkException(message: 'No internet'));

      // Act & Assert
      expect(
        () => repository.getAttendance(tChildId, month: '2025-01'),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}

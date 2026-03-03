import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/network/dio_client.dart';
import 'package:parent_school_app/data/datasources/remote/academic_api.dart';
import 'package:parent_school_app/core/constants/api_constants.dart';
import 'package:parent_school_app/core/storage/local_cache_service.dart';

class MockDioClient extends Mock implements DioClient {}
class MockLocalCacheService extends Mock implements LocalCacheService {}

void main() {
  late AcademicApi academicApi;
  late MockDioClient mockDioClient;
  late MockLocalCacheService mockLocalCache;

  setUp(() {
    mockDioClient = MockDioClient();
    mockLocalCache = MockLocalCacheService();
    when(() => mockLocalCache.save(any(), any())).thenAnswer((_) async {});
    
    academicApi = AcademicApi(mockDioClient, mockLocalCache);
    registerFallbackValue(Options());
  });

  group('AcademicApi', () {
    const tChildId = 1;

    test('getSchedule returns list of ScheduleModel on success', () async {
      // Arrange
      final tResponse = {
        'schedule_by_child': {
          '1': {
            '2025-01-01': [
              {
                'id': 100,
                'subject': {'name': 'Math'},
                'teacher': {'name': 'John Doe'},
                'lessonTime': {
                  'starts_at': '08:00:00',
                  'ends_at': '08:45:00',
                  'lesson_no': 1
                },
                'room': {'name': '101A'},
                'day_of_week': 3,
              }
            ]
          }
        }
      };

      when(() => mockDioClient.get(
            ApiConstants.schedule(tChildId),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.schedule(tChildId)),
            data: tResponse,
            statusCode: 200,
          ));

      // Act
      final result = await academicApi.getSchedule(tChildId);

      // Assert
      expect(result.length, 1);
      expect(result.first.id, 100);
      expect(result.first.subjectName, 'Math');
      verify(() => mockDioClient.get(
            ApiConstants.schedule(tChildId),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).called(1);
    });

    test('getGradeSummary returns list of SubjectGradeSummary on success', () async {
      // Arrange
      final tResponse = {
        'yMap': {
          '1': {
            'subject_id': 1,
            'subject_name': 'Math',
            'grade_5': 5
          }
        },
        'subjects': {
          '1': {
            'name': 'Math'
          }
        }
      };

      when(() => mockDioClient.get(
            ApiConstants.childDetails(tChildId),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.childDetails(tChildId)),
            data: tResponse,
            statusCode: 200,
          ));

      // Act
      final result = await academicApi.getGradeSummary(tChildId);

      // Assert
      expect(result.length, 1);
      expect(result.first.subjectName, 'Math');
      expect(result.first.averageGrade, 5.0);
    });
  });
}

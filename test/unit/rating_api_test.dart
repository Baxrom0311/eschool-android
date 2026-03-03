import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/network/dio_client.dart';
import 'package:parent_school_app/data/datasources/remote/rating_api.dart';
import 'package:parent_school_app/core/constants/api_constants.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late RatingApi ratingApi;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    ratingApi = RatingApi(mockDioClient);
    registerFallbackValue(Options());
  });

  group('RatingApi', () {
    const tChildId = 1;

    test('getClassRating returns ranked RatingModel list', () async {
      // Arrange
      final tResponse = {
        'children': [
          {
            'id': 101,
            'name': 'Student A',
            'average_grade': 4.0,
            'class_id': 10
          },
          {
            'id': 102,
            'name': 'Student B',
            'average_grade': 5.0,
            'class_id': 10
          },
          {
            'id': 103,
            'name': 'Student C',
            'average_grade': 3.0,
            'class_id': 11 // Different class
          }
        ]
      };

      when(() => mockDioClient.get(
            ApiConstants.children,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.children),
            data: tResponse,
            statusCode: 200,
          ));

      // Act
      final result = await ratingApi.getClassRating(10);

      // Assert
      expect(result.length, 2);
      expect(result.first.studentName, 'Student B');
      expect(result.first.rank, 1);
      expect(result.last.studentName, 'Student A');
      expect(result.last.rank, 2);
    });

    test('getSchoolRating returns all ranked RatingModel list', () async {
      // Arrange
      final tResponse = {
        'children': [
          {
            'id': 101,
            'name': 'Student A',
            'average_grade': 4.0,
          },
          {
            'id': 102,
            'name': 'Student B',
            'average_grade': 5.0,
          }
        ]
      };

      when(() => mockDioClient.get(
            ApiConstants.children,
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.children),
            data: tResponse,
            statusCode: 200,
          ));

      // Act
      final result = await ratingApi.getSchoolRating();

      // Assert
      expect(result.length, 2);
      expect(result.first.studentName, 'Student B');
      expect(result.first.rank, 1);
    });

    test('getChildRating parses and derives grade from qMap', () async {
      // Arrange
      final tResponse = {
        'student': {
          'id': tChildId,
          'name': 'Student X',
        },
        'qMap': {
          '1': {
            '1': {'grade_5': 4}
          },
          '2': {
            '1': {'grade_5': 5}
          }
        }
      };

      when(() => mockDioClient.get(
            ApiConstants.childRating(tChildId),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.childRating(tChildId)),
            data: tResponse,
            statusCode: 200,
          ));

      // Act
      final result = await ratingApi.getChildRating(tChildId);

      // Assert
      expect(result.averageGrade, 4.5);
      expect(result.totalScore, 90.0);
      expect(result.studentName, 'Student X');
    });
  });
}

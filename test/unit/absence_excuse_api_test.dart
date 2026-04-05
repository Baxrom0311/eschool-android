import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/constants/api_constants.dart';
import 'package:parent_school_app/core/network/dio_client.dart';
import 'package:parent_school_app/data/datasources/remote/absence_excuse_api.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late AbsenceExcuseApi absenceExcuseApi;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    absenceExcuseApi = AbsenceExcuseApi(mockDioClient);
    registerFallbackValue(Options());
  });

  group('AbsenceExcuseApi', () {
    const tChildId = 1;

    test('getExcuses parses paginated parent response', () async {
      final tResponse = {
        'data': [
          {
            'id': 10,
            'excuse_date': '2026-04-05',
            'excuse_date_to': '2026-04-06',
            'reason': 'Kasal bo\'lib qoldi',
            'status': 'pending',
            'attachment': 'excuses/test.pdf',
          },
        ],
      };

      when(
        () => mockDioClient.get(
          ApiConstants.absenceExcuses,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.absenceExcuses),
          data: tResponse,
          statusCode: 200,
        ),
      );

      final result = await absenceExcuseApi.getExcuses(tChildId);

      expect(result, hasLength(1));
      expect(result.first.id, 10);
      expect(result.first.dateFrom, '2026-04-05');
      expect(result.first.dateTo, '2026-04-06');
      expect(result.first.reason, 'Kasal bo\'lib qoldi');
      expect(result.first.attachmentUrl, 'excuses/test.pdf');
    });

    test('submitExcuse sends backend field names', () async {
      when(
        () => mockDioClient.post(
          ApiConstants.absenceExcuses,
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.absenceExcuses),
          statusCode: 201,
        ),
      );

      await absenceExcuseApi.submitExcuse(
        childId: tChildId,
        dateFrom: '2026-04-05',
        dateTo: '2026-04-06',
        reason: 'Oilaviy sabab',
      );

      verify(
        () => mockDioClient.post(
          ApiConstants.absenceExcuses,
          data: {
            'student_id': tChildId,
            'excuse_date': '2026-04-05',
            'excuse_date_to': '2026-04-06',
            'reason': 'Oilaviy sabab',
          },
        ),
      ).called(1);
    });
  });
}

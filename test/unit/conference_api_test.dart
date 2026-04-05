import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/constants/api_constants.dart';
import 'package:parent_school_app/core/network/dio_client.dart';
import 'package:parent_school_app/data/datasources/remote/conference_api.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late ConferenceApi conferenceApi;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    conferenceApi = ConferenceApi(mockDioClient);
    registerFallbackValue(Options());
  });

  group('ConferenceApi', () {
    const tChildId = 1;

    test('getAvailableSlots parses slots response', () async {
      final tResponse = {
        'slots': [
          {
            'id': 11,
            'slot_date': '2026-04-07',
            'start_time': '09:00',
            'end_time': '09:20',
            'status': 'available',
            'location': '101-xona',
            'teacher': {'name': 'Matematika domla'},
          },
        ],
      };

      when(
        () => mockDioClient.get(ApiConstants.conferenceAvailable),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiConstants.conferenceAvailable,
          ),
          data: tResponse,
          statusCode: 200,
        ),
      );

      final result = await conferenceApi.getAvailableSlots(tChildId);

      expect(result, hasLength(1));
      expect(result.first.slotId, 11);
      expect(result.first.date, '2026-04-07');
      expect(result.first.time, '09:00 - 09:20');
      expect(result.first.teacherName, 'Matematika domla');
      expect(result.first.location, '101-xona');
      expect(result.first.zoomLink, isNull);
    });

    test('getMyBookings parses nested booking payload', () async {
      final tResponse = {
        'bookings': [
          {
            'id': 55,
            'conference_slot_id': 11,
            'status': 'booked',
            'conference_slot': {
              'id': 11,
              'slot_date': '2026-04-07',
              'start_time': '09:00',
              'end_time': '09:20',
              'location': 'https://meet.example.com/slot-11',
              'teacher': {'name': 'Matematika domla'},
            },
          },
        ],
      };

      when(
        () => mockDioClient.get(
          ApiConstants.conferenceMyBookings,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiConstants.conferenceMyBookings,
          ),
          data: tResponse,
          statusCode: 200,
        ),
      );

      final result = await conferenceApi.getMyBookings(tChildId);

      expect(result, hasLength(1));
      expect(result.first.id, 55);
      expect(result.first.slotId, 11);
      expect(result.first.time, '09:00 - 09:20');
      expect(result.first.teacherName, 'Matematika domla');
      expect(result.first.zoomLink, 'https://meet.example.com/slot-11');
    });

    test('bookConference sends slot-based payload', () async {
      when(
        () => mockDioClient.post(
          ApiConstants.conferenceBook,
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.conferenceBook),
          statusCode: 201,
        ),
      );

      await conferenceApi.bookConference(
        childId: tChildId,
        conferenceSlotId: 11,
        note: 'Onlayn uchrashuv bo\'lsa yaxshi bo\'lardi',
      );

      verify(
        () => mockDioClient.post(
          ApiConstants.conferenceBook,
          data: {
            'student_id': tChildId,
            'slot_id': 11,
            'note': 'Onlayn uchrashuv bo\'lsa yaxshi bo\'lardi',
          },
        ),
      ).called(1);
    });
  });
}

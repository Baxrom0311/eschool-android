import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/localization/app_locale.dart';
import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/core/network/dio_client.dart';
import 'package:parent_school_app/data/datasources/remote/auth_api.dart';
import 'package:parent_school_app/core/constants/api_constants.dart';
import 'package:parent_school_app/core/error/exceptions.dart';

// Mock class for DioClient
class MockDioClient extends Mock implements DioClient {}

void main() {
  late AuthApi authApi;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    AppLocalizations.updateCurrent(AppLocalizations(AppLocale.uz));
    authApi = AuthApi(mockDioClient);
    registerFallbackValue(Options());
  });

  group('AuthApi', () {
    const tUsername = '+998901234567';
    const tPassword = 'password';

    final tAuthResponseJson = {
      'token': 'test_token_123',
      'user': {
        'id': 1,
        'full_name': 'Test User',
        'phone': '+998901234567',
        'role': 'parent',
      },
    };

    test('login returns AuthResponse on success', () async {
      // Arrange
      when(
        () => mockDioClient.post(
          ApiConstants.login,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.login),
          data: tAuthResponseJson,
          statusCode: 200,
        ),
      );

      // Act
      final result = await authApi.login(
        username: tUsername,
        password: tPassword,
      );

      // Assert
      expect(result.accessToken, 'test_token_123');
      expect(result.user.fullName, 'Test User');
      expect(result.user.phone, '+998901234567');
      verify(
        () => mockDioClient.post(
          ApiConstants.login,
          data: {
            'email': tUsername,
            'password': tPassword,
            'device_name': 'android_app',
          },
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('login throws ServerException when token is missing', () async {
      AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));

      // Arrange
      final invalidResponse = {
        'user': {'id': 1, 'full_name': 'Test User'},
      };

      when(
        () => mockDioClient.post(
          ApiConstants.login,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.login),
          data: invalidResponse,
          statusCode: 200,
        ),
      );

      // Act
      final call = authApi.login;

      // Assert
      expect(
        () => call(username: tUsername, password: tPassword),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Server error',
          ),
        ),
      );
    });

    test(
      'login throws NetworkException on DioException with connection issue',
      () async {
        AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));

        // Arrange
        when(
          () => mockDioClient.post(
            ApiConstants.login,
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ApiConstants.login),
            type: DioExceptionType.connectionError,
          ),
        );

        // Act
        final call = authApi.login;

        // Assert
        expect(
          () => call(username: tUsername, password: tPassword),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              'No internet connection',
            ),
          ),
        );
      },
    );

    test(
      'login uses localized fallback user name when profile name is missing',
      () async {
        AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));

        final tFallbackResponse = {
          'token': 'test_token_123',
          'user': {'id': 1, 'phone': '+998901234567', 'role': 'parent'},
        };

        when(
          () => mockDioClient.post(
            ApiConstants.login,
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiConstants.login),
            data: tFallbackResponse,
            statusCode: 200,
          ),
        );

        final result = await authApi.login(
          username: tUsername,
          password: tPassword,
        );

        expect(result.user.fullName, 'User');
      },
    );

    test('logout makes a valid post call', () async {
      // Arrange
      when(() => mockDioClient.post(ApiConstants.logout)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.logout),
          statusCode: 200,
        ),
      );

      // Act
      await authApi.logout();

      // Assert
      verify(() => mockDioClient.post(ApiConstants.logout)).called(1);
    });

    test('forgotPassword makes a valid post call', () async {
      // Arrange
      when(
        () => mockDioClient.post(
          ApiConstants.forgotPassword,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.forgotPassword),
          statusCode: 200,
        ),
      );

      // Act
      await authApi.forgotPassword(phone: '+998901112233');

      // Assert
      verify(
        () => mockDioClient.post(
          ApiConstants.forgotPassword,
          data: {'phone': '+998901112233'},
          options: any(named: 'options'),
        ),
      ).called(1);
    });
  });
}

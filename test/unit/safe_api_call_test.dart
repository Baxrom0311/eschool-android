import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/core/error/failures.dart';
import 'package:parent_school_app/core/localization/app_locale.dart';
import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/core/utils/safe_api_call.dart';

void main() {
  setUp(() {
    AppLocalizations.updateCurrent(AppLocalizations(AppLocale.uz));
  });

  group('safeApiCall', () {
    test(
      'uses localized generic fallback when no error message is provided',
      () async {
        AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));

        final result = await safeApiCall<void>(() async {
          throw '';
        });

        result.fold(
          (failure) =>
              expect(failure, const ServerFailure('Something went wrong')),
          (_) => fail('Expected a failure result'),
        );
      },
    );

    test(
      'prefixes localized custom message when backend message exists',
      () async {
        AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));

        final result = await safeApiCall<void>(() async {
          throw 'Backend failure';
        }, errorMessage: AppLocalizations.current.loginFailed);

        result.fold(
          (failure) => expect(
            failure,
            const ServerFailure('Login failed: Backend failure'),
          ),
          (_) => fail('Expected a failure result'),
        );
      },
    );
  });
}

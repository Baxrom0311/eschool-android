import 'package:flutter_test/flutter_test.dart';

import 'package:parent_school_app/core/error/exceptions.dart';
import 'package:parent_school_app/core/localization/app_locale.dart';
import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/data/repositories/base_repository.dart';

class _TestRepository extends BaseRepository {}

void main() {
  setUp(() {
    AppLocalizations.updateCurrent(AppLocalizations(AppLocale.uz));
  });

  group('BaseRepository.safeExecute', () {
    test('uses localized generic fallback when message is empty', () async {
      AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));
      final repository = _TestRepository();

      await expectLater(
        repository.safeExecute<void>(() async {
          throw '';
        }),
        throwsA(
          isA<ServerException>().having(
            (error) => error.message,
            'message',
            'Something went wrong',
          ),
        ),
      );
    });

    test('preserves explicit backend messages', () async {
      AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));
      final repository = _TestRepository();

      await expectLater(
        repository.safeExecute<void>(() async {
          throw 'Backend failure';
        }),
        throwsA(
          isA<ServerException>().having(
            (error) => error.message,
            'message',
            'Backend failure',
          ),
        ),
      );
    });
  });
}

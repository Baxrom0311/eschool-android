import 'package:flutter_test/flutter_test.dart';
import 'package:parent_school_app/core/localization/app_locale.dart';
import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/core/utils/date_formatter.dart';

void main() {
  setUp(() {
    AppLocalizations.updateCurrent(AppLocalizations(AppLocale.uz));
  });

  group('DateFormatter', () {
    test(
      'formatRelative uses localized today, yesterday and tomorrow labels',
      () {
        AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));
        final now = DateTime.now();

        expect(DateFormatter.formatRelative(now), 'Today');
        expect(
          DateFormatter.formatRelative(now.subtract(const Duration(days: 1))),
          'Yesterday',
        );
        expect(
          DateFormatter.formatRelative(now.add(const Duration(days: 1))),
          'Tomorrow',
        );
      },
    );

    test('formatTimeAgo uses localized relative time labels', () {
      AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));

      expect(
        DateFormatter.formatTimeAgo(
          DateTime.now().subtract(const Duration(seconds: 10)),
        ),
        'Just now',
      );
      expect(
        DateFormatter.formatTimeAgo(
          DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        '5 minutes ago',
      );
      expect(
        DateFormatter.formatTimeAgo(
          DateTime.now().subtract(const Duration(hours: 2)),
        ),
        '2 hours ago',
      );
    });
  });
}

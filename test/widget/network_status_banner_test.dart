import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parent_school_app/core/localization/app_locale.dart';
import 'package:parent_school_app/core/localization/app_localizations.dart';
import 'package:parent_school_app/presentation/providers/connectivity_provider.dart';
import 'package:parent_school_app/presentation/screens/home/widgets/network_status_banner.dart';

class MockConnectivityNotifier extends StateNotifier<NetworkStatus>
    with Mock
    implements ConnectivityNotifier {
  MockConnectivityNotifier(super.state);
}

void main() {
  setUp(() {
    AppLocalizations.updateCurrent(AppLocalizations(AppLocale.en));
  });

  testWidgets('shows localized offline banner', (tester) async {
    final notifier = MockConnectivityNotifier(NetworkStatus.offline);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [connectivityProvider.overrideWith((ref) => notifier)],
        child: const MaterialApp(
          home: Scaffold(body: NetworkStatusBanner(child: SizedBox.shrink())),
        ),
      ),
    );

    expect(find.text('No internet connection'), findsOneWidget);
  });
}

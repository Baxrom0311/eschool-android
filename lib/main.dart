import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parent_school_app/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/localization/app_locale.dart';
import 'core/localization/l10n_extension.dart';
import 'core/routing/app_router.dart';
import 'core/storage/shared_prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/services/app_telemetry_service.dart';
import 'core/services/firebase_service.dart';
import 'presentation/providers/app_locale_provider.dart';
import 'presentation/providers/app_theme_mode_provider.dart';
import 'presentation/screens/home/widgets/network_status_banner.dart';
import 'core/services/socket_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppTelemetryService.installErrorHandlers();
  await _bootstrap();

  runApp(const ProviderScope(child: ParentSchoolApp()));
}

Future<void> _bootstrap() async {
  try {
    await SharedPrefsService.init();
    await initializeDateFormatting();
  } catch (e) {
    if (kDebugMode) {
      log('Bootstrap error: $e', name: 'Bootstrap');
    }
  }

  unawaited(AppTelemetryService.init());
}

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class ParentSchoolApp extends ConsumerStatefulWidget {
  const ParentSchoolApp({super.key});

  @override
  ConsumerState<ParentSchoolApp> createState() => _ParentSchoolAppState();
}

class _ParentSchoolAppState extends ConsumerState<ParentSchoolApp> {
  StreamSubscription? _fcmSubscription;

  @override
  void initState() {
    super.initState();
    _fcmSubscription = FirebaseService.onMessage.listen((message) {
      final l10n = AppLocalizationsRegistry.instance;
      final title =
          message.notification?.title ?? l10n.notificationFallbackTitle;
      final body = message.notification?.body ?? '';

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (body.isNotEmpty) ...[const SizedBox(height: 4), Text(body)],
            ],
          ),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: AppColors.primaryBlue,
          action: SnackBarAction(
            label: l10n.close,
            textColor: Colors.white,
            onPressed: () {
              scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
            },
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final router = ref.watch(routerProvider);

    // WebSocket tinglovchisini ishga tushirish
    ref.watch(socketListenerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      locale: locale.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      scaffoldMessengerKey: scaffoldMessengerKey,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          AppLocalizationsRegistry.update(l10n);
        }
        return NetworkStatusBanner(child: child!);
      },
    );
  }
}

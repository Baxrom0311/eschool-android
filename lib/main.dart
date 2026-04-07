import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/localization/app_locale.dart';
import 'core/localization/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/storage/shared_prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'core/services/firebase_service.dart';
import 'presentation/providers/app_locale_provider.dart';
import 'presentation/providers/app_theme_mode_provider.dart';
import 'presentation/screens/home/widgets/network_status_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  // Firebase startupni UI ochilishini bloklamasdan fon rejimida ishga tushiramiz.
  unawaited(FirebaseService.init());
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
      final l10n = AppLocalizations.current;
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
    final l10n = AppLocalizations(locale);
    AppLocalizations.updateCurrent(l10n);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: l10n.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      locale: locale.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      scaffoldMessengerKey: scaffoldMessengerKey,
      builder: (context, child) {
        return NetworkStatusBanner(child: child!);
      },
    );
  }
}

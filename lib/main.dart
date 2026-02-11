import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/routing/app_router.dart';
import 'core/storage/shared_prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _bootstrap();

  runApp(
    const ProviderScope(
      child: ParentSchoolApp(),
    ),
  );
}



Future<void> _bootstrap() async {
  try {
    await SharedPrefsService.init();
    await initializeDateFormatting('uz', null);
  } catch (e) {
    if (kDebugMode) {
      log('Bootstrap error: $e', name: 'Bootstrap');
    }
  }

  // Firebase startupni UI ochilishini bloklamasdan fon rejimida ishga tushiramiz.
  unawaited(FirebaseService.init());
}

class ParentSchoolApp extends StatelessWidget {
  const ParentSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ranch School Parent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}

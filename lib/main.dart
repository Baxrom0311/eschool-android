import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routing/app_router.dart';
import 'core/storage/shared_prefs_service.dart';
import 'core/storage/secure_storage.dart';
import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences init
  await SharedPrefsService.init();

  runApp(const ParentSchoolApp());
}

class ParentSchoolApp extends StatelessWidget {
  const ParentSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ─── Core Services ───
        Provider<SecureStorageService>(
          create: (_) => SecureStorageService(),
        ),
        ProxyProvider<SecureStorageService, DioClient>(
          update: (_, secureStorage, __) => DioClient(secureStorage),
        ),

        // ─── Feature Providers ───
        // Dev2 bu yerga o'zining providerlarini qo'shadi:
        // ChangeNotifierProvider(create: (_) => AuthProvider(...)),
        // ChangeNotifierProvider(create: (_) => UserProvider(...)),
        // ChangeNotifierProvider(create: (_) => PaymentProvider(...)),
        // ChangeNotifierProvider(create: (_) => AcademicProvider(...)),
        // ChangeNotifierProvider(create: (_) => MenuProvider(...)),
        // ChangeNotifierProvider(create: (_) => ChatProvider(...)),
      ],
      child: MaterialApp.router(
        title: 'Parent School',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    try {
      if (Firebase.apps.isEmpty) {
        if (kIsWeb) {
          // Web uchun options kerak, lekin bu fayl generatsiya qilinmagan bo'lsa
          // bu yerda crash bo'lmasligi uchun try-catch bor.
          // Agar rostakam options bo'lsa, uni shu yerga pass qilish kerak:
          // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
          // Hozircha bo'sh qoldiramiz, keyinchalik to'g'irlash uchun.
          log('Firebase initializeApp for WEB ignored (missing options)', name: 'FirebaseService');
        } else {
          await Firebase.initializeApp();
        }
      }
    } catch (e) {
      log('Background handler Firebase init error: $e', name: 'FirebaseService');
    }
  if (kDebugMode) {
    log('Background message handled: ${message.messageId}');
  }
}

class FirebaseService {
  static FirebaseMessaging? _firebaseMessaging;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      if (Firebase.apps.isEmpty) {
        if (kIsWeb) {
           // Web da optionssiz init qilib bo'lmaydi.
           // Userga xabar beramiz va davom etamiz (Firebase ishlmaydi).
           log('Warning: Firebase options not found for Web. Firebase features will be disabled.', name: 'FirebaseService');
           // Agar options bo'lsa:
           // await Firebase.initializeApp(options: ...);
        } else {
           await Firebase.initializeApp();
        }
      }

      _firebaseMessaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission for notifications
      final settings = await _firebaseMessaging?.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings?.authorizationStatus == AuthorizationStatus.authorized) {
        _debugLog('Notification permission granted');
      } else {
        _debugLog('Notification permission not granted');
      }

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _debugLog('Foreground FCM message received: ${message.messageId}');
      });

      _initialized = true;
    } catch (e) {
      // Firebase config bo'lmasa ilovani to'xtatmaymiz.
      _debugLog('Firebase init error: $e');
    }
  }

  static Future<String?> getFCMToken() async {
    try {
      if (_firebaseMessaging == null) return null;
      final token = await _firebaseMessaging!.getToken();
      if (token != null && token.isNotEmpty) {
        _debugLog('FCM token acquired');
      }
      return token;
    } catch (e) {
      _debugLog('Error getting FCM token: $e');
      return null;
    }
  }

  static void _debugLog(String message) {
    if (kDebugMode) {
      log(message, name: 'FirebaseService');
    }
  }
}

import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
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
        await Firebase.initializeApp();
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

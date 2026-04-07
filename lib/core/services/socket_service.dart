import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_client_flutter/pusher_client_flutter.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import '../../presentation/providers/auth_provider.dart';

/// Laravel Reverb (WebSocket) bilan ishlash uchun servis
class SocketService {
  Echo? _echo;
  final SecureStorageService _storage;
  final String? _token;

  SocketService(this._storage, this._token) {
    if (_token != null) {
      _initEcho();
    }
  }

  void _initEcho() {
    try {
      PusherOptions options = PusherOptions(
        host: ApiConstants.reverbHost,
        port: ApiConstants.reverbPort,
        cluster: 'mt1',
        auth: PusherAuth(
          '${ApiConstants.baseUrl}/broadcasting/auth',
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        ),
      );

      // Reverb uchun PusherClient ishlatiladi
      PusherClient pusherClient = PusherClient(
        ApiConstants.reverbKey,
        options,
        autoConnect: true,
      );

      _echo = Echo(
        client: pusherClient,
        broadcaster: EchoBroadcasterType.Pusher,
      );

      log('WebSocket: Echo initialized for Reverb');
    } catch (e) {
      log('WebSocket: Initialization error: $e');
    }
  }

  /// Hususiy kanalga ulanish va eventni tinglash
  void listenPrivate(String channelName, String eventName, Function(Map<String, dynamic>) onEvent) {
    if (_echo == null) return;

    _echo!.private(channelName).listen(eventName, (data) {
      log('WebSocket Event [$eventName] on [$channelName]: $data');
      onEvent(Map<String, dynamic>.from(data));
    });
  }

  /// Kanalni tark etish
  void leaveChannel(String channelName) {
    _echo?.leave(channelName);
  }

  /// WebSocket ulanishini uzish
  void disconnect() {
    _echo?.disconnect();
    log('WebSocket: Disconnected');
  }
}

/// SocketService Provider
final socketServiceProvider = Provider<SocketService?>((ref) {
  final authState = ref.watch(authProvider);
  final storage = ref.watch(secureStorageProvider);

  if (!authState.isAuthenticated || authState.user == null || authState.token == null) {
    return null;
  }

  return SocketService(storage, authState.token);
});

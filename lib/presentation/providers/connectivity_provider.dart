import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/outbox_service.dart';
import 'chat_provider.dart';

enum NetworkStatus { online, offline, unknown }

class ConnectivityNotifier extends StateNotifier<NetworkStatus> {
  final Connectivity _connectivity = Connectivity();
  final Ref _ref;

  ConnectivityNotifier(this._ref) : super(NetworkStatus.unknown) {
    _init();
    _connectivity.onConnectivityChanged.listen(_updateState);
  }

  Future<void> _init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateState(results);
    } catch (e) {
      state = NetworkStatus.unknown;
    }
  }

  void _updateState(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      state = NetworkStatus.offline;
    } else {
      final wasOffline = state == NetworkStatus.offline;
      state = NetworkStatus.online;
      
      if (wasOffline) {
        _flushOutbox();
      }
    }
  }

  Future<void> _flushOutbox() async {
    try {
      final outbox = _ref.read(outboxServiceProvider);
      final repo = _ref.read(chatRepositoryProvider);
      await outbox.flushOutbox(repo);
      // O'zgarishlarni UI ga bildirish uchun chatProvider ni qisman yangilab yuborish kerak bo'lishi mumkin
    } catch (_) {}
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, NetworkStatus>((ref) {
  return ConnectivityNotifier(ref);
});

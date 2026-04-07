import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/providers/academic_provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/payment_provider.dart';
import '../../presentation/providers/user_provider.dart';
import 'socket_service.dart';

/// WebSocket eventlarini tinglovchi va tegishli providerlarni yangilovchi servis.
/// Bu servis faqat foydalanuvchi authdan o'tganda ishga tushadi.
class SocketListener {
  final Ref _ref;

  SocketListener(this._ref) {
    _init();
  }

  void _init() {
    // SocketService mavjud bo'lganda (auth bo'lganda) tinglashni boshlaymiz
    _ref.listen<SocketService?>(socketServiceProvider, (previous, next) {
      if (next != null) {
        _subscribeToChannels(next);
      }
    });

    // Agar ilova ishga tushganda allaqachon auth bo'lsa
    final socketService = _ref.read(socketServiceProvider);
    if (socketService != null) {
      _subscribeToChannels(socketService);
    }
  }

  void _subscribeToChannels(SocketService socket) {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return;

    final parentId = authState.user!.id;
    final channelName = 'parent.$parentId';

    log('WebSocket: Subscribing to $channelName');

    // 1. Davomat (Attendance)
    socket.listenPrivate(channelName, 'AttendanceMarked', (data) {
      log('WebSocket: Attendance event received');
      final selectedChildId = _ref.read(userProvider).selectedChild?.id;
      if (selectedChildId != null) {
        _ref.read(attendanceProvider.notifier).loadAttendance(selectedChildId);
      }
    });

    // 2. Baholar (Grades)
    socket.listenPrivate(channelName, 'GradePublished', (data) {
      log('WebSocket: Grade event received');
      final selectedChildId = _ref.read(userProvider).selectedChild?.id;
      if (selectedChildId != null) {
        _ref.read(gradesProvider.notifier).loadGrades(selectedChildId);
      }
    });

    // 3. To'lovlar (Payments)
    socket.listenPrivate(channelName, 'PaymentReceived', (data) {
      log('WebSocket: Payment event received');
      _ref.read(paymentProvider.notifier).loadInitialData(
        studentId: _ref.read(userProvider).selectedChild?.id,
      );
    });

    // 4. Uy vazifalari (Homework)
    socket.listenPrivate(channelName, 'HomeworkAssigned', (data) {
      log('WebSocket: Homework event received');
      final selectedChildId = _ref.read(userProvider).selectedChild?.id;
      if (selectedChildId != null) {
        _ref.read(assignmentsProvider.notifier).loadAssignments(selectedChildId);
      }
    });
  }
}

/// SocketListener Provider (App ishga tushganda main.dart da chaqirilishi kerak)
final socketListenerProvider = Provider<SocketListener>((ref) {
  return SocketListener(ref);
});

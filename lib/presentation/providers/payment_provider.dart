import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/storage/shared_prefs_service.dart';
import '../../data/datasources/remote/payment_api.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';
import 'auth_provider.dart';

// ═══════════════════════════════════════════════════════════════
// DEPENDENCY PROVIDERS
// ═══════════════════════════════════════════════════════════════

final paymentApiProvider = Provider<PaymentApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PaymentApi(dioClient);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final paymentApi = ref.watch(paymentApiProvider);
  return PaymentRepository(paymentApi: paymentApi);
});

const _undefined = Object();

// ═══════════════════════════════════════════════════════════════
// PAYMENT STATE
// ═══════════════════════════════════════════════════════════════

/// To'lov holati — balans, tarix, to'lov usullari
class PaymentState {
  final BalanceInfo? balance;
  final List<PaymentModel> payments;
  final List<Map<String, dynamic>> paymentMethods;
  final bool isLoading;
  final String? error;

  /// Pagination
  final int currentPage;
  final bool hasMore;
  final int? selectedStudentId;

  const PaymentState({
    this.balance,
    this.payments = const [],
    this.paymentMethods = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.selectedStudentId,
  });

  const PaymentState.initial()
    : balance = null,
      payments = const [],
      paymentMethods = const [],
      isLoading = false,
      error = null,
      currentPage = 1,
      hasMore = true,
      selectedStudentId = null;

  PaymentState copyWith({
    BalanceInfo? balance,
    List<PaymentModel>? payments,
    List<Map<String, dynamic>>? paymentMethods,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    Object? selectedStudentId = _undefined,
  }) {
    return PaymentState(
      balance: balance ?? this.balance,
      payments: payments ?? this.payments,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedStudentId: selectedStudentId == _undefined
          ? this.selectedStudentId
          : selectedStudentId as int?,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAYMENT NOTIFIER
// ═══════════════════════════════════════════════════════════════

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository _repository;

  PaymentNotifier({required PaymentRepository repository})
    : _repository = repository,
      super(const PaymentState.initial());

  /// Balans va to'lov usullarini yuklash
  Future<void> loadInitialData({int? studentId}) async {
    // Prevent duplicate initial loads for the same child while data is fresh.
    if (state.isLoading && state.selectedStudentId == studentId) return;
    final hasData =
        state.balance != null ||
        state.payments.isNotEmpty ||
        state.paymentMethods.isNotEmpty;
    if (!state.isLoading &&
        state.selectedStudentId == studentId &&
        state.error == null &&
        hasData) {
      return;
    }

    final cached = _readCache(studentId);
    if (cached != null) {
      state = cached.copyWith(
        isLoading: true,
        error: null,
        selectedStudentId: studentId,
      );
    } else {
      state = state.copyWith(
        isLoading: true,
        error: null,
        selectedStudentId: studentId,
      );
    }

    // Parallel yuklash — tezroq, typed tuple bilan runtime castlardan qochamiz.
    final (balanceResult, historyResult, methodsResult) = await (
      _repository.getBalance(studentId: studentId),
      _repository.getPaymentHistory(page: 1, studentId: studentId),
      _repository.getPaymentMethods(),
    ).wait;

    // Natijalarni tekshirish
    BalanceInfo? balance = cached?.balance;
    List<PaymentModel> payments = cached?.payments ?? [];
    List<Map<String, dynamic>> methods = cached?.paymentMethods ?? [];
    String? error;
    var hasFreshData = false;

    balanceResult.fold(
      (f) {
        if (cached == null) {
          error = f.message;
        }
      },
      (b) {
        hasFreshData = true;
        balance = b;
      },
    );

    historyResult.fold(
      (f) {
        if (cached == null) {
          error ??= f.message;
        }
      },
      (p) {
        hasFreshData = true;
        payments = p;
      },
    );

    methodsResult.fold(
      (f) {
        if (cached == null) {
          error ??= f.message;
        }
      },
      (m) {
        hasFreshData = true;
        methods = m;
      },
    );

    if (!hasFreshData && cached != null) {
      state = cached.copyWith(
        isLoading: false,
        error: null,
        selectedStudentId: studentId,
      );
      return;
    }

    state = state.copyWith(
      balance: balance,
      payments: payments,
      paymentMethods: methods,
      isLoading: false,
      error: error,
      currentPage: 1,
      hasMore: payments.length >= 20,
      selectedStudentId: studentId,
    );
    unawaited(_saveCache(state));
  }

  /// Keyingi sahifani yuklash (infinite scroll)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final nextPage = state.currentPage + 1;
    final result = await _repository.getPaymentHistory(
      page: nextPage,
      studentId: state.selectedStudentId,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (newPayments) {
        state = state.copyWith(
          payments: [...state.payments, ...newPayments],
          isLoading: false,
          currentPage: nextPage,
          hasMore: newPayments.length >= 20,
        );
        unawaited(_saveCache(state));
      },
    );
  }

  /// Yangi to'lov yaratish
  Future<Map<String, dynamic>?> createPayment({
    required int amount,
    required String method,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.createPayment(
      amount: amount,
      method: method,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return null;
      },
      (paymentData) {
        state = state.copyWith(isLoading: false);
        return paymentData;
      },
    );
  }

  /// Faqat balansni yangilash
  Future<void> refreshBalance() async {
    final result = await _repository.getBalance(
      studentId: state.selectedStudentId,
    );
    result.fold((_) {}, (balance) {
      state = state.copyWith(balance: balance);
      unawaited(_saveCache(state));
    });
  }

  /// Hammasini yangilash
  Future<void> refresh({int? studentId}) async {
    final effectiveStudentId = studentId ?? state.selectedStudentId;
    state = const PaymentState.initial();
    await loadInitialData(studentId: effectiveStudentId);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clear() {
    state = const PaymentState.initial();
    unawaited(_clearCache());
  }

  PaymentState? _readCache(int? studentId) {
    final raw = SharedPrefsService.getString(_cacheKey(studentId));
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final balanceRaw = map['balance'];
      final paymentsRaw = map['payments'];
      final methodsRaw = map['payment_methods'];

      final balance = balanceRaw is Map
          ? BalanceInfo.fromJson(Map<String, dynamic>.from(balanceRaw))
          : null;
      final payments = paymentsRaw is List
          ? paymentsRaw
                .whereType<Map>()
                .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const <PaymentModel>[];
      final methods = methodsRaw is List
          ? methodsRaw
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : const <Map<String, dynamic>>[];

      return PaymentState(
        balance: balance,
        payments: payments,
        paymentMethods: methods,
        isLoading: false,
        error: null,
        currentPage: map['current_page'] is int
            ? map['current_page'] as int
            : 1,
        hasMore: map['has_more'] is bool ? map['has_more'] as bool : true,
        selectedStudentId: studentId,
      );
    } catch (_) {
      unawaited(SharedPrefsService.remove(_cacheKey(studentId)));
      return null;
    }
  }

  Future<void> _saveCache(PaymentState current) async {
    if (current.balance == null &&
        current.payments.isEmpty &&
        current.paymentMethods.isEmpty) {
      return;
    }

    await SharedPrefsService.setString(
      _cacheKey(current.selectedStudentId),
      jsonEncode({
        'balance': current.balance?.toJson(),
        'payments': current.payments.map((e) => e.toJson()).toList(),
        'payment_methods': current.paymentMethods,
        'current_page': current.currentPage,
        'has_more': current.hasMore,
      }),
    );
  }

  Future<void> _clearCache() async {
    await SharedPrefsService.remove(_cacheKey(state.selectedStudentId));
  }

  String _cacheKey(int? studentId) =>
      '${StorageKeys.paymentStateCachePrefix}${studentId ?? 0}';
}

// ═══════════════════════════════════════════════════════════════
// GLOBAL PAYMENT PROVIDER
// ═══════════════════════════════════════════════════════════════

/// ```dart
/// final paymentState = ref.watch(paymentProvider);
/// final balance = paymentState.balance;
///
/// ref.read(paymentProvider.notifier).createPayment(
///   amount: 500000,
///   method: 'payme',
/// );
/// ```
final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((
  ref,
) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentNotifier(repository: repository);
});

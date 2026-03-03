import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/payment_model.dart';
import 'api_helpers.dart';

/// Payment API — to'lov bilan bog'liq barcha API so'rovlari
class PaymentApi with ApiHelpers {
  final DioClient _client;

  PaymentApi(this._client);

  /// Balans va shartnoma ma'lumotlarini olish
  ///
  /// Parent OAS javobi to'lovlar ro'yxati bo'lgani uchun balans qiymatlari
  /// bo'lmasa xavfsiz defaultlar bilan to'ldiriladi.
  Future<BalanceInfo> getBalance({int? studentId}) async {
    try {
      final response = await _client.get(
        ApiConstants.balance,
        queryParameters: {
          if (studentId != null && studentId > 0) 'student_id': studentId,
        },
      );
      final data = asMap(response.data);
      final allPayments = _extractPaymentRows(data, studentId: studentId);

      final hasFinancialData =
          data.containsKey('balance') ||
          data.containsKey('monthly_fee') ||
          data.containsKey('default_amount') ||
          data.containsKey('debt_amount') ||
          data.containsKey('contract_number');

      final monthlyFee = toInt(data['monthly_fee'] ?? data['default_amount']);
      final balance = toInt(data['balance']);
      final explicitDebt = toInt(data['debt_amount']);
      final debt = hasFinancialData
          ? (explicitDebt > 0
                ? explicitDebt
                : (monthlyFee > balance ? (monthlyFee - balance) : 0))
          : 0;

      return BalanceInfo.fromJson({
        'balance': balance,
        'monthly_fee': monthlyFee,
        'contract_number': data['contract_number']?.toString(),
        'next_payment_date': _latestPaidDate(allPayments),
        'debt_amount': debt,
        'has_financial_data': hasFinancialData,
      });
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// To'lovlar tarixini olish (pagination bilan)
  Future<List<PaymentModel>> getPaymentHistory({
    int? studentId,
    int page = 1,
    int perPage = ApiConstants.defaultPageSize,
    String? status,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.paymentHistory,
        queryParameters: {
          if (studentId != null && studentId > 0) 'student_id': studentId,
          'page': page,
          'per_page': perPage,
        },
      );
      final root = asMap(response.data);
      var payments =
          _extractPaymentRows(
              root,
              studentId: studentId,
            ).map(_mapPaymentRow).toList();

      if (status != null && status.isNotEmpty) {
        final normalized = status.toLowerCase();
        payments = payments
            .where((p) => p.status.name.toLowerCase() == normalized)
            .toList();
      }

      return payments;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// Yangi to'lov yaratish (PayMe/Click/Paynet ga yo'naltirish uchun URL olish)
  ///
  /// POST /api/parent/payments/create
  /// Body: { "student_id": 5, "amount": 450000 }
  /// Response: { "transaction_id": 123, "click_url": "...", "payme_url": "...", "paynet_url": "..." }
  Future<Map<String, dynamic>> createPayment({
    required int amount,
    required String method,
    int? studentId,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.createPayment,
        data: {
          'student_id': studentId ?? 0,
          'amount': amount,
        },
      );

      final data = asMap(response.data);

      // method bo'yicha tegishli URL ni tanlash
      final urlKey = switch (method) {
        'click' => 'click_url',
        'payme' => 'payme_url',
        'paynet' => 'paynet_url',
        _ => 'click_url',
      };

      return {
        'transaction_id': data['transaction_id'],
        'redirect_url': data[urlKey]?.toString() ?? '',
        'click_url': data['click_url']?.toString() ?? '',
        'payme_url': data['payme_url']?.toString() ?? '',
        'paynet_url': data['paynet_url']?.toString() ?? '',
      };
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// To'lov usullarini olish (mavjud PayMe/Click/naqd)
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    return _defaultMethods();
  }

  List<Map<String, dynamic>> _defaultMethods() {
    return const [
      {'id': 'click', 'name': 'Click', 'icon': 'assets/icons/click.png'},
      {'id': 'payme', 'name': 'PayMe', 'icon': 'assets/icons/payme.png'},
      {'id': 'cash', 'name': 'Naqd', 'icon': 'assets/icons/cash.png'},
    ];
  }

  List<Map<String, dynamic>> _extractPaymentRows(
    Map<String, dynamic> root, {
    int? studentId,
  }) {
    final result = <Map<String, dynamic>>[];

    if (root['payments_by_child'] is Map) {
      final byChild = Map<String, dynamic>.from(
        root['payments_by_child'] as Map,
      );
      if (studentId != null && studentId > 0) {
        final selected = byChild[studentId.toString()];
        if (selected is List) {
          for (final item in selected.whereType<Map>()) {
            result.add(Map<String, dynamic>.from(item));
          }
        }
      } else {
        for (final value in byChild.values) {
          if (value is List) {
            for (final item in value.whereType<Map>()) {
              result.add(Map<String, dynamic>.from(item));
            }
          }
        }
      }
      return result;
    }

    if (root['payments'] is List) {
      for (final item in (root['payments'] as List).whereType<Map>()) {
        result.add(Map<String, dynamic>.from(item));
      }
      return result;
    }

    if (root['data'] is List) {
      for (final item in (root['data'] as List).whereType<Map>()) {
        result.add(Map<String, dynamic>.from(item));
      }
    }

    return result;
  }

  PaymentModel _mapPaymentRow(Map<String, dynamic> row) {
    final paidAt = (row['paid_at'] ?? row['created_at'] ?? '').toString();
    final statusValue =
        (row['status'] ?? (paidAt.isNotEmpty ? 'completed' : 'pending'))
            .toString()
            .toLowerCase();

    final method = _normalizeMethod(row['payment_method']?.toString());
    final status = _normalizeStatus(statusValue);

    final group = asMap(row['group']);
    final payType = row['pay_type']?.toString();
    final note = row['note']?.toString();
    final periodMonth = row['period_month']?.toString();
    final periodYear = row['period_year']?.toString();
    final description =
        note ??
        [
          if (payType != null && payType.isNotEmpty) payType,
          if (periodMonth != null && periodYear != null)
            '$periodMonth/$periodYear',
        ].join(' ');

    return PaymentModel.fromJson({
      'id': toInt(row['id']) == 0
          ? row.toString().hashCode.abs()
          : toInt(row['id']),
      'amount': _toAmountDouble(row['amount']),
      'status': status,
      'method': method,
      'description': description,
      'transaction_id': row['transaction_id']?.toString(),
      'contract_number':
          row['contract_number']?.toString() ?? group['code']?.toString(),
      'created_at': paidAt.isEmpty ? DateTime.now().toIso8601String() : paidAt,
      'updated_at': row['updated_at']?.toString(),
    });
  }

  String _normalizeMethod(String? value) {
    final raw = (value ?? '').toLowerCase();
    if (raw.contains('click')) return 'click';
    if (raw.contains('payme')) return 'payme';
    if (raw.contains('transfer')) return 'transfer';
    if (raw.contains('cash')) return 'cash';
    return 'cash';
  }

  String _normalizeStatus(String value) {
    switch (value) {
      case 'completed':
      case 'paid':
      case 'success':
        return 'completed';
      case 'failed':
      case 'error':
        return 'failed';
      case 'refunded':
        return 'refunded';
      default:
        return 'pending';
    }
  }

  double _toAmountDouble(dynamic value) {
    final amount = toNullableDouble(value);
    if (amount != null) return amount;
    return toInt(value).toDouble();
  }

  String? _latestPaidDate(List<Map<String, dynamic>> rows) {
    final dates = rows
        .map((e) => e['paid_at']?.toString() ?? e['created_at']?.toString())
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.last;
  }
}

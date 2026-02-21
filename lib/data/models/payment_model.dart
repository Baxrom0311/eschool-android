import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_model.g.dart';

/// To'lov holati enumlari
enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('refunded')
  refunded,
}

/// To'lov usuli enumlari
enum PaymentMethod {
  @JsonValue('payme')
  payme,
  @JsonValue('click')
  click,
  @JsonValue('cash')
  cash,
  @JsonValue('transfer')
  transfer,
}

/// To'lov modeli — to'lovlar tarixi va yangi to'lovlar uchun
@JsonSerializable()
class PaymentModel extends Equatable {
  final int id;

  /// To'lov summasi (so'mda, tiyin aniqligi bilan)
  final double amount;

  /// To'lov holati
  final PaymentStatus status;

  /// To'lov usuli
  final PaymentMethod method;

  /// To'lov tavsifi
  final String? description;

  /// Tranzaksiya IDsi (to'lov tizimidan)
  @JsonKey(name: 'transaction_id')
  final String? transactionId;

  /// Shartnoma raqami
  @JsonKey(name: 'contract_number')
  final String? contractNumber;

  /// To'lov sanasi
  @JsonKey(name: 'created_at')
  final String createdAt;

  /// Yangilangan sana
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const PaymentModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.method,
    this.description,
    this.transactionId,
    this.contractNumber,
    required this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  /// Formatlangan summa: "1 500 000 so'm"
  String get formattedAmount {
    final hasFraction = (amount % 1).abs() > 0.000001;
    final amountText = hasFraction
        ? amount.toStringAsFixed(2)
        : amount.toStringAsFixed(0);
    final parts = amountText.split('.');
    final formattedInteger = parts.first.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    if (parts.length > 1 && parts[1] != '00') {
      return '$formattedInteger.${parts[1]} so\'m';
    }
    return '$formattedInteger so\'m';
  }

  /// Holat rangi uchun helper
  bool get isCompleted => status == PaymentStatus.completed;
  bool get isPending => status == PaymentStatus.pending;
  bool get isFailed => status == PaymentStatus.failed;

  /// Holat matni (o'zbekcha)
  String get statusText {
    switch (status) {
      case PaymentStatus.pending:
        return 'Kutilmoqda';
      case PaymentStatus.completed:
        return 'Muvaffaqiyatli';
      case PaymentStatus.failed:
        return 'Muvaffaqiyatsiz';
      case PaymentStatus.refunded:
        return 'Qaytarilgan';
    }
  }

  /// To'lov usuli matni
  String get methodText {
    switch (method) {
      case PaymentMethod.payme:
        return 'PayMe';
      case PaymentMethod.click:
        return 'Click';
      case PaymentMethod.cash:
        return 'Naqd';
      case PaymentMethod.transfer:
        return 'O\'tkazma';
    }
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    status,
    method,
    description,
    transactionId,
    contractNumber,
    createdAt,
  ];
}

/// Balans modeli — joriy balans va shartnoma ma'lumotlari
@JsonSerializable()
class BalanceInfo extends Equatable {
  final int balance;

  @JsonKey(name: 'monthly_fee')
  final int monthlyFee;

  @JsonKey(name: 'contract_number')
  final String? contractNumber;

  @JsonKey(name: 'next_payment_date')
  final String? nextPaymentDate;

  @JsonKey(name: 'debt_amount', defaultValue: 0)
  final int debtAmount;

  @JsonKey(name: 'has_financial_data', defaultValue: true)
  final bool hasFinancialData;

  const BalanceInfo({
    required this.balance,
    required this.monthlyFee,
    this.contractNumber,
    this.nextPaymentDate,
    this.debtAmount = 0,
    this.hasFinancialData = true,
  });

  factory BalanceInfo.fromJson(Map<String, dynamic> json) =>
      _$BalanceInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceInfoToJson(this);

  bool get hasDebt => debtAmount > 0;

  String get formattedBalance {
    final formatted = balance.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$formatted so\'m';
  }

  String get formattedMonthlyFee {
    final formatted = monthlyFee.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$formatted so\'m';
  }

  @override
  List<Object?> get props => [
    balance,
    monthlyFee,
    contractNumber,
    nextPaymentDate,
    debtAmount,
    hasFinancialData,
  ];
}

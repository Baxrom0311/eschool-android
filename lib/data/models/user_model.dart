import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'child_model.dart';

part 'user_model.g.dart';

/// Foydalanuvchi (Ota-ona) modeli
///
/// API dan keladigan to'liq profil ma'lumotlari.
/// Login/Register javobida ham, Profile API da ham ishlatiladi.
@JsonSerializable(explicitToJson: true)
class UserModel extends Equatable {
  final int id;

  @JsonKey(name: 'full_name', readValue: _fullNameReader)
  final String fullName;

  final String phone;

  final String? email;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  /// Foydalanuvchi roli: 'parent', 'teacher', 'admin'
  @JsonKey(defaultValue: 'parent')
  final String role;

  /// Joriy balans (so'm)
  @JsonKey(name: 'balance', defaultValue: 0)
  final int balance;

  /// Shartnoma raqami
  @JsonKey(name: 'contract_number')
  final String? contractNumber;

  /// Shartnoma summasi (oylik)
  @JsonKey(name: 'monthly_fee', defaultValue: 0)
  final int monthlyFee;

  /// Farzandlar ro'yxati
  @JsonKey(defaultValue: [])
  final List<ChildModel> children;

  /// Hisob yaratilgan sana
  @JsonKey(name: 'created_at')
  final String? createdAt;

  /// Bildirishnomalar yoqilganmi
  @JsonKey(name: 'notifications_enabled', defaultValue: true)
  final bool notificationsEnabled;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.role = 'parent',
    this.balance = 0,
    this.contractNumber,
    this.monthlyFee = 0,
    this.children = const [],
    this.createdAt,
    this.notificationsEnabled = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? email,
    String? avatarUrl,
    String? role,
    int? balance,
    String? contractNumber,
    int? monthlyFee,
    List<ChildModel>? children,
    String? createdAt,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      balance: balance ?? this.balance,
      contractNumber: contractNumber ?? this.contractNumber,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      children: children ?? this.children,
      createdAt: createdAt ?? this.createdAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  /// Birinchi farzand (tez-tez tanlangan farzand sifatida ishlatiladi)
  ChildModel? get firstChild => children.isNotEmpty ? children.first : null;

  /// Farzandlar soni
  int get childrenCount => children.length;

  /// Balansni formatlangan ko'rinishda qaytarish (1,500,000 so'm)
  String get formattedBalance {
    final formatted = balance
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
    return '$formatted so\'m';
  }

  /// To'lov qilish kerakmi (balans < oylik to'lov)
  bool get needsPayment => balance < monthlyFee;

  /// Qarz summasi (agar bor bo'lsa)
  int get debtAmount => monthlyFee > balance ? monthlyFee - balance : 0;

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        email,
        avatarUrl,
        role,
        balance,
        contractNumber,
        monthlyFee,
        children,
        createdAt,
        notificationsEnabled,
      ];

  @override
  String toString() =>
      'UserModel(id: $id, fullName: $fullName, children: ${children.length})';
}

/// JSON dan o'qishda yordamchi funksiya
Object? _fullNameReader(Map json, String key) {
  if (json.containsKey('full_name')) {
    return json['full_name'];
  }
  if (json.containsKey('name')) {
    return json['name'];
  }
  if (json.containsKey('first_name') && json.containsKey('last_name')) {
    return '${json['first_name']} ${json['last_name']}';
  }
  return null;
}

import 'package:json_annotation/json_annotation.dart';

import 'user_model.dart';

part 'auth_response.g.dart';

/// Login/Register API javob modeli
///
/// Server login/register so'roviga javob sifatida
/// tokenlar va foydalanuvchi ma'lumotlarini qaytaradi.
///
/// Misol javob:
/// ```json
/// {
///   "access_token": "eyJhbGci...",
///   "refresh_token": "dGhpcyBp...",
///   "token_type": "Bearer",
///   "expires_in": 3600,
///   "user": { ... }
/// }
/// ```
@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'token')
  final String accessToken;

  // @JsonKey(name: 'refresh_token')
  // final String refreshToken; // Not used in new API

  // @JsonKey(name: 'token_type', defaultValue: 'Bearer')
  // final String tokenType; // Not used

  // @JsonKey(name: 'expires_in', defaultValue: 3600)
  // final int expiresIn; // Not used

  /// Foydalanuvchi ma'lumotlari
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    // required this.refreshToken,
    // this.tokenType = 'Bearer',
    // this.expiresIn = 3600,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  String toString() =>
      'AuthResponse(userId: ${user.id})';
}

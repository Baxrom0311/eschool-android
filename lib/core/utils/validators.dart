import '../constants/app_strings.dart';

/// Form validatsiya funksiyalari
class Validators {
  Validators._();

  /// Maydon bo'sh emasligini tekshirish
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName ${AppStrings.fieldRequired.toLowerCase()}'
          : AppStrings.fieldRequired;
    }
    return null;
  }

  /// Telefon raqamini tekshirish (O'zbekiston formati)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.phoneRequired;
    }
    // +998 XX XXX XX XX
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^(\+998|998)?[0-9]{9}$').hasMatch(cleaned)) {
      return AppStrings.invalidPhone;
    }
    return null;
  }

  /// Email tekshirish
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.emailRequired;
    }
    final email = value.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  /// Parol tekshirish (minimum 6 belgi)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  /// Parollarni solishtirish
  static String? confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordRequired;
    }
    if (value != original) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }

  /// Minimum uzunlik
  static String? minLength(String? value, int min) {
    if (value == null || value.length < min) {
      return AppStrings.minimumLength(min);
    }
    return null;
  }
}

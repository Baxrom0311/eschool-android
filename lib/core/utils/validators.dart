/// Form validatsiya funksiyalari
class Validators {
  Validators._();

  /// Maydon bo'sh emasligini tekshirish
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName to\'ldirilishi shart'
          : 'Bu maydon to\'ldirilishi shart';
    }
    return null;
  }

  /// Telefon raqamini tekshirish (O'zbekiston formati)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon raqamini kiriting';
    }
    // +998 XX XXX XX XX
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^(\+998|998)?[0-9]{9}$').hasMatch(cleaned)) {
      return 'Telefon raqami noto\'g\'ri';
    }
    return null;
  }

  /// Email tekshirish
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email kiriting';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Email noto\'g\'ri';
    }
    return null;
  }

  /// Parol tekshirish (minimum 6 belgi)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Parolni kiriting';
    }
    if (value.length < 6) {
      return 'Parol kamida 6 ta belgi bo\'lishi kerak';
    }
    return null;
  }

  /// Parollarni solishtirish
  static String? confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) {
      return 'Parolni tasdiqlang';
    }
    if (value != original) {
      return 'Parollar mos kelmayapti';
    }
    return null;
  }

  /// Minimum uzunlik
  static String? minLength(String? value, int min) {
    if (value == null || value.length < min) {
      return 'Kamida $min ta belgi kiritilishi kerak';
    }
    return null;
  }
}

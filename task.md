# PARENT SCHOOL APP - INITIAL SETUP TASK
## Flutter Project Boshlang'ich Konfiguratsiya

---

## 📋 LOYIHA HAQIDA TO'LIQ MA'LUMOT

### **Loyiha Nomi:** Parent School App (Ota-onalar uchun maktab ilovasi)

### **Maqsad:**
Ota-onalar farzandlarining maktabdagi o'qish jarayonini kuzatish, baholar, dars jadvali, uyga vazifalar, to'lovlar, ovqatlanish menyusi va o'qituvchilar bilan muloqot qilish uchun mobil ilova.

### **Platform:** 
- Android (asosiy)
- iOS (kelajakda)

### **Texnologiya:** Flutter

### **Backend API:** 
- Base URL: `https://ranchschool.izlash.uz/api`
- Swagger Docs: `https://ranchschool.izlash.uz/docs/tenant`
- API Type: RESTful JSON

### **Arxitektura:** Clean Architecture
- **Presentation Layer:** Screens, Widgets, Providers (State Management)
- **Data Layer:** Models, Repositories, API Services
- **Core Layer:** Constants, Utils, Theme, Network

---

## 🎯 ASOSIY FUNKSIYALAR (10 ta)

1. **Autentifikatsiya** - Login/Register (telefon/username + parol, Google, QR kod)
2. **Profil** - Shaxsiy ma'lumotlar, farzandlar ro'yxati, balans
3. **To'lovlar** - Balans ko'rish, to'lovlar tarixi, to'lov qilish (PayMe, Click)
4. **Baholar va Reyting** - Fan bo'yicha baholar, umumiy reyting, davomat
5. **Dars Jadvali** - Kunlik/haftalik jadval, xona, o'qituvchi
6. **Uyga Vazifalar** - Vazifalar ro'yxati, topshirish, fayl yuklash
7. **Ovqatlanish Menyusi** - Kunlik/haftalik menyu, kaloriya ma'lumoti
8. **Chat** - O'qituvchilar bilan xabar almashinish, fayl yuborish
9. **Bildirishnomalar** - Push notifications, yangiliklar
10. **Dynamic Theming** - Har bir maktab o'z ranglarini tanlashi mumkin

---

## 👥 JAMOA TUZILMASI

### **2 ta Developer:**

**Developer 1 (UI Specialist):**
- Barcha ekranlarni yasash
- Custom widgetlar
- Animatsiyalar
- Ishlash joyi: `lib/presentation/screens/` va `lib/presentation/widgets/`

**Developer 2 (Core/Backend Specialist):**
- API integratsiya
- State management
- Data models
- Repositories
- Ishlash joyi: `lib/core/` va `lib/data/`

### **Sizning vazifangiz (Initial Setup):**
Ikkalasi uchun umumiy base (asos) tayyorlash - loyihani yaratish, dependencies qo'shish, folder structure, basic configuration.

---

## 📦 SIZNING TASKINGIZ: INITIAL PROJECT SETUP

### **Maqsad:**
Developer 1 va Developer 2 ishlashni boshlashlari uchun to'liq tayyor loyiha tayyorlash.

### **Vaqt:** 1 kun (6-8 soat)

---

## ✅ TASK 1: FLUTTER PROJECT YARATISH (30 daqiqa)

### **1.1 Yangi Flutter project yaratish:**

```bash
flutter create parent_school_app --org uz.ranchschool
cd parent_school_app
```

**Tushuntirish:**
- `parent_school_app` - loyiha nomi
- `--org uz.ranchschool` - Android package name uchun: `uz.ranchschool.parent_school_app`

### **1.2 Flutter versiyasini tekshirish:**

```bash
flutter --version
# Minimum: Flutter 3.16.0 yoki yuqori
# Dart 3.0+ kerak
```

Agar versiya past bo'lsa:
```bash
flutter upgrade
```

### **1.3 Android SDK Setup:**
```bash
flutter doctor
# Barcha checkmarklar ✓ bo'lishi kerak
# Agar muammo bo'lsa, hal qiling
```

### **1.4 Test qilish:**
```bash
flutter run
# Emulator yoki real device da default app ochilishi kerak
```

**Checklist:**
- [ ] Flutter project yaratildi
- [ ] Flutter versiyasi 3.16.0+
- [ ] `flutter doctor` barcha ✓
- [ ] Default app ishladi

---

## ✅ TASK 2: FOLDER STRUCTURE YARATISH (30 daqiqa)

### **2.1 lib/ papkasini tozalash:**

```bash
cd lib
rm -rf main.dart
```

### **2.2 Quyidagi folder strukturani yarating:**

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_text_styles.dart
│   │   ├── storage_keys.dart
│   │   └── app_routes.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── theme_config.dart
│   │   ├── theme_colors.dart
│   │   └── dynamic_theme_provider.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── api_interceptors.dart
│   │   ├── api_error_handler.dart
│   │   └── network_info.dart
│   ├── storage/
│   │   ├── secure_storage.dart
│   │   └── shared_prefs_service.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── date_formatter.dart
│   │   ├── file_utils.dart
│   │   └── logger.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   ├── failures.dart
│   │   └── error_handler.dart
│   └── routing/
│       ├── app_router.dart
│       └── route_names.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── child_model.dart
│   │   ├── grade_model.dart
│   │   ├── schedule_model.dart
│   │   ├── assignment_model.dart
│   │   ├── payment_model.dart
│   │   ├── menu_model.dart
│   │   ├── chat_model.dart
│   │   └── notification_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   ├── academic_repository.dart
│   │   ├── payment_repository.dart
│   │   ├── menu_repository.dart
│   │   ├── chat_repository.dart
│   │   └── school_repository.dart
│   └── datasources/
│       ├── remote/
│       │   ├── api_service.dart
│       │   ├── auth_api.dart
│       │   ├── user_api.dart
│       │   ├── academic_api.dart
│       │   ├── payment_api.dart
│       │   ├── menu_api.dart
│       │   └── chat_api.dart
│       └── local/
│           └── local_storage.dart
├── presentation/
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   └── children_list_screen.dart
│   │   ├── academics/
│   │   │   ├── grades_screen.dart
│   │   │   ├── schedule_screen.dart
│   │   │   ├── assignments_screen.dart
│   │   │   └── attendance_screen.dart
│   │   ├── payments/
│   │   │   ├── payments_screen.dart
│   │   │   └── payment_method_screen.dart
│   │   ├── menu/
│   │   │   └── daily_menu_screen.dart
│   │   ├── chat/
│   │   │   ├── chat_list_screen.dart
│   │   │   └── chat_room_screen.dart
│   │   └── rating/
│   │       └── rating_screen.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_app_bar.dart
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── loading_indicator.dart
│   │   │   └── error_widget.dart
│   │   ├── profile/
│   │   │   ├── profile_header_card.dart
│   │   │   ├── child_card.dart
│   │   │   └── balance_card.dart
│   │   ├── grades/
│   │   │   ├── grade_card.dart
│   │   │   └── rating_header.dart
│   │   ├── schedule/
│   │   │   └── schedule_card.dart
│   │   ├── assignments/
│   │   │   └── assignment_card.dart
│   │   ├── payments/
│   │   │   └── payment_card.dart
│   │   ├── menu/
│   │   │   └── meal_card.dart
│   │   ├── chat/
│   │   │   ├── message_bubble.dart
│   │   │   └── conversation_card.dart
│   │   └── bottom_nav_bar.dart
│   └── providers/
│       ├── auth_provider.dart
│       ├── user_provider.dart
│       ├── academic_provider.dart
│       ├── payment_provider.dart
│       ├── menu_provider.dart
│       └── chat_provider.dart
└── main.dart
```

### **Folder yaratish uchun bash script:**

`lib/` papkasida yangi fayllar yarating:

```bash
# core/constants/
mkdir -p lib/core/constants
touch lib/core/constants/api_constants.dart
touch lib/core/constants/app_colors.dart
touch lib/core/constants/app_strings.dart
touch lib/core/constants/app_text_styles.dart
touch lib/core/constants/storage_keys.dart
touch lib/core/constants/app_routes.dart

# core/theme/
mkdir -p lib/core/theme
touch lib/core/theme/app_theme.dart
touch lib/core/theme/theme_config.dart
touch lib/core/theme/theme_colors.dart
touch lib/core/theme/dynamic_theme_provider.dart

# core/network/
mkdir -p lib/core/network
touch lib/core/network/dio_client.dart
touch lib/core/network/api_interceptors.dart
touch lib/core/network/api_error_handler.dart
touch lib/core/network/network_info.dart

# core/storage/
mkdir -p lib/core/storage
touch lib/core/storage/secure_storage.dart
touch lib/core/storage/shared_prefs_service.dart

# core/utils/
mkdir -p lib/core/utils
touch lib/core/utils/validators.dart
touch lib/core/utils/date_formatter.dart
touch lib/core/utils/file_utils.dart
touch lib/core/utils/logger.dart

# core/error/
mkdir -p lib/core/error
touch lib/core/error/exceptions.dart
touch lib/core/error/failures.dart
touch lib/core/error/error_handler.dart

# core/routing/
mkdir -p lib/core/routing
touch lib/core/routing/app_router.dart
touch lib/core/routing/route_names.dart

# data/models/
mkdir -p lib/data/models
touch lib/data/models/user_model.dart
touch lib/data/models/child_model.dart
touch lib/data/models/grade_model.dart
touch lib/data/models/schedule_model.dart
touch lib/data/models/assignment_model.dart
touch lib/data/models/payment_model.dart
touch lib/data/models/menu_model.dart
touch lib/data/models/chat_model.dart
touch lib/data/models/notification_model.dart

# data/repositories/
mkdir -p lib/data/repositories
touch lib/data/repositories/auth_repository.dart
touch lib/data/repositories/user_repository.dart
touch lib/data/repositories/academic_repository.dart
touch lib/data/repositories/payment_repository.dart
touch lib/data/repositories/menu_repository.dart
touch lib/data/repositories/chat_repository.dart
touch lib/data/repositories/school_repository.dart

# data/datasources/remote/
mkdir -p lib/data/datasources/remote
touch lib/data/datasources/remote/api_service.dart
touch lib/data/datasources/remote/auth_api.dart
touch lib/data/datasources/remote/user_api.dart
touch lib/data/datasources/remote/academic_api.dart
touch lib/data/datasources/remote/payment_api.dart
touch lib/data/datasources/remote/menu_api.dart
touch lib/data/datasources/remote/chat_api.dart

# data/datasources/local/
mkdir -p lib/data/datasources/local
touch lib/data/datasources/local/local_storage.dart

# presentation/screens/auth/
mkdir -p lib/presentation/screens/auth
touch lib/presentation/screens/auth/login_screen.dart
touch lib/presentation/screens/auth/register_screen.dart
touch lib/presentation/screens/auth/forgot_password_screen.dart

# presentation/screens/splash/
mkdir -p lib/presentation/screens/splash
touch lib/presentation/screens/splash/splash_screen.dart

# presentation/screens/home/
mkdir -p lib/presentation/screens/home
touch lib/presentation/screens/home/home_screen.dart

# presentation/screens/profile/
mkdir -p lib/presentation/screens/profile
touch lib/presentation/screens/profile/profile_screen.dart
touch lib/presentation/screens/profile/children_list_screen.dart

# presentation/screens/academics/
mkdir -p lib/presentation/screens/academics
touch lib/presentation/screens/academics/grades_screen.dart
touch lib/presentation/screens/academics/schedule_screen.dart
touch lib/presentation/screens/academics/assignments_screen.dart
touch lib/presentation/screens/academics/attendance_screen.dart

# presentation/screens/payments/
mkdir -p lib/presentation/screens/payments
touch lib/presentation/screens/payments/payments_screen.dart
touch lib/presentation/screens/payments/payment_method_screen.dart

# presentation/screens/menu/
mkdir -p lib/presentation/screens/menu
touch lib/presentation/screens/menu/daily_menu_screen.dart

# presentation/screens/chat/
mkdir -p lib/presentation/screens/chat
touch lib/presentation/screens/chat/chat_list_screen.dart
touch lib/presentation/screens/chat/chat_room_screen.dart

# presentation/screens/rating/
mkdir -p lib/presentation/screens/rating
touch lib/presentation/screens/rating/rating_screen.dart

# presentation/widgets/common/
mkdir -p lib/presentation/widgets/common
touch lib/presentation/widgets/common/custom_app_bar.dart
touch lib/presentation/widgets/common/custom_button.dart
touch lib/presentation/widgets/common/custom_text_field.dart
touch lib/presentation/widgets/common/loading_indicator.dart
touch lib/presentation/widgets/common/error_widget.dart

# presentation/widgets/ (other)
mkdir -p lib/presentation/widgets/profile
mkdir -p lib/presentation/widgets/grades
mkdir -p lib/presentation/widgets/schedule
mkdir -p lib/presentation/widgets/assignments
mkdir -p lib/presentation/widgets/payments
mkdir -p lib/presentation/widgets/menu
mkdir -p lib/presentation/widgets/chat
touch lib/presentation/widgets/bottom_nav_bar.dart

# presentation/providers/
mkdir -p lib/presentation/providers
touch lib/presentation/providers/auth_provider.dart
touch lib/presentation/providers/user_provider.dart
touch lib/presentation/providers/academic_provider.dart
touch lib/presentation/providers/payment_provider.dart
touch lib/presentation/providers/menu_provider.dart
touch lib/presentation/providers/chat_provider.dart

# main.dart
touch lib/main.dart
```

**Checklist:**
- [ ] Barcha folderlar yaratildi
- [ ] Barcha fayllar yaratildi (bo'sh, keyinchalik to'ldiriladi)
- [ ] VS Code / Android Studio da folder structure ko'rinmoqda

---

## ✅ TASK 3: PUBSPEC.YAML KONFIGURATSIYASI (45 daqiqa)

### **3.1 pubspec.yaml ni ochish va to'ldirish:**

`pubspec.yaml` faylini to'liq quyidagi kontent bilan almashtiring:

```yaml
name: parent_school_app
description: "Ota-onalar uchun maktab ilovasi - farzandlarning o'qish jarayonini kuzatish"
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # UI Components
  cupertino_icons: ^1.0.6
  flutter_svg: ^2.0.10
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  flutter_spinkit: ^5.2.1
  
  # State Management
  provider: ^6.1.2
  
  # Network & API
  dio: ^5.4.3+1
  retrofit: ^4.1.0
  pretty_dio_logger: ^1.3.1
  connectivity_plus: ^6.0.3
  
  # Local Storage
  shared_preferences: ^2.2.3
  flutter_secure_storage: ^9.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Navigation
  go_router: ^14.2.0
  
  # Forms & Validation
  flutter_form_builder: ^9.3.0
  form_builder_validators: ^10.0.1
  
  # Date & Time
  intl: ^0.19.0
  table_calendar: ^3.1.2
  
  # File Handling
  file_picker: ^8.0.6
  image_picker: ^1.1.2
  path_provider: ^2.1.3
  mime: ^1.0.5
  open_file: ^3.3.2
  
  # QR Code
  qr_code_scanner: ^1.0.1
  qr_flutter: ^4.1.0
  
  # Social Auth
  google_sign_in: ^6.2.1
  
  # Charts & Visualization
  fl_chart: ^0.68.0
  percent_indicator: ^4.2.3
  
  # Notifications
  firebase_core: ^2.32.0
  firebase_messaging: ^14.9.4
  flutter_local_notifications: ^17.2.1+2
  
  # Chat
  dash_chat_2: ^0.0.21
  file_icon: ^1.0.1
  
  # Utils
  url_launcher: ^6.3.0
  permission_handler: ^11.3.1
  package_info_plus: ^8.0.0
  device_info_plus: ^10.1.2
  
  # Error Handling & Utilities
  dartz: ^0.10.1
  equatable: ^2.0.5
  json_annotation: ^4.9.0
  logger: ^2.3.0
  
  # UI Enhancements
  flutter_slidable: ^3.1.1
  pull_to_refresh: ^2.0.0
  animations: ^2.0.11
  lottie: ^3.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Linting
  flutter_lints: ^4.0.0
  
  # Code Generation
  build_runner: ^2.4.11
  retrofit_generator: ^8.1.2
  json_serializable: ^6.8.0
  hive_generator: ^2.0.1

flutter:
  uses-material-design: true

  # Assets
  # assets:
  #   - assets/images/
  #   - assets/icons/
  #   - assets/animations/
  
  # Fonts
  # fonts:
  #   - family: Roboto
  #     fonts:
  #       - asset: assets/fonts/Roboto-Regular.ttf
  #       - asset: assets/fonts/Roboto-Bold.ttf
  #         weight: 700
```

### **3.2 Dependencies install qilish:**

```bash
flutter pub get
```

Bu 2-3 daqiqa davom etishi mumkin.

### **3.3 Packages tekshirish:**

```bash
flutter pub outdated
# Hamma paketlar qanday versiyada ekanligini ko'rsatadi
```

**Checklist:**
- [ ] pubspec.yaml to'ldirildi
- [ ] `flutter pub get` muvaffaqiyatli bajarildi
- [ ] Hech qanday error yo'q
- [ ] VS Code da packages import qilish mumkin

---

## ✅ TASK 4: CORE CONSTANTS FAYLLARINI TO'LDIRISH (1 soat)

### **4.1 API Constants (`lib/core/constants/api_constants.dart`):**

```dart
/// API endpoints va konfiguratsiyalar
class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://ranchschool.izlash.uz/api';
  static const String baseUrlDev = 'https://dev.ranchschool.izlash.uz/api'; // Development
  
  // Timeout durations
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  
  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String googleAuth = '/auth/google';
  
  // User Endpoints
  static const String profile = '/parent/profile';
  static const String updateProfile = '/parent/profile';
  static const String children = '/parent/children';
  static String childDetails(int id) => '/parent/children/$id';
  
  // School Endpoints
  static const String schoolSettings = '/school/settings';
  static const String schoolTheme = '/school/theme';
  
  // Academic Endpoints
  static String grades(int childId) => '/parent/children/$childId/grades';
  static String schedule(int childId) => '/parent/children/$childId/schedule';
  static String assignments(int childId) => '/parent/children/$childId/assignments';
  static String attendance(int childId) => '/parent/children/$childId/attendance';
  static String rating(int childId) => '/parent/children/$childId/rating';
  
  // Assignment Endpoints
  static String assignmentDetails(int id) => '/assignments/$id';
  static String submitAssignment(int id) => '/assignments/$id/submit';
  static String uploadAssignmentFile(int id) => '/assignments/$id/upload';
  
  // Payment Endpoints
  static const String balance = '/parent/balance';
  static const String contract = '/parent/contract';
  static const String paymentHistory = '/parent/payments/history';
  static const String createPayment = '/parent/payments/create';
  static const String paymentMethods = '/payments/methods';
  
  // Menu Endpoints
  static const String dailyMenu = '/menu/daily';
  static const String weeklyMenu = '/menu/weekly';
  
  // Chat Endpoints
  static const String conversations = '/chat/conversations';
  static String messages(int conversationId) => '/chat/$conversationId/messages';
  static String sendMessage(int conversationId) => '/chat/$conversationId/send';
  static const String uploadChatFile = '/chat/upload';
  
  // Notification Endpoints
  static const String notifications = '/notifications';
  static String markAsRead(int id) => '/notifications/$id/read';
  static const String saveFcmToken = '/notifications/token';
  
  // Rating Endpoints
  static String classRating(int classId) => '/rating/class/$classId';
  static const String schoolRating = '/rating/school';
  
  // File Upload
  static const String upload = '/upload';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
```

### **4.2 App Colors (`lib/core/constants/app_colors.dart`):**

```dart
import 'package:flutter/material.dart';

/// Default ranglar (Dynamic theme kelganda override bo'ladi)
class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2952CC);
  static const Color darkBlue = Color(0xFF1C3FAA);
  static const Color lightBlue = Color(0xFF5B8DEE);
  static const Color secondaryBlue = Color(0xFF5B8DEE);
  
  // Status Colors
  static const Color success = Color(0xFF00C48C);
  static const Color warning = Color(0xFFFFB800);
  static const Color danger = Color(0xFFFF5757);
  static const Color info = Color(0xFF00B8D9);
  
  // Grade Colors
  static const Color gradeExcellent = Color(0xFF00C48C); // 5 baho
  static const Color gradeGood = Color(0xFFFFB800);      // 4 baho
  static const Color gradeAverage = Color(0xFFFF9F43);   // 3 baho
  static const Color gradePoor = Color(0xFFFF5757);      // 2 baho va past
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFFE8EBF0);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textHint = Color(0xFFA0AEC0);
  static const Color textDisabled = Color(0xFFCBD5E0);
  
  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFFCBD5E0);
  static const Color divider = Color(0xFFEDF2F7);
  
  // Accent Colors (for buttons, highlights)
  static const Color accentGreen = Color(0xFF00C48C);
  static const Color accentOrange = Color(0xFFFFA726);
  static const Color accentPurple = Color(0xFF9C27B0);
  
  // Shadow
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  
  // Transparent
  static const Color transparent = Color(0x00000000);
}
```

### **4.3 App Strings (`lib/core/constants/app_strings.dart`):**

```dart
/// Ilovadagi barcha static matnlar
class AppStrings {
  // App Info
  static const String appName = 'Parent School App';
  static const String appVersion = '1.0.0';
  
  // Auth
  static const String login = 'Kirish';
  static const String register = 'Ro\'yxatdan o\'tish';
  static const String logout = 'Chiqish';
  static const String username = 'Foydalanuvchi nomi';
  static const String phone = 'Telefon raqami';
  static const String password = 'Parol';
  static const String confirmPassword = 'Parolni tasdiqlang';
  static const String forgotPassword = 'Parolni unutdingizmi?';
  static const String rememberMe = 'Meni eslab qol';
  static const String loginWithGoogle = 'Google orqali kirish';
  static const String loginWithQr = 'QR kod orqali kirish';
  static const String welcome = 'Xush kelibsiz!';
  static const String welcomeBack = 'Qaytganingizdan xursandmiz!';
  
  // Navigation
  static const String home = 'Asosiy';
  static const String academics = 'Ta\'lim';
  static const String menu = 'Oziqlanish';
  static const String payments = 'To\'lovlar';
  static const String profile = 'Profil';
  
  // Profile
  static const String myProfile = 'Mening profilim';
  static const String children = 'Farzandlar';
  static const String balance = 'Balans';
  static const String settings = 'Sozlamalar';
  static const String personalInfo = 'Shaxsiy ma\'lumotlar';
  static const String changePassword = 'Parolni o\'zgartirish';
  
  // Academics
  static const String grades = 'Baholar';
  static const String schedule = 'Dars jadvali';
  static const String assignments = 'Uyga vazifalar';
  static const String attendance = 'Davomat';
  static const String rating = 'Reyting';
  
  // Payments
  static const String paymentHistory = 'To\'lovlar tarixi';
  static const String makePayment = 'To\'lov qilish';
  static const String contractNumber = 'Shartnoma raqami';
  static const String debt = 'Qarzingiz';
  static const String nextPayment = 'Keyingi to\'lov';
  
  // Menu
  static const String dailyMenu = 'Kunlik menyu';
  static const String weeklyMenu = 'Haftalik menyu';
  static const String breakfast = 'Nonushta';
  static const String lunch = 'Tushlik';
  static const String snack = 'Peshim choy';
  static const String calories = 'Kaloriya';
  static const String protein = 'Oqsil';
  static const String fat = 'Yog\'';
  
  // Chat
  static const String chat = 'Chat';
  static const String messages = 'Xabarlar';
  static const String sendMessage = 'Xabar yuborish';
  static const String typeMessage = 'Xabar yozing...';
  static const String attachFile = 'Fayl biriktirish';
  
  // Common
  static const String save = 'Saqlash';
  static const String cancel = 'Bekor qilish';
  static const String delete = 'O\'chirish';
  static const String edit = 'Tahrirlash';
  static const String submit = 'Yuborish';
  static const String next = 'Keyingisi';
  static const String back = 'Orqaga';
  static const String yes = 'Ha';
  static const String no = 'Yo\'q';
  static const String ok = 'OK';
  static const String close = 'Yopish';
  static const String search = 'Qidirish';
  static const String filter = 'Filtr';
  static const String sort = 'Saralash';
  static const String select = 'Tanlash';
  static const String selectAll = 'Hammasini tanlash';
  static const String clear = 'Tozalash';
  static const String apply = 'Qo\'llash';
  static const String retry = 'Qayta urinish';
  static const String refresh = 'Yangilash';
  
  // Status
  static const String loading = 'Yuklanmoqda...';
  static const String success = 'Muvaffaqiyatli';
  static const String error = 'Xatolik';
  static const String noData = 'Ma\'lumot yo\'q';
  static const String noInternet = 'Internet bilan aloqa yo\'q';
  
  // Errors
  static const String errorGeneric = 'Nimadir xato ketdi';
  static const String errorNetwork = 'Tarmoq bilan bog\'lanishda xatolik';
  static const String errorServer = 'Server xatoligi';
  static const String errorAuth = 'Autentifikatsiya xatosi';
  static const String errorValidation = 'Ma\'lumotlar to\'liq emas';
  
  // Validation
  static const String fieldRequired = 'Bu maydon to\'ldirilishi shart';
  static const String invalidEmail = 'Email noto\'g\'ri';
  static const String invalidPhone = 'Telefon raqami noto\'g\'ri';
  static const String passwordTooShort = 'Parol juda qisqa (minimum 6 ta belgi)';
  static const String passwordsDoNotMatch = 'Parollar mos kelmayapti';
}
```

### **4.4 Storage Keys (`lib/core/constants/storage_keys.dart`):**

```dart
/// Local storage key nomlari
class StorageKeys {
  // Auth
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';
  
  // User
  static const String userProfile = 'user_profile';
  static const String selectedChildId = 'selected_child_id';
  
  // Theme
  static const String themeData = 'theme_data';
  static const String isDarkMode = 'is_dark_mode';
  
  // Settings
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String fcmToken = 'fcm_token';
  
  // Cache
  static const String cacheGrades = 'cache_grades';
  static const String cacheSchedule = 'cache_schedule';
  static const String cacheMenu = 'cache_menu';
  static const String cacheExpiry = 'cache_expiry';
  
  // First Launch
  static const String isFirstLaunch = 'is_first_launch';
  static const String onboardingCompleted = 'onboarding_completed';
}
```

### **4.5 App Text Styles (`lib/core/constants/app_text_styles.dart`):**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Ilovadagi barcha text stylelar
class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  // Button
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );
  
  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.3,
  );
  
  // Label
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );
  
  // Input
  static const TextStyle input = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle inputHint = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
    height: 1.5,
  );
  
  // Special
  static const TextStyle price = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle grade = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  // White variants
  static const TextStyle h1White = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    height: 1.2,
  );
  
  static const TextStyle h2White = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    height: 1.3,
  );
  
  static const TextStyle bodyWhite = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
    height: 1.5,
  );
}
```

### **4.6 Route Names (`lib/core/routing/route_names.dart`):**

```dart
/// Route nomlari
class RouteNames {
  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Main Navigation
  static const String home = '/home';
  static const String mainNavigator = '/main';
  
  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String childrenList = '/profile/children';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';
  
  // Academics
  static const String grades = '/academics/grades';
  static const String schedule = '/academics/schedule';
  static const String assignments = '/academics/assignments';
  static const String assignmentDetails = '/academics/assignments/:id';
  static const String attendance = '/academics/attendance';
  static const String rating = '/academics/rating';
  
  // Payments
  static const String payments = '/payments';
  static const String paymentHistory = '/payments/history';
  static const String paymentMethod = '/payments/method';
  
  // Menu
  static const String menu = '/menu';
  static const String menuWeekly = '/menu/weekly';
  
  // Chat
  static const String chatList = '/chat';
  static const String chatRoom = '/chat/:id';
  
  // Notifications
  static const String notifications = '/notifications';
}
```

**Checklist:**
- [ ] Barcha constants fayllar to'ldirildi
- [ ] Hech qanday syntax error yo'q
- [ ] Fayllar import qilish mumkin
- [ ] VS Code autocomplete ishlayapti

---

## ✅ TASK 5: MAIN.DART BOSHLANG'ICH VERSIYA (30 daqiqa)

### **5.1 lib/main.dart ni to'ldirish:**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Initialize services (SharedPreferences, SecureStorage, etc.)
  // await SharedPrefsService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.secondaryBlue,
          error: AppColors.danger,
          background: AppColors.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: AppColors.cardBackground,
        ),
      ),
      home: const InitialScreen(),
    );
  }
}

/// Vaqtinchalik ekran (keyinchalik Splash/Login bilan almashtiriladi)
class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 100,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.welcome,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Project structure tayyor!\nDeveloperlar ish boshlashlari mumkin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Login
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Login screen hali yaratilmagan'),
                  ),
                );
              },
              child: const Text('Kirish'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### **5.2 Test qilish:**

```bash
flutter run
```

Ilovani ishga tushiring va "Welcome" ekrani ko'rinishi kerak.

**Checklist:**
- [ ] main.dart yaratildi
- [ ] App ishlayapti
- [ ] Welcome ekrani ko'rinmoqda
- [ ] Theme qo'llanmoqda (ko'k rang)
- [ ] Button bosilganda SnackBar chiqmoqda

---

## ✅ TASK 6: GIT REPOSITORY SOZLASH (30 daqiqa)

### **6.1 .gitignore faylini tekshirish:**

Flutter default `.gitignore` mavjud bo'lishi kerak. Tekshiring:

```bash
cat .gitignore
```

Agar mavjud bo'lmasa yoki to'liq emas bo'lsa, quyidagini qo'shing:

```.gitignore
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# VS Code related
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release

# iOS related
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral/
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# Environment files
.env
.env.local
.env.*.local

# Firebase
google-services.json
GoogleService-Info.plist
```

### **6.2 Git repository yaratish:**

```bash
git init
git add .
git commit -m "Initial project setup: folder structure, dependencies, constants"
```

### **6.3 GitHub repository yaratish (agar kerak bo'lsa):**

GitHub da yangi repository yarating va quyidagilarni bajaring:

```bash
git remote add origin https://github.com/USERNAME/parent-school-app.git
git branch -M main
git push -u origin main
```

### **6.4 Develop branch yaratish:**

```bash
git checkout -b develop
git push -u origin develop
```

**Checklist:**
- [ ] .gitignore to'liq
- [ ] Git initialized
- [ ] Initial commit qilindi
- [ ] GitHub repo yaratildi (agar kerak bo'lsa)
- [ ] main va develop branch mavjud

---

## ✅ TASK 7: README.MD YOZISH (30 daqiqa)

### **7.1 README.md yaratish:**

Loyiha root papkasida `README.md` fayl yarating va quyidagi kontent bilan to'ldiring:

```markdown
# Parent School App

Ota-onalar uchun maktab ilovasi - farzandlarning o'qish jarayonini kuzatish, baholar, to'lovlar, ovqatlanish menyusi va o'qituvchilar bilan muloqot.

## 📱 Loyiha Haqida

Bu ilova ota-onalarga quyidagi imkoniyatlarni beradi:

- 📊 Farzandlarning baholarini ko'rish
- 📅 Dars jadvalini kuzatish
- 📝 Uyga vazifalarni ko'rish va topshirish
- 💳 To'lovlar tarixi va balansni boshqarish
- 🍽️ Kunlik/haftalik ovqatlanish menyusini ko'rish
- 💬 O'qituvchilar bilan chat orqali muloqot
- 🏆 Farzandlarning reyting va davomatini kuzatish
- 🔔 Push bildirishnomalar orqali yangiliklar

## 🛠️ Texnologiyalar

- **Framework:** Flutter 3.16+
- **Language:** Dart 3.0+
- **State Management:** Provider
- **Network:** Dio + Retrofit
- **Local Storage:** Hive + Shared Preferences + Secure Storage
- **Navigation:** GoRouter
- **Architecture:** Clean Architecture

## 📁 Loyiha Strukturasi

```
lib/
├── core/               # Core funksiyalar, utils, constants
├── data/               # Data layer: models, repositories, API
└── presentation/       # UI layer: screens, widgets, providers
```

## 🚀 Boshlash

### Talablar

- Flutter SDK 3.16.0 yoki yuqori
- Dart SDK 3.0.0 yoki yuqori
- Android Studio / VS Code
- Android SDK (Android) yoki Xcode (iOS)

### O'rnatish

1. Repository ni clone qiling:
```bash
git clone https://github.com/USERNAME/parent-school-app.git
cd parent-school-app
```

2. Dependencies ni o'rnating:
```bash
flutter pub get
```

3. Ilovani ishga tushiring:
```bash
flutter run
```

## 🔑 API Configuration

Backend API: `https://ranchschool.izlash.uz/api`

API endpoints `lib/core/constants/api_constants.dart` faylida belgilangan.

## 👥 Jamoa

- **Developer 1:** UI/UX Implementation
- **Developer 2:** Core Infrastructure & Backend Integration

## 📝 Development Workflow

1. `develop` branchdan feature branch yaratish:
```bash
git checkout develop
git checkout -b feature/dev1-login-screen
```

2. O'zgarishlarni commit qilish:
```bash
git add .
git commit -m "[DEV1] feat: Add login screen"
```

3. Push va Pull Request yaratish:
```bash
git push origin feature/dev1-login-screen
```

## 🧪 Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

## 📦 Build

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

## 📄 License

This project is proprietary and confidential.

## 📞 Contact

Savollar bo'lsa, jamoa bilan bog'laning.
```

**Checklist:**
- [ ] README.md yaratildi
- [ ] To'liq ma'lumot yozildi
- [ ] Markdown formatda to'g'ri

---

## ✅ TASK 8: ANDROID KONFIGURATSIYASI (30 daqiqa)

### **8.1 android/app/build.gradle ni yangilash:**

`android/app/build.gradle` faylini oching va quyidagilarni tekshiring/yangilang:

```gradle
android {
    namespace "uz.ranchschool.parent_school_app"
    compileSdk 34
    
    defaultConfig {
        applicationId "uz.ranchschool.parent_school_app"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
        
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### **8.2 AndroidManifest.xml ga permissions qo'shish:**

`android/app/src/main/AndroidManifest.xml` ga quyidagi permissionlarni qo'shing:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    
    <application
        android:label="Parent School"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        <!-- Rest of manifest -->
    </application>
</manifest>
```

**Checklist:**
- [ ] build.gradle yangilandi
- [ ] AndroidManifest.xml permissions qo'shildi
- [ ] compileSdk 34
- [ ] minSdk 21

---

## ✅ TASK 9: FINAL TESTING VA COMMIT (30 daqiqa)

### **9.1 Full clean build:**

```bash
flutter clean
flutter pub get
flutter analyze
```

`flutter analyze` hech qanday error ko'rsatmasligi kerak.

### **9.2 Run qilish:**

```bash
flutter run --release
```

Release mode da ishlashini tekshiring.

### **9.3 Final commit:**

```bash
git add .
git commit -m "Complete initial setup: dependencies, structure, constants, Android config"
git push origin develop
```

**Checklist:**
- [ ] `flutter analyze` hech qanday error yo'q
- [ ] Release mode da ishlayapti
- [ ] Final commit qilindi
- [ ] GitHub da kod ko'rinmoqda

---

## 📋 TOPSHIRISH CHECKLIST

Barcha quyidagilar tayyor bo'lishi kerak:

### Project Setup:
- [ ] Flutter project yaratildi
- [ ] Folder structure to'liq
- [ ] pubspec.yaml to'liq dependencies bilan
- [ ] `flutter pub get` muvaffaqiyatli

### Constants:
- [ ] api_constants.dart to'liq
- [ ] app_colors.dart to'liq
- [ ] app_strings.dart to'liq
- [ ] app_text_styles.dart to'liq
- [ ] storage_keys.dart to'liq
- [ ] route_names.dart to'liq

### Configuration:
- [ ] main.dart ishlayapti
- [ ] Theme qo'llanmoqda
- [ ] Android config tayyor
- [ ] .gitignore to'liq

### Git:
- [ ] Git initialized
- [ ] Initial commits qilindi
- [ ] GitHub repository mavjud
- [ ] main va develop branches mavjud

### Documentation:
- [ ] README.md to'liq
- [ ] Code comments yozilgan

### Testing:
- [ ] App ishga tushmoqda
- [ ] Hech qanday compile error yo'q
- [ ] `flutter analyze` tozalangan

---

## 🎯 KEYINGI QADAMLAR (Developer 1 va 2 uchun)

### Developer 1 boshlashi mumkin:
1. `feature/dev1-auth-screens` branch yaratish
2. Login screen UI yaratish
3. Mock data bilan ishlash

### Developer 2 boshlashi mumkin:
1. `feature/dev2-core-setup` branch yaratish
2. DioClient yaratish
3. API service yaratish
4. Auth repository yaratish

---

## 📞 SAVOLLAR?

Agar biror narsa tushunarsiz bo'lsa yoki muammo bo'lsa:

1. README.md ni o'qing
2. Task dokumentatsiyasini qayta ko'rib chiqing
3. Jamoa bilan bog'laning

---

## ⏱️ VAQT TAXMINLARI

| Task | Vaqt |
|------|------|
| 1. Flutter Project Yaratish | 30 min |
| 2. Folder Structure | 30 min |
| 3. pubspec.yaml | 45 min |
| 4. Constants Fayllar | 1 soat |
| 5. main.dart | 30 min |
| 6. Git Setup | 30 min |
| 7. README | 30 min |
| 8. Android Config | 30 min |
| 9. Testing & Final Commit | 30 min |
| **JAMI** | **~6 soat** |

---

**OMAD! 🚀**

Barcha tasklar tugagach, developerlar parallel ishlashni boshlashlari mumkin!
# Parent School App

Ota-onalar uchun maktab ilovasi — farzandlarning o'qish jarayonini kuzatish, to'lovlarni boshqarish, o'qituvchilar bilan muloqot qilish.

## Texnologiyalar

- **Flutter** (Dart)
- **State Management:** Provider
- **Navigation:** GoRouter
- **HTTP Client:** Dio
- **Local Storage:** SharedPreferences + FlutterSecureStorage
- **API:** [School API (Tenant)](https://ranchschool.izlash.uz/docs/tenant)

## Loyiha Strukturasi

```
lib/
├── core/                  # Umumiy (har ikki developer ishlatadi)
│   ├── constants/         # API, ranglar, matnlar, stillar
│   ├── network/           # Dio client, error handler
│   ├── storage/           # Token, SharedPrefs
│   ├── utils/             # Validators, date formatter
│   ├── error/             # Exceptions, failures
│   ├── routing/           # GoRouter, route nomlari
│   └── theme/             # Material theme
├── data/                  # Dev2 mas'uliyati
│   ├── models/            # JSON model larlar
│   ├── repositories/      # Business logic
│   └── datasources/       # API calls, local cache
├── presentation/          # Dev1 mas'uliyati (screenlar)
│   ├── screens/           # Auth, Home, Profile, Payments, Menu, ...
│   ├── widgets/           # Umumiy va maxsus widgetlar
│   └── providers/         # Dev2 — state management
└── main.dart              # App entry point
```

## Ishga tushirish

```bash
# Flutter o'rnatilgan bo'lishi kerak
flutter pub get
flutter run
```

## Git Workflow

```bash
# Yangi feature boshlash
git checkout -b feature/login-screen

# Commit
git add .
git commit -m "feat: login screen UI"

# Push
git push origin feature/login-screen
```

## Developer Vazifalar

- **Dev1 (UI):** `dev1_tasks.md` ni ko'ring
- **Dev2 (API):** `dev2_tasks.md` ni ko'ring

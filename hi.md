# OTA-ONALAR UCHUN MOBIL ILOVA - ISH REJASI
## Flutter (Android) Development Plan

---

## 📋 LOYIHA HAQIDA

**Maqsad:** Ota-onalar farzandlarining o'qish jarayonini kuzatish, to'lovlarni boshqarish, o'qituvchilar bilan muloqot qilish uchun mobil ilova yaratish.

**Texnologiya:** Flutter (Android-first, keyinchalik iOS)

**API:** School API (Tenant) - https://ranchschool.izlash.uz/docs/tenant

---

## 🎯 ASOSIY FUNKSIYALAR (Rasmlar asosida)

### 1. **AUTENTIFIKATSIYA**
- Login ekrani (telefon/username va parol)
- Google orqali kirish
- QR kod orqali kirish
- Ro'yxatdan o'tish
- Parolni tiklash

### 2. **PROFIL BOSHQARUVI**
- Shaxsiy ma'lumotlar
- Farzandlar ro'yxati
- Balans ko'rsatkichi
- Sozlamalar
- Chat va bildirishnomalar
- Chiqish

### 3. **TO'LOVLAR TIZIMI**
- Balansni ko'rish
- To'lovlar tarixi
- To'lov qilish (PayMe, Click, va boshqalar)
- Qarzlik/kredit ko'rsatkichi
- SHARTNOMA RAQAMI ko'rsatish
- Oylik to'lovlar jadvali

### 4. **OZIQLANISH (MENYU)**
- Kunlik menyu
- Haftalik kalendar
- Ovqat tarkibi (kaloriya, oqsil, yog')
- Ovqat rasmlari
- Nonushta/Tushlik vaqtlari
- Peshim choy/Halol taomlar belgilari

### 5. **TA'LIM VA REYTING**
- Farzandning baholar ro'yxati
- Fan bo'yicha bahollar (Matematika, Ona Tili, Ingliz Tili, Fizika)
- Davomat statistikasi
- Umum reyting (sinfda nechchi o'rinda)
- Jami ballar (score)
- O'rtacha baho

### 6. **DARSLAR JADVALI**
- Bugungi darslar
- Haftalik jadval
- Xona raqami
- Dars vaqti
- O'qituvchi nomi
- Sinf neyting (#3 yoki boshqa)

### 7. **UYGA VAZIFALAR**
- Yangi vazifalar ro'yxati
- Vazifa matni
- Yuborish muddati
- Status (Shashllinch, Jarayonda, Bajarildi)
- Yuborish imkoniyati
- Progress bar
- Haftalik/Oylik filtr

### 8. **CHAT VA BILDIRISHNOMALAR**
- O'qituvchilar bilan chat
- Guruh chatlari
- Fayllar yuborish/qabul qilish
- Bildirishnomalar
- Yangi xabarlar badge

### 9. **YANGILIKLAR/E'LONLAR**
- Maktab yangiliklari
- Tashkil etilayotgan tadbirlar
- Foto/video galereya
- Kategoriyalar (Tushlik, Tashriflar)

### 10. **REYTING TIZIMI**
- Sinf reytingi (podium bilan - 1, 2, 3-o'rin)
- Barcha o'quvchilar reytingi
- Ball va foiz ko'rsatkichlari
- Maktab/Sinfda filtr

---

## 🏗️ ARXITEKTURA VA TUZILMA

### **Tavsiya etilgan arxitektura:**
```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_routes.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── date_formatter.dart
│   │   └── helpers.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── network/
│       ├── dio_client.dart
│       └── api_endpoints.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── child_model.dart
│   │   ├── payment_model.dart
│   │   ├── grade_model.dart
│   │   ├── assignment_model.dart
│   │   ├── menu_model.dart
│   │   ├── schedule_model.dart
│   │   └── chat_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   ├── payment_repository.dart
│   │   ├── academic_repository.dart
│   │   └── chat_repository.dart
│   └── datasources/
│       ├── remote/
│       │   └── api_service.dart
│       └── local/
│           └── shared_prefs_service.dart
├── domain/
│   ├── entities/
│   └── usecases/
├── presentation/
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   └── children_list_screen.dart
│   │   ├── payments/
│   │   │   ├── payments_screen.dart
│   │   │   └── payment_history_screen.dart
│   │   ├── menu/
│   │   │   └── daily_menu_screen.dart
│   │   ├── academics/
│   │   │   ├── grades_screen.dart
│   │   │   ├── schedule_screen.dart
│   │   │   └── assignments_screen.dart
│   │   ├── chat/
│   │   │   ├── chat_list_screen.dart
│   │   │   └── chat_room_screen.dart
│   │   └── rating/
│   │       └── rating_screen.dart
│   ├── widgets/
│   │   ├── custom_app_bar.dart
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── child_selector.dart
│   │   ├── grade_card.dart
│   │   ├── payment_card.dart
│   │   └── bottom_nav_bar.dart
│   └── providers/ (yoki bloc/)
│       ├── auth_provider.dart
│       ├── user_provider.dart
│       ├── payment_provider.dart
│       └── academic_provider.dart
└── main.dart
```

---

## 📦 KERAKLI PAKETLAR

### **pubspec.yaml ga qo'shiladigan asosiy paketlar:**

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1  # yoki flutter_bloc: ^8.1.3
  
  # Network
  dio: ^5.4.0
  retrofit: ^4.0.3
  pretty_dio_logger: ^1.3.1
  
  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI Components
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_spinkit: ^5.2.0
  
  # Navigation
  go_router: ^13.0.0
  
  # Forms & Validation
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0
  
  # Date & Time
  intl: ^0.18.1
  flutter_calendar_carousel: ^2.4.2
  
  # File Handling
  file_picker: ^6.1.1
  image_picker: ^1.0.7
  path_provider: ^2.1.2
  
  # QR Code
  qr_code_scanner: ^1.0.1
  qr_flutter: ^4.1.0
  
  # Social Auth
  google_sign_in: ^6.2.1
  
  # Charts & Graphs
  fl_chart: ^0.66.0
  
  # Notifications
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
  
  # Chat
  dash_chat_2: ^0.0.18
  
  # Utils
  url_launcher: ^6.2.2
  permission_handler: ^11.1.0
  connectivity_plus: ^5.0.2
  
  # Error Handling
  dartz: ^0.10.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  build_runner: ^2.4.7
  retrofit_generator: ^7.0.8
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
  
  # Linting
  flutter_lints: ^3.0.1
```

---

## 🎨 DIZAYN TIZIMI

### **Ranglar (Rasmlardan olingan):**
```dart
class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2952CC);
  static const Color darkBlue = Color(0xFF1C3FAA);
  static const Color lightBlue = Color(0xFF5B8DEE);
  
  // Status Colors
  static const Color success = Color(0xFF00C48C);
  static const Color warning = Color(0xFFFF9F43);
  static const Color danger = Color(0xFFFF5757);
  static const Color info = Color(0xFF00B8D9);
  
  // Grade Colors
  static const Color gradeGreen = Color(0xFF00C48C);
  static const Color gradeYellow = Color(0xFFFFB800);
  static const Color gradeOrange = Color(0xFFFF9F43);
  static const Color gradePurple = Color(0xFF9C27B0);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color border = Color(0xFFE2E8F0);
}
```

### **Typography:**
```dart
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
```

---

## 🔐 API INTEGRATSIYASI

### **Priority API Endpoints (Ota-onalar uchun):**

#### 1. **Authentication**
- `POST /api/auth/login` - Login
- `POST /api/auth/register` - Register
- `POST /api/auth/google` - Google Sign In
- `POST /api/auth/logout` - Logout
- `POST /api/auth/refresh` - Token refresh

#### 2. **User & Children**
- `GET /api/parent/profile` - Parent profile
- `GET /api/parent/children` - Children list
- `GET /api/parent/children/{id}` - Child details

#### 3. **Payments**
- `GET /api/parent/balance` - Balance
- `GET /api/parent/payments/history` - Payment history
- `POST /api/parent/payments/create` - Create payment
- `GET /api/parent/contract` - Contract info

#### 4. **Academics**
- `GET /api/parent/children/{id}/grades` - Grades
- `GET /api/parent/children/{id}/schedule` - Schedule
- `GET /api/parent/children/{id}/assignments` - Assignments
- `GET /api/parent/children/{id}/attendance` - Attendance

#### 5. **Menu**
- `GET /api/menu/daily` - Daily menu
- `GET /api/menu/weekly` - Weekly menu

#### 6. **Rating**
- `GET /api/parent/children/{id}/rating` - Child rating
- `GET /api/rating/class/{classId}` - Class rating

#### 7. **Chat**
- `GET /api/chat/conversations` - Chat list
- `GET /api/chat/{id}/messages` - Messages
- `POST /api/chat/{id}/send` - Send message
- `POST /api/chat/{id}/upload` - Upload file

#### 8. **Notifications**
- `GET /api/notifications` - Notifications
- `PUT /api/notifications/{id}/read` - Mark as read

---

## 📅 ISH REJASI (BOSQICHMA-BOSQICH)

### **BOSQICH 1: LOYIHANI SOZLASH (1-2 kun)**

**1.1 Flutter loyihasini yaratish**
```bash
flutter create parent_school_app
cd parent_school_app
```

**1.2 Kerakli paketlarni o'rnatish**
- `pubspec.yaml` ni to'ldirish
- `flutter pub get`

**1.3 Loyiha strukturasini yaratish**
- Papkalarni yaratish (core, data, presentation)
- Constants fayllarini yaratish

**1.4 Git repository sozlash**
```bash
git init
git add .
git commit -m "Initial project setup"
```

---

### **BOSQICH 2: ASOSIY KONFIGURATSIYALAR (2-3 kun)**

**2.1 API Client sozlash**
- Dio configuratsiya
- Interceptors (token, logging)
- Base URL sozlash

**2.2 State Management sozlash**
- Provider/Bloc sozlash
- Repository pattern yaratish

**2.3 Routing sozlash**
- GoRouter konfiguratsiya
- Route nomlari

**2.4 Theme va Dizayn tizimi**
- AppColors class
- AppTextStyles class
- Custom widgets (Button, TextField, AppBar)

**2.5 Local Storage**
- SharedPreferences setup
- Secure Storage for tokens
- Hive database (agar kerak bo'lsa)

---

### **BOSQICH 3: AUTENTIFIKATSIYA (3-4 kun)**

**3.1 Login Screen**
- UI yaratish (rasm 1 asosida)
- Form validation
- API integration

**3.2 Register Screen**
- UI yaratish
- Form validation
- API integration

**3.3 Social Auth**
- Google Sign In
- QR Code Scanner

**3.4 Token Management**
- Access token saqlash
- Refresh token logic
- Auto-logout

**3.5 Onboarding/Splash Screen**
- Splash animation
- Auto-login check

---

### **BOSQICH 4: ASOSIY NAVIGATION (2-3 kun)**

**4.1 Bottom Navigation Bar**
- 5 ta asosiy tab (Asosiy, Ta'lim, Oziqlanish, To'lovlar, Profil)
- Active/Inactive states
- Badge for notifications

**4.2 App Bar**
- Custom AppBar with user info
- Notification bell
- Child selector dropdown

**4.3 Drawer/Side Menu**
- Menu items
- Logout option

---

### **BOSQICH 5: PROFIL MODULI (3-4 kun)**

**5.1 Profile Screen** (rasm 2 asosida)
- User info card
- Balance display
- Children list
- Settings menu

**5.2 Children Management**
- Children list
- Child selector
- Switch between children

**5.3 Settings**
- Shaxsiy ma'lumotlarni tahrirlash
- Parolni o'zgartirish
- Tilni tanlash
- Bildirishnomalar sozlamalari

**5.4 API Integration**
- GET profile
- GET children list
- UPDATE profile

---

### **BOSQICH 6: TO'LOVLAR MODULI (4-5 kun)**

**6.1 Payments Screen** (rasm 4 asosida)
- Balance card
- Contract number
- Debt display
- Payment button

**6.2 Payment History**
- List view
- Filter by date
- Status indicators (HAQIQATDAGI, MIJASAQATGA, ARXIV)

**6.3 Payment Integration**
- PayMe integration
- Click integration
- Payment success/failure handling

**6.4 API Integration**
- GET balance
- GET payment history
- POST create payment

---

### **BOSQICH 7: OZIQLANISH (MENYU) MODULI (3-4 kun)**

**7.1 Daily Menu Screen** (rasm 5 asosida)
- Calendar view
- Current day highlight
- Meal cards with images

**7.2 Meal Details**
- Image display
- Nutritional info (Kcal, Oqsil, Yog')
- Time display
- Category badges

**7.3 Weekly View**
- Week calendar
- Navigate between days

**7.4 API Integration**
- GET daily menu
- GET weekly menu

---

### **BOSQICH 8: TA'LIM VA REYTING MODULI (5-6 kun)**

**8.1 Grades Screen** (rasm 6 asosida)
- Overall rating (JONY CHORAK x/5.0)
- O'sish foizi
- Subject list with grades
- Progress bars

**8.2 Schedule Screen** (rasm 7 asosida)
- Today's classes
- Time slots
- Room numbers
- Teacher names

**8.3 Attendance**
- Davomat statistikasi
- Calendar view
- Present/Absent days

**8.4 Rating Screen** (rasm 10 asosida)
- Top 3 podium
- Full class ranking
- Score display
- Sinf/Maktab filter

**8.5 API Integration**
- GET grades
- GET schedule
- GET attendance
- GET rating

---

### **BOSQICH 9: UYGA VAZIFALAR MODULI (4-5 kun)**

**9.1 Assignments List** (rasm 8-9 asosida)
- New assignments badge
- Assignment cards
- Status indicators
- Filter (Haftalik/Oylik)

**9.2 Assignment Details**
- Full text
- Deadline
- Submit button
- File upload

**9.3 Assignment Submission**
- Text input
- File picker
- Submit API

**9.4 Progress Tracking**
- Progress bar
- Completion status

**9.5 API Integration**
- GET assignments
- POST submit assignment
- Upload files

---

### **BOSQICH 10: CHAT MODULI (4-5 kun)**

**10.1 Chat List** (rasm 3 asosida)
- Conversations list
- Last message preview
- Unread badge
- Teacher avatars

**10.2 Chat Room**
- Message list
- Send message
- File upload/download
- Real-time updates (WebSocket yoki polling)

**10.3 Group Chats**
- Multiple participants
- Group info

**10.4 File Handling**
- PDF viewer
- Image viewer
- Download files

**10.5 API Integration**
- GET conversations
- GET messages
- POST send message
- Upload files

---

### **BOSQICH 11: BILDIRISHNOMALAR (2-3 kun)**

**11.1 Notification List**
- Notification cards
- Read/Unread status
- Time display

**11.2 Push Notifications**
- Firebase Cloud Messaging setup
- Local notifications
- Notification handling

**11.3 Notification Types**
- New message
- Payment reminder
- Grade posted
- Assignment deadline

**11.4 API Integration**
- GET notifications
- Mark as read

---

### **BOSQICH 12: QIDIRISH VA FILTRLAR (2-3 kun)**

**12.1 Search Functionality**
- Global search
- Search in assignments
- Search in grades

**12.2 Filters**
- Date range
- Subject
- Status
- Child selector

---

### **BOSQICH 13: OFFLINE REJIM VA KESH (3-4 kun)**

**13.1 Caching Strategy**
- API response caching
- Image caching
- Offline data access

**13.2 Sync Logic**
- Background sync
- Conflict resolution

**13.3 Error Handling**
- No internet connection
- Retry mechanism

---

### **BOSQICH 14: TESTING (4-5 kun)**

**14.1 Unit Tests**
- Repository tests
- UseCase tests
- Validators tests

**14.2 Widget Tests**
- Screen tests
- Widget tests

**14.3 Integration Tests**
- End-to-end flows
- API integration tests

**14.4 Manual Testing**
- Full app testing
- Bug fixes

---

### **BOSQICH 15: OPTIMIZATSIYA VA POLISH (3-4 kun)**

**15.1 Performance**
- Image optimization
- List performance (ListView.builder)
- Memory leaks check

**15.2 UI Polish**
- Animations
- Transitions
- Loading states
- Empty states

**15.3 Error Messages**
- User-friendly error messages
- Uzbek localization

**15.4 Accessibility**
- Font sizes
- Color contrast
- Screen reader support

---

### **BOSQICH 16: BUILD VA DEPLOY (2-3 kun)**

**16.1 Android Build**
- App signing
- ProGuard rules
- Build APK/AAB

**16.2 App Icons & Splash**
- Icon generation
- Splash screen

**16.3 Play Store Preparation**
- Screenshots
- Description
- Privacy policy

**16.4 Internal Testing**
- Beta release
- Bug fixes

---

## ⏱️ UMUMIY VAQT TAXMINLARI

| Bosqich | Vaqt (kunlar) | To'plam |
|---------|---------------|---------|
| Bosqich 1: Sozlash | 1-2 | 2 |
| Bosqich 2: Konfiguratsiya | 2-3 | 5 |
| Bosqich 3: Auth | 3-4 | 9 |
| Bosqich 4: Navigation | 2-3 | 12 |
| Bosqich 5: Profil | 3-4 | 16 |
| Bosqich 6: To'lovlar | 4-5 | 21 |
| Bosqich 7: Menyu | 3-4 | 25 |
| Bosqich 8: Ta'lim | 5-6 | 31 |
| Bosqich 9: Vazifalar | 4-5 | 36 |
| Bosqich 10: Chat | 4-5 | 41 |
| Bosqich 11: Notifications | 2-3 | 44 |
| Bosqich 12: Search | 2-3 | 47 |
| Bosqich 13: Offline | 3-4 | 51 |
| Bosqich 14: Testing | 4-5 | 56 |
| Bosqich 15: Polish | 3-4 | 60 |
| Bosqich 16: Deploy | 2-3 | 63 |
| **JAMI** | **~63 kun** | **2-3 oy** |

---

## 🎯 PRIORITETLAR

### **MVP (Minimum Viable Product) - 1-oy**
1. ✅ Authentication (Login/Register)
2. ✅ Profile va Children
3. ✅ Grades va Schedule
4. ✅ Payments (balans ko'rish)
5. ✅ Basic Navigation

### **Version 1.0 - 2-oy**
6. ✅ Assignments
7. ✅ Menu
8. ✅ Chat
9. ✅ Notifications
10. ✅ Rating

### **Version 1.1+ - 3-oy**
11. ✅ Payment integration (PayMe/Click)
12. ✅ Offline mode
13. ✅ Advanced features

---

## 🔧 DEVELOPMENT BEST PRACTICES

### **1. Code Organization**
- Clean Architecture
- SOLID principles
- DRY (Don't Repeat Yourself)

### **2. Git Workflow**
- Feature branches
- Meaningful commit messages
- Regular commits

### **3. Error Handling**
- Try-catch blocks
- User-friendly error messages
- Logging

### **4. Security**
- Token encryption
- Secure API calls
- Input validation

### **5. Performance**
- Lazy loading
- Image optimization
- Efficient state management

---

## 📱 DEVICE TESTING

### **Test qilish kerak bo'lgan qurilmalar:**
- Samsung Galaxy (mid-range)
- Xiaomi Redmi (budget)
- OnePlus (flagship)
- Different screen sizes (small, medium, large)
- Different Android versions (10, 11, 12, 13, 14)

---

## 📚 QOSHIMCHA RESURSLAR

### **Flutter Documentation:**
- https://docs.flutter.dev/

### **State Management:**
- Provider: https://pub.dev/packages/provider
- Bloc: https://bloclibrary.dev/

### **API Integration:**
- Dio: https://pub.dev/packages/dio
- Retrofit: https://pub.dev/packages/retrofit

### **UI Libraries:**
- Flutter Widget Catalog: https://docs.flutter.dev/ui/widgets

---

## ✅ CHECKLIST

### **Har bir bosqichdan keyin tekshirish:**
- [ ] Code review
- [ ] Unit tests yozilgan
- [ ] UI rasmga mos keladi
- [ ] API ishlayapti
- [ ] Error handling qo'shilgan
- [ ] Loading states qo'shilgan
- [ ] Git commit qilingan
- [ ] Documentation yozilgan

---

## 🎨 UI/UX ESLATMALAR

### **Rasmlardan olingan dizayn elementlar:**

1. **Rang sxemasi:**
   - Asosiy: Ko'k (#2952CC)
   - Urg'u: Yashil, Sariq, Orange, Purple
   - Fon: Och kulrang (#F5F7FA)

2. **Card Design:**
   - Rounded corners (16px)
   - Shadow effect
   - White background
   - Blue header sections

3. **Typography:**
   - Bold headers
   - Normal body text
   - Light secondary text

4. **Icons:**
   - Outlined style
   - Consistent size
   - Meaningful colors

5. **Status Indicators:**
   - Color-coded (green=success, red=danger, orange=warning)
   - Clear labels
   - Progress bars

---

## 🚀 DEPLOYMENT STEPS

### **1. Pre-deployment:**
```bash
# Clean build
flutter clean
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### **2. Keystore setup:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### **3. Play Store:**
- Internal testing
- Closed testing (beta)
- Open testing
- Production release

---

## 📊 SUCCESS METRICS

### **Technical KPIs:**
- App startup time < 3s
- API response time < 2s
- Crash rate < 1%
- 60 FPS smooth scrolling

### **User Experience:**
- Login success rate > 95%
- Payment success rate > 90%
- Chat message delivery > 98%

---

## 🎓 OXIRGI MASLAHATLAR

1. **Bosqichma-bosqich ishlang** - Bir vaqtda hammasi emas
2. **Doimiy test qiling** - Har bir feature tayyor bo'lgach test qiling
3. **Code review qiling** - Kodni qayta ko'rib chiqing
4. **Documentation yozing** - Keyingi developer uchun
5. **Git commit qiling** - Har kuni oxirida
6. **API bilan ishlashda** - Xatoliklarni to'g'ri handle qiling
7. **UI/UX ga e'tibor bering** - Foydalanuvchi tajribasini yaxshilang
8. **Performance optimize qiling** - Tezkorlikka e'tibor bering
9. **Security ni unutmang** - Ma'lumotlar xavfsizligi
10. **Foydalanuvchilarni tinglang** - Feedback olish muhim

---

**OMAD! 🎉**

Savollar bo'lsa, so'rasangiz bo'ladi!
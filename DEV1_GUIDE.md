# Dev1 - UI/Screen Development Guide

## 📁 Your Working Directories
```
lib/presentation/
├── screens/          # ✅ YOUR MAIN WORK AREA
│   ├── splash/
│   ├── auth/
│   ├── home/
│   ├── profile/
│   ├── payments/
│   ├── menu/
│   ├── academics/
│   ├── chat/
│   ├── rating/
│   └── notifications/
└── widgets/          # ✅ YOUR REUSABLE COMPONENTS
    ├── common/       # Already exists (buttons, text fields, etc.)
    ├── profile/
    ├── payments/
    ├── menu/
    ├── grades/
    ├── schedule/
    ├── assignments/
    └── chat/
```

## 🎯 Current Sprint: Sprint 1 - Auth Screens (3.5 days)

### Tasks Checklist:
- [ ] `screens/splash/splash_screen.dart` — Logo + auto-login check
- [ ] `screens/auth/login_screen.dart` — Phone/username, password, Google, QR-code
- [ ] `screens/auth/register_screen.dart` — Registration form
- [ ] `screens/auth/forgot_password_screen.dart` — Password recovery

## 🛠️ Resources You Can Use (from `core/`)

### Constants
- `lib/core/constants/app_colors.dart` - Color palette
- `lib/core/constants/app_text_styles.dart` - Text styles
- `lib/core/constants/app_strings.dart` - Static strings
- `lib/core/constants/api_constants.dart` - API endpoints

### Widgets (Already Available)
- `widgets/common/custom_button.dart` - Reusable button
- `widgets/common/custom_text_field.dart` - Input fields
- `widgets/common/loading_indicator.dart` - Loading spinner
- `widgets/common/app_error_widget.dart` - Error display
- `widgets/bottom_nav_bar.dart` - Bottom navigation

### Theme
- `lib/core/theme/app_theme.dart` - Material theme configuration

### Routing
- `lib/core/routing/app_router.dart` - Navigation routes
- `lib/core/routing/route_names.dart` - Route constants

## 📝 Development Guidelines

### 1. Screen Structure Template
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class YourScreen extends ConsumerWidget {
  const YourScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Title'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Your UI here
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. Use Existing Common Widgets
```dart
// Instead of creating new buttons/fields, use:
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
```

### 3. Navigation
```dart
import 'package:go_router/go_router.dart';
import '../../core/routing/route_names.dart';

// Navigate to another screen
context.go(RouteNames.home);

// Navigate with parameters
context.push('${RouteNames.profile}?childId=123');

// Go back
context.pop();
```

### 4. State Management (Riverpod)
Dev2 will provide providers. You'll consume them like this:
```dart
// Watch a provider
final authState = ref.watch(authProvider);

// Read once (in callbacks)
ref.read(authProvider.notifier).login(username, password);

// Listen to changes
ref.listen(authProvider, (previous, next) {
  if (next.isAuthenticated) {
    context.go(RouteNames.home);
  }
});
```

## 🎨 Design Principles

1. **Consistent Spacing**: Use multiples of 8 (8, 16, 24, 32)
2. **Use Theme Colors**: Always use colors from `AppColors` class
3. **Responsive Design**: Test on different screen sizes
4. **Loading States**: Show `LoadingIndicator` during async operations
5. **Error Handling**: Use `AppErrorWidget` for errors
6. **Accessibility**: Add semantic labels for screen readers

## 🚀 Sprint 1 - Getting Started

### Step 1: Create Splash Screen
```dart
// lib/presentation/screens/splash/splash_screen.dart
```
- Show app logo centered
- Check if user is logged in (use provider from Dev2)
- Auto-navigate to Login or Home after 2 seconds

### Step 2: Create Login Screen
```dart
// lib/presentation/screens/auth/login_screen.dart
```
- Phone/Username input field
- Password input field
- Login button
- "Forgot Password?" link
- "Register" link
- Optional: Google sign-in button
- Optional: QR code login button

### Step 3: Create Register Screen
```dart
// lib/presentation/screens/auth/register_screen.dart
```
- Full name field
- Phone number field
- Email field (optional)
- Password field
- Confirm password field
- Register button
- "Already have account?" link

### Step 4: Create Forgot Password Screen
```dart
// lib/presentation/screens/auth/forgot_password_screen.dart
```
- Phone/Email input
- Send OTP button
- OTP verification fields
- New password fields

## 📦 Git Workflow

After completing each screen:
```bash
git add .
git commit -m "feat(auth): add login screen"
git push origin dev1-sprint1
```

## 🤝 Collaboration with Dev2

- **You create**: UI screens and widgets
- **Dev2 creates**: Providers, repositories, API calls
- **You use**: Dev2's providers for state management
- **Dev2 uses**: Your screens in routing

### Communication Points:
1. What data does your screen need? → Tell Dev2
2. What actions can user perform? → Dev2 creates provider methods
3. What loading/error states to show? → You handle in UI

## 📚 Next Sprints Preview

- **Sprint 2**: Home + Profile screens
- **Sprint 3**: Payments screens
- **Sprint 4**: Menu + Grades
- **Sprint 5**: Schedule + Assignments + Attendance
- **Sprint 6**: Chat
- **Sprint 7**: Rating + Polish

---

**Total Duration**: ~28 days (7 sprints)

Good luck! 🎉

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';

/// Login Screen - Modern School App Design
///
/// Sprint 1 - Task 2
/// Dev1 Responsibility
///
/// Design Features:
/// - Large blue curved top section (40% height)
/// - White floating card for form inputs
/// - Clean, modern Material 3 aesthetic
/// - Royal Blue (#2E5BFF) primary color
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Call login provider (Dev2 will provide)
      // Example:
      // await ref.read(authProvider.notifier).login(
      //   _usernameController.text,
      //   _passwordController.text,
      // );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Navigate to home on success
      context.go(RouteNames.home);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kirish amalga oshmadi: ${e.toString()}'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.4;

    return Scaffold(
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════
          // Blue Curved Top Background (40% height)
          // ═══════════════════════════════════════════════════════
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: topHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo/Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Welcome Title
                    const Text(
                      'Xush kelibsiz!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tizimga kirish',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════
          // White Floating Card with Form
          // ═══════════════════════════════════════════════════════
          Positioned(
            top: topHeight - 40,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Card(
                  elevation: 8,
                  shadowColor: AppColors.shadow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          // ─── Phone/Username Field ───
                          CustomTextField(
                            controller: _usernameController,
                            label: 'Telefon raqam yoki login',
                            hint: '+998 90 123 45 67',
                            prefixIcon: Icons.person_outline_rounded,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Iltimos, telefon raqam yoki login kiriting';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // ─── Password Field ───
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Parol',
                            hint: 'Parolingizni kiriting',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Iltimos, parol kiriting';
                              }
                              if (value.length < 6) {
                                return 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // ─── Forgot Password Link ───
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                context.push(RouteNames.forgotPassword);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              child: const Text(
                                'Parolni unutdingizmi?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ─── Login Button ───
                          CustomButton(
                            text: 'Kirish',
                            onPressed: _isLoading ? null : _handleLogin,
                            isLoading: _isLoading,
                            height: 56,
                            borderRadius: 16,
                          ),
                          const SizedBox(height: 24),

                          // ─── Divider ───
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.divider,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'yoki',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.divider,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // ─── Google Sign-in Button ───
                          OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    // TODO: Implement Google sign-in
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Google orqali kirish hozircha mavjud emas',
                                        ),
                                      ),
                                    );
                                  },
                            icon: Container(
                              padding: const EdgeInsets.all(2),
                              child: Image.asset(
                                'assets/icons/google.png',
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.g_mobiledata_rounded,
                                    size: 32,
                                  );
                                },
                              ),
                            ),
                            label: const Text(
                              'Google orqali kirish',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ─── QR Code Login Button ───
                          OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    // TODO: Implement QR code login
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'QR kod orqali kirish hozircha mavjud emas',
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 24,
                            ),
                            label: const Text(
                              'QR kod orqali kirish',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // ─── Register Link ───
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Hisobingiz yo\'qmi? ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.push(RouteNames.register);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 0,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Ro\'yxatdan o\'tish',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

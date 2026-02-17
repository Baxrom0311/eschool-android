import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

/// Login Screen - Parent app auth entrypoint.
///
/// Includes:
/// - email/phone login
/// - forgot password action
/// - Google sign in action
/// - QR login action (API-level unavailable fallback)
/// - register link
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    try {
      await ref
          .read(authProvider.notifier)
          .login(
            username: _loginController.text.trim(),
            password: _passwordController.text,
          );
      await _completeAuthFlow(defaultError: 'Kirish amalga oshmadi');
    } catch (e) {
      _showError('Kirish amalga oshmadi: ${e.toString()}');
    }
  }

  Future<void> _completeAuthFlow({required String defaultError}) async {
    final authState = ref.read(authProvider);
    if (!mounted) return;

    if (authState.error != null) {
      _showError(authState.error!);
      return;
    }

    if (!authState.isAuthenticated) {
      _showError(defaultError);
      return;
    }

    if (authState.user != null) {
      ref.read(userProvider.notifier).setUser(authState.user!);
    }

    await ref.read(userProvider.notifier).loadProfile();
    if (!mounted) return;

    final userState = ref.read(userProvider);
    if (userState.user == null) {
      _showError(userState.error ?? 'Profil ma\'lumotlarini yuklashda xatolik');
      return;
    }

    context.go(RouteNames.home);
  }

  void _handleQrLogin() {
    _showError(
      'QR orqali kirish hozircha yoqilmagan. Tenant API hozir faqat email/parol loginni qo\'llab-quvvatlaydi.',
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.4;
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: topHeight,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(38),
                  bottomRight: Radius.circular(38),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                      child: Row(
                        children: [
                          const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Asosiy ekran',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Xush kelibsiz!',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tizimga kirish uchun\nma\'lumotlaringizni kiriting',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: topHeight - 50,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Card(
                  elevation: 7,
                  shadowColor: AppColors.shadow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionLabel('LOGIN YOKI TELEFON'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _loginController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Login yoki email kiriting';
                              }
                              if (value.trim().length < 3) {
                                return 'Kiritilgan qiymat juda qisqa';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Masalan: azizbek_01',
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.textHint,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF2F5FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildSectionLabel('PAROL'),
                              const Spacer(),
                              TextButton(
                                onPressed: () =>
                                    context.push(RouteNames.forgotPassword),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Unutdingizmi?',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Parol kiriting';
                              }
                              if (value.length < 6) {
                                return 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.textHint,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textHint,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF2F5FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: AppColors.shadow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Kirish',
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: AppColors.divider,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'YOKI',
                                  style: TextStyle(
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.8,
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: AppColors.divider,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _AuthOptionCard(
                                  label: 'Google',
                                  icon: Icons.g_mobiledata_rounded,
                                  onTap: isLoading
                                      ? null
                                      : () => _showError(
                                          'Google orqali kirish tez kunda ishga tushiriladi',
                                        ),
                                  iconColor: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _AuthOptionCard(
                                  label: 'QR Kod',
                                  icon: Icons.qr_code_2_rounded,
                                  onTap: isLoading ? null : _handleQrLogin,
                                  iconColor: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Hisobingiz yo\'qmi? ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _showError(
                                  'Ro\'yxatdan o\'tish tez kunda ishga tushiriladi',
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Ro\'yxatdan o\'ting',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _AuthOptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color iconColor;

  const _AuthOptionCard({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6EBF3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 34, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

/// Parolni tiklash — 2-bosqichli oqim:
///  1. Telefon raqamni kiriting → SMS kod yuboriladi
///  2. SMS kod + yangi parol → parol yangilanadi
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  /// false = 1-bosqich (telefon), true = 2-bosqich (kod + parol)
  bool _codeSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ────────── 1-bosqich: telefon → kod yuborish ──────────

  Future<void> _handleSendCode() async {
    if (!_phoneFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final authApi = ref.read(authApiProvider);
      await authApi.forgotPassword(phone: _phoneController.text.trim());

      if (!mounted) return;
      setState(() => _codeSent = true);

      _showSuccess('Tasdiqlash kodi yuborildi');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ────────── 2-bosqich: kod + parol → reset ──────────

  Future<void> _handleResetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final authApi = ref.read(authApiProvider);
      await authApi.resetPassword(
        phone: _phoneController.text.trim(),
        code: _codeController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parol muvaffaqiyatli yangilandi!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Login sahifasiga qaytish
      context.pop();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.32;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Top blue header ───
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Parolni tiklash',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _codeSent
                          ? 'SMS orqali kelgan kodni kiriting'
                          : 'Telefon raqamingizni kiriting',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Card content ───
          Positioned(
            top: topHeight - 40,
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
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                    child: _codeSent ? _buildResetForm() : _buildPhoneForm(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────── BOSQICH 1: telefon raqam formasi ──────────

  Widget _buildPhoneForm() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel('TELEFON RAQAM'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            validator: Validators.phone,
            decoration: InputDecoration(
              hintText: '+998 90 123 45 67',
              prefixIcon: const Icon(
                Icons.phone_outlined,
                color: AppColors.textHint,
              ),
              filled: true,
              fillColor: const Color(0xFFF2F5FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSendCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Kod yuborish',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Kirish sahifasiga qaytish',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────── BOSQICH 2: kod + yangi parol formasi ──────────

  Widget _buildResetForm() {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel('TASDIQLASH KODI'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: 6,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Kodni kiriting';
              if (v.length != 6) return 'Kod 6 xonali bo\'lishi kerak';
              return null;
            },
            decoration: InputDecoration(
              hintText: '123456',
              counterText: '',
              prefixIcon: const Icon(
                Icons.sms_outlined,
                color: AppColors.textHint,
              ),
              filled: true,
              fillColor: const Color(0xFFF2F5FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _buildLabel('YANGI PAROL'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Parol kiriting';
              if (v.length < 8) {
                return 'Parol kamida 8 ta belgidan iborat bo\'lishi kerak';
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
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
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
            ),
          ),
          const SizedBox(height: 18),
          _buildLabel('PAROLNI TASDIQLASH'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmController,
            obscureText: !_isConfirmVisible,
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Parolni tasdiqlang';
              if (v != _passwordController.text) {
                return 'Parollar mos kelmaydi';
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
                  setState(() => _isConfirmVisible = !_isConfirmVisible);
                },
                icon: Icon(
                  _isConfirmVisible
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
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Parolni yangilash',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _codeSent = false;
                  _codeController.clear();
                  _passwordController.clear();
                  _confirmController.clear();
                });
              },
              child: const Text(
                'Qaytadan kod yuborish',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
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

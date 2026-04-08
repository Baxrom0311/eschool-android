import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/network/api_error_handler.dart';
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
    final l10n = context.l10n;
    if (!_phoneFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final authApi = ref.read(authApiProvider);
      await authApi.forgotPassword(phone: _phoneController.text.trim());

      if (!mounted) return;
      setState(() => _codeSent = true);

      _showSuccess(l10n.verificationCodeSent);
    } catch (e) {
      _showError(
        ApiErrorHandler.readableMessage(
          e,
          fallback: l10n.verificationCodeSendFailed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ────────── 2-bosqich: kod + parol → reset ──────────

  Future<void> _handleResetPassword() async {
    final l10n = context.l10n;
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
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          content: Text(
            l10n.passwordResetSuccess,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      );

      // Login sahifasiga qaytish
      context.pop();
    } catch (e) {
      _showError(
        ApiErrorHandler.readableMessage(e, fallback: l10n.passwordResetFailed),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorScheme.errorContainer,
        content: Text(
          message,
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorScheme.secondaryContainer,
        content: Text(
          message,
          style: TextStyle(color: colorScheme.onSecondaryContainer),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.32;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final inputFillColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.65 : 0.55,
    );
    final onHeroColor = colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ─── Top blue header ───
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
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: const BorderRadius.only(
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
                        color: onHeroColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 36,
                        color: onHeroColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.forgotPasswordTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: onHeroColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _codeSent
                          ? l10n.forgotPasswordCodeSubtitle
                          : l10n.forgotPasswordPhoneSubtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: onHeroColor.withValues(alpha: 0.9),
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
                  shadowColor: theme.shadowColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                    child: _codeSent
                        ? _buildResetForm(inputFillColor)
                        : _buildPhoneForm(inputFillColor),
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

  Widget _buildPhoneForm(Color inputFillColor) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel(l10n.phoneNumberSection),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            validator: Validators.phone,
            decoration: InputDecoration(
              hintText: '+998 90 123 45 67',
              prefixIcon: Icon(
                Icons.phone_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: inputFillColor,
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
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      l10n.sendCodeAction,
                      style: const TextStyle(
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
              child: Text(
                l10n.backToLoginAction,
                style: TextStyle(
                  color: colorScheme.primary,
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

  Widget _buildResetForm(Color inputFillColor) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel(l10n.verificationCodeSection),
          const SizedBox(height: 8),
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: 6,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.codeRequired;
              if (v.length != 6) return l10n.codeLengthInvalid;
              return null;
            },
            decoration: InputDecoration(
              hintText: l10n.verificationCodeHint,
              counterText: '',
              prefixIcon: Icon(
                Icons.sms_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _buildLabel(l10n.newPasswordLabel.toUpperCase()),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.passwordRequired;
              if (v.length < 8) return l10n.minimumLength(8);
              return null;
            },
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              filled: true,
              fillColor: inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _buildLabel(l10n.confirmPasswordLabel.toUpperCase()),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmController,
            obscureText: !_isConfirmVisible,
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return l10n.confirmPasswordRequired;
              }
              if (v != _passwordController.text) {
                return l10n.passwordsDoNotMatch;
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _isConfirmVisible = !_isConfirmVisible);
                },
                icon: Icon(
                  _isConfirmVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              filled: true,
              fillColor: inputFillColor,
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
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      l10n.resetPasswordAction,
                      style: const TextStyle(
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
              child: Text(
                l10n.resendCodeAction,
                style: TextStyle(
                  color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

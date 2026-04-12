import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

import '../../../core/localization/app_locale.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../providers/app_locale_provider.dart';
import '../../providers/app_theme_mode_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

/// Login Screen - Parent app auth entrypoint.
///
/// Includes:
/// - email login
/// - forgot password action
/// - Google sign in action
/// - QR login action (API-level unavailable fallback)
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
  bool _isSubmitting = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l10n = context.l10n;
    final authState = ref.read(authProvider);
    if (_isSubmitting || authState.isLoading) return;

    if (authState.isAuthenticated) {
      await _completeAuthFlow(defaultError: l10n.loginFailed);
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(authProvider.notifier)
          .login(
            username: _loginController.text.trim(),
            password: _passwordController.text,
          );
      await _completeAuthFlow(defaultError: l10n.loginFailed);
    } catch (e) {
      _showError(
        ApiErrorHandler.readableMessage(e, fallback: l10n.loginFailed),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
      _showError(userState.error ?? context.l10n.profileLoadError);
      return;
    }

    context.go(RouteNames.home);
  }

  void _handleQrLogin() {
    context.push(RouteNames.qrLogin);
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(appLocaleProvider);
    final currentThemeMode = ref.watch(appThemeModeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.42;
    final isLoading = ref.watch(authProvider).isLoading;
    final isBusy = isLoading || _isSubmitting;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Header Background with Premium Navy Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: topHeight + 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              l10n.loginHeader.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Spacer(),
                            // Theme Toggle
                            _buildHeaderChip(
                              onTap: () {
                                final next = switch (currentThemeMode) {
                                  ThemeMode.light => ThemeMode.dark,
                                  _ => ThemeMode.light,
                                };
                                ref.read(appThemeModeProvider.notifier).setThemeMode(next);
                              },
                              child: Icon(
                                currentThemeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Language Switch
                            PopupMenuButton<AppLocale>(
                              onSelected: (l) => ref.read(appLocaleProvider.notifier).setLocale(l),
                              itemBuilder: (ctx) => AppLocale.values.map((l) => PopupMenuItem(value: l, child: Text(l.nativeLabel))).toList(),
                              child: _buildHeaderChip(
                                child: Text(
                                  currentLocale.code.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Premium Abstract Logo
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.shield_rounded, size: 52, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 28),
                      FittedBox(
                        child: Text(
                          l10n.welcome,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.loginHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.6),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Login Form Card
          Positioned(
            top: topHeight,
            left: 20,
            right: 20,
            bottom: 40,
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionLabel(l10n.emailSection),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _loginController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.email,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          decoration: _buildInputDecoration(
                            l10n.emailExample,
                            Icons.alternate_email_rounded,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionLabel(l10n.passwordSection),
                            GestureDetector(
                              onTap: () => context.push(RouteNames.forgotPassword),
                              child: Text(
                                l10n.forgotPasswordShort,
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => isBusy ? null : _handleLogin(),
                          validator: Validators.password,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          decoration: _buildInputDecoration(
                            '••••••••',
                            Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                                color: AppColors.slate400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 64,
                          child: ElevatedButton(
                            onPressed: isBusy ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: isBusy
                                ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(Colors.white)))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(l10n.loginButton, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.keyboard_arrow_right_rounded, size: 22),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(child: Divider(height: 1, thickness: 0.5)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                l10n.orLabel.toUpperCase(),
                                style: const TextStyle(color: AppColors.slate400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                              ),
                            ),
                            const Expanded(child: Divider(height: 1, thickness: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _AuthOptionCard(
                                label: l10n.googleLabel,
                                icon: Icons.g_mobiledata_rounded,
                                onTap: isBusy ? null : () => _showError(l10n.googleSoon),
                                iconColor: AppColors.info,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _AuthOptionCard(
                                label: l10n.qrCodeLabel,
                                icon: Icons.qr_code_scanner_rounded,
                                onTap: isBusy ? null : _handleQrLogin,
                                iconColor: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.accountCreatedByAdmin,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.slate400,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ],
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

  InputDecoration _buildInputDecoration(String hint, IconData prefix, {Widget? suffixIcon}) {
    final theme = Theme.of(context);
    
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefix, color: AppColors.primaryBlue.withValues(alpha: 0.5), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.slate100.withValues(alpha: theme.brightness == Brightness.dark ? 0.05 : 1.0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.danger, width: 1.5)),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w900,
        color: AppColors.slate400,
      ),
    );
  }

  Widget _buildHeaderChip({required Widget child, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: child,
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
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/localization/app_localizations.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(appLocaleProvider);
    final currentThemeMode = ref.watch(appThemeModeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final inputFillColor = isDark
        ? colorScheme.surface.withValues(alpha: 0.92)
        : const Color(0xFFF2F5FA);
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.4;
    final isLoading = ref.watch(authProvider).isLoading;
    final isBusy = isLoading || _isSubmitting;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                            child: Row(
                              children: [
                                Text(
                                  l10n.loginHeader,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                PopupMenuButton<ThemeMode>(
                                  tooltip: l10n.changeTheme,
                                  initialValue: currentThemeMode,
                                  onSelected: (themeMode) {
                                    ref
                                        .read(appThemeModeProvider.notifier)
                                        .setThemeMode(themeMode);
                                  },
                                  color: theme.cardColor,
                                  itemBuilder: (context) => ThemeMode.values
                                      .map(
                                        (mode) => PopupMenuItem<ThemeMode>(
                                          value: mode,
                                          child: Row(
                                            children: [
                                              Icon(
                                                _themeModeIcon(mode),
                                                size: 18,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(_themeModeLabel(mode, l10n)),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  child: _buildHeaderChip(
                                    child: Icon(
                                      _themeModeIcon(currentThemeMode),
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton<AppLocale>(
                                  tooltip: l10n.changeLanguage,
                                  initialValue: currentLocale,
                                  onSelected: (locale) {
                                    ref
                                        .read(appLocaleProvider.notifier)
                                        .setLocale(locale);
                                  },
                                  color: theme.cardColor,
                                  itemBuilder: (context) => AppLocale.values
                                      .map(
                                        (locale) => PopupMenuItem<AppLocale>(
                                          value: locale,
                                          child: Text(locale.nativeLabel),
                                        ),
                                      )
                                      .toList(),
                                  child: _buildHeaderChip(
                                    child: Text(
                                      currentLocale.code.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
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
                          Text(
                            l10n.welcome,
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.loginHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
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
                  shadowColor: theme.shadowColor,
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
                          _buildSectionLabel(l10n.emailSection),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _loginController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: Validators.email,
                            decoration: InputDecoration(
                              hintText: l10n.emailExample,
                              prefixIcon: Icon(
                                Icons.alternate_email_rounded,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              filled: true,
                              fillColor: inputFillColor,
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
                              _buildSectionLabel(l10n.passwordSection),
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
                                child: Text(
                                  l10n.forgotPasswordShort,
                                  style: TextStyle(
                                    color: colorScheme.primary,
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
                            onFieldSubmitted: (_) {
                              if (!isBusy) {
                                _handleLogin();
                              }
                            },
                            validator: Validators.password,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: colorScheme.onSurfaceVariant,
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
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              filled: true,
                              fillColor: inputFillColor,
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
                              onPressed: isBusy ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 4,
                                shadowColor: theme.shadowColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: isBusy
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              colorScheme.onPrimary,
                                            ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          l10n.loginButton,
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  l10n.orLabel,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _AuthOptionCard(
                                  label: l10n.googleLabel,
                                  icon: Icons.g_mobiledata_rounded,
                                  onTap: isBusy
                                      ? null
                                      : () => _showError(l10n.googleSoon),
                                  iconColor: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _AuthOptionCard(
                                  label: l10n.qrCodeLabel,
                                  icon: Icons.qr_code_2_rounded,
                                  onTap: isBusy ? null : _handleQrLogin,
                                  iconColor: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.accountCreatedByAdmin,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
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

  String _themeModeLabel(ThemeMode themeMode, AppLocalizations l10n) {
    return switch (themeMode) {
      ThemeMode.system => l10n.themeSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };
  }

  IconData _themeModeIcon(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.system => Icons.brightness_auto_rounded,
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
    };
  }

  Widget _buildHeaderChip({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: child,
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
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 34, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color:
                    theme.textTheme.titleMedium?.color ?? colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/routing/route_names.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// Register Screen - Create New Account
///
/// Design: EXACTLY like LoginScreen (Blue curved header 40%, White Card)
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.registerUnavailableMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onHeroColor = colorScheme.onPrimary;
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.4;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
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
                        color: onHeroColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        size: 60,
                        color: onHeroColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Register Title
                    Text(
                      l10n.registerTitle,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: onHeroColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.registerSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: onHeroColor.withValues(alpha: 0.9),
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
                  shadowColor: theme.shadowColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),

                          // ─── Full Name Field ───
                          CustomTextField(
                            controller: _nameController,
                            label: l10n.fullNameLabel,
                            hint: l10n.fullNameHint,
                            prefixIcon: Icons.person_outline_rounded,
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.fullNameRequired;
                              }
                              if (value.length < 3) {
                                return l10n.minimumLength(3);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // ─── Phone Number Field ───
                          CustomTextField(
                            controller: _phoneController,
                            label: l10n.phoneNumberLabel,
                            hint: '+998 90 123 45 67',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.phoneRequired;
                              }
                              // Basic phone validation
                              if (value.length < 9) {
                                return l10n.invalidPhone;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // ─── Password Field ───
                          CustomTextField(
                            controller: _passwordController,
                            label: l10n.passwordLabel,
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.passwordRequired;
                              }
                              if (value.length < 6) {
                                return l10n.passwordTooShort;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // ─── Confirm Password Field ───
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: l10n.confirmPasswordLabel,
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.confirmPasswordRequired;
                              }
                              if (value != _passwordController.text) {
                                return l10n.passwordsDoNotMatch;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // ─── Register Button ───
                          CustomButton(
                            text: l10n.createAccountAction,
                            onPressed: _isLoading ? null : _handleRegister,
                            isLoading: _isLoading,
                            height: 62,
                            borderRadius: 32,
                          ),
                          const SizedBox(height: 32),

                          // ─── Login Link ───
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${l10n.haveAccountPrompt} ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.go(RouteNames.login);
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
                                child: Text(
                                  l10n.loginButton,
                                  style: const TextStyle(
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

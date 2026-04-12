import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import 'package:parent_school_app/core/routing/route_names.dart';
import 'package:parent_school_app/core/utils/formatters.dart';
import 'package:parent_school_app/presentation/providers/auth_provider.dart';
import 'package:parent_school_app/presentation/providers/user_provider.dart';
import 'package:parent_school_app/presentation/providers/payment_provider.dart';
import 'package:parent_school_app/presentation/providers/app_theme_mode_provider.dart';
import 'package:parent_school_app/presentation/providers/app_locale_provider.dart';
import 'package:parent_school_app/core/localization/app_locale.dart';
import 'package:parent_school_app/presentation/widgets/common/page_background.dart';
import 'package:parent_school_app/presentation/widgets/common/animated_pressable.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final userState = ref.watch(userProvider);
    final paymentState = ref.watch(paymentProvider);
    final user = userState.user;
    final hasFinancialData = paymentState.balance?.hasFinancialData ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 8),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: LiquidGlass.blur, sigmaY: LiquidGlass.blur),
            child: AppBar(
              title: Text(l10n.profile, style: theme.appBarTheme.titleTextStyle),
              centerTitle: true,
              backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: LiquidGlass.opacity(context)),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: PageBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 64),

            // ─── Modern Avatar Header ───
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Atmospheric Glow Ring
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              AppColors.liquidIndigo.first.withValues(alpha: 0.1),
                              AppColors.liquidIndigo.last.withValues(alpha: 0.8),
                              AppColors.liquidIndigo.first.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      ),
                      // Inner Glass Border & Avatar
                      Container(
                        width: 124,
                        height: 124,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: user?.avatarUrl != null
                                ? Image.network(user!.avatarUrl!, width: 110, height: 110, fit: BoxFit.cover)
                                : Icon(Icons.person_rounded, size: 60, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    user?.fullName ?? l10n.userFallbackName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phone ?? '---',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ─── Quick Stats BENTO Row ───
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.account_balance_wallet_rounded,
                    label: l10n.balanceLabel,
                    value: hasFinancialData ? Formatters.formatCurrency(paymentState.balance!.balance.toDouble()) : '0',
                    suffix: ' UZS',
                    colors: AppColors.liquidIndigo,
                    onTap: () => context.push(RouteNames.payments),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.group_rounded,
                    label: l10n.childrenLabel,
                    value: '${userState.children.length}',
                    suffix: '',
                    colors: AppColors.liquidEmerald,
                    onTap: () => context.push(RouteNames.childrenList),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ─── Settings Sections ───
            _SettingsGroup(
              title: l10n.academicsTitle,
              items: [
                _SettingsItem(
                  icon: Icons.emoji_events_rounded,
                  title: l10n.achievementsTitle,
                  subtitle: l10n.achievementsSubtitle,
                  onTap: () => context.push(RouteNames.leaderboard),
                  color: AppColors.liquidAmber.first,
                ),
                _SettingsItem(
                  icon: Icons.assignment_late_rounded,
                  title: l10n.absenceAppealTitle,
                  subtitle: l10n.absenceAppealSubtitle,
                  onTap: () => context.push(RouteNames.absences),
                  color: AppColors.liquidRose.first,
                ),
                _SettingsItem(
                  icon: Icons.local_library_rounded,
                  title: l10n.digitalLibraryTitle,
                  subtitle: l10n.digitalLibrarySubtitle,
                  onTap: () => context.push(RouteNames.library),
                  color: AppColors.liquidEmerald.first,
                  isLast: true,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _SettingsGroup(
              title: l10n.personalInfoTitle,
              items: [
                _SettingsItem(
                  icon: Icons.person_rounded,
                  title: l10n.personalInfoTitle,
                  subtitle: l10n.personalInfoSubtitle,
                  onTap: () => context.push(RouteNames.editProfile),
                ),
                _SettingsItem(
                  icon: Icons.lock_rounded,
                  title: l10n.passwordChangeTitle,
                  subtitle: l10n.passwordChangeSubtitle,
                  onTap: () => context.push(RouteNames.changePassword),
                ),
                _SettingsItem(
                  icon: Icons.translate_rounded,
                  title: l10n.changeLanguage,
                  subtitle: ref.watch(appLocaleProvider).code.toUpperCase(),
                  onTap: () => _showLanguagePicker(context, ref),
                ),
                _SettingsItem(
                  icon: theme.brightness == Brightness.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  title: l10n.changeTheme,
                  subtitle: _getThemeName(context, ref.watch(appThemeModeProvider)),
                  onTap: () => _showThemePicker(context, ref),
                  isLast: true,
                ),
              ],
            ),

            const SizedBox(height: 48),

            // ─── Danger Zone: Logout ───
            _LogoutButton(onTap: () => _handleLogout(context, ref)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text(l10n.logoutTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        content: Text(l10n.logoutConfirmMessage, style: theme.textTheme.bodyMedium),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 8),
          AnimatedPressable(
            onTap: () async {
              Navigator.pop(dialogContext);
              await ref.read(authProvider.notifier).logout();
              ref.read(userProvider.notifier).clear();
              ref.read(paymentProvider.notifier).clear();
              if (context.mounted) {
                context.go(RouteNames.login);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.liquidRose),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.liquidRose.first.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                l10n.logoutAction,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeName(BuildContext context, ThemeMode mode) {
    final l10n = context.l10n;
    return switch (mode) {
      ThemeMode.system => l10n.themeSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(l10n.changeLanguage, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              ),
              _buildPickerItem(context, l10n.langUz, ref.read(appLocaleProvider) == AppLocale.uz, () {
                ref.read(appLocaleProvider.notifier).setLocale(AppLocale.uz);
                Navigator.pop(context);
              }),
              _buildPickerItem(context, l10n.langRu, ref.read(appLocaleProvider) == AppLocale.ru, () {
                ref.read(appLocaleProvider.notifier).setLocale(AppLocale.ru);
                Navigator.pop(context);
              }),
              _buildPickerItem(context, l10n.langEn, ref.read(appLocaleProvider) == AppLocale.en, () {
                ref.read(appLocaleProvider.notifier).setLocale(AppLocale.en);
                Navigator.pop(context);
              }),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(l10n.changeTheme, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              ),
              _buildPickerItem(context, l10n.themeSystem, ref.read(appThemeModeProvider) == ThemeMode.system, () {
                ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              }, icon: Icons.brightness_auto_rounded),
              _buildPickerItem(context, l10n.themeLight, ref.read(appThemeModeProvider) == ThemeMode.light, () {
                ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              }, icon: Icons.light_mode_rounded),
              _buildPickerItem(context, l10n.themeDark, ref.read(appThemeModeProvider) == ThemeMode.dark, () {
                ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              }, icon: Icons.dark_mode_rounded),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickerItem(BuildContext context, String title, bool isSelected, VoidCallback onTap, {IconData? icon}) {
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: onTap,
      leading: icon != null ? Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.3), size: 24) : null,
      title: Text(
        title, 
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, 
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900, 
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3), 
              letterSpacing: 2.0,
              fontSize: 10,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.03),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              return Column(
                children: [
                  items[index],
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 76,
                      endIndent: 20,
                      color: theme.colorScheme.outline.withValues(alpha: 0.05),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
  final bool isLast;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.primary;
    return AnimatedPressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08), 
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle, 
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4), 
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.15), size: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String suffix;
  final List<Color> colors;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.suffix,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedPressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.first.withValues(alpha: 0.15), colors.last.withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.first.withValues(alpha: 0.1)),
                ),
                child: Icon(icon, color: colors.first, size: 20),
              ),
              const SizedBox(height: 20),
              Text(
                label.toUpperCase(), 
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900, 
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  letterSpacing: 1.5,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 18, color: theme.colorScheme.onSurface)),
                      TextSpan(text: suffix, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnimatedPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.liquidRose.first.withValues(alpha: 0.15),
              AppColors.liquidRose.last.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.liquidRose.first.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.liquidRose.first, size: 22),
            const SizedBox(width: 12),
            Text(
              l10n.logoutAction.toUpperCase(),
              style: TextStyle(
                color: AppColors.liquidRose.first, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 2.0,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

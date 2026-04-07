import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/app_locale_provider.dart';
import '../../providers/app_theme_mode_provider.dart';
import '../../../core/localization/app_locale.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userState = ref.watch(userProvider);
    final paymentState = ref.watch(paymentProvider);
    final user = userState.user;
    final hasFinancialData = paymentState.balance?.hasFinancialData ?? false;

    // Initial data load if needed
    // Note: Splash screen already loads profile, but balance might need refresh

    return Scaffold(
      body: Column(
        children: [
          // ═══════════════════════════════════════════════════════
          // Blue Header with User Info
          // ═══════════════════════════════════════════════════════
          Container(
            width: double.infinity,
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
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  children: [
                    // ─── Avatar and Name ───
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.onPrimary.withValues(
                        alpha: 0.94,
                      ),
                      child: CircleAvatar(
                        radius: 47,
                        backgroundColor: colorScheme.onPrimary.withValues(
                          alpha: 0.12,
                        ),
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: colorScheme.primary,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      user?.fullName ?? l10n.userFallbackName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      l10n.phoneDisplay(user?.phone ?? '---'),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => context.push(RouteNames.payments),
                            child: _StatCard(
                              icon: Icons.account_balance_wallet_rounded,
                              label: l10n.balanceLabel,
                              value: hasFinancialData
                                  ? '${Formatters.formatCurrency(paymentState.balance!.balance.toDouble())} UZS'
                                  : '---',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => context.push(RouteNames.childrenList),
                            child: _StatCard(
                              icon: Icons.people_rounded,
                              label: l10n.childrenLabel,
                              value: l10n.childrenCount(
                                userState.children.length,
                              ),
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

          // ═══════════════════════════════════════════════════════
          // Settings List
          // ═══════════════════════════════════════════════════════
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.emoji_events_rounded,
                  title: l10n.achievementsTitle,
                  subtitle: l10n.achievementsSubtitle,
                  onTap: () {
                    context.push(RouteNames.leaderboard);
                  },
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.groups_rounded,
                  title: l10n.conferencesTitle,
                  subtitle: l10n.conferencesSubtitle,
                  onTap: () {
                    context.push(RouteNames.conference);
                  },
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.assignment_late_rounded,
                  title: l10n.absenceAppealTitle,
                  subtitle: l10n.absenceAppealSubtitle,
                  onTap: () {
                    context.push(RouteNames.absences);
                  },
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.local_library_rounded,
                  title: l10n.digitalLibraryTitle,
                  subtitle: l10n.digitalLibrarySubtitle,
                  onTap: () {
                    context.push(RouteNames.library);
                  },
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.person_outline_rounded,
                  title: l10n.personalInfoTitle,
                  subtitle: l10n.personalInfoSubtitle,
                  onTap: () {
                    context.push(RouteNames.editProfile);
                  },
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.lock_outline_rounded,
                  title: l10n.passwordChangeTitle,
                  subtitle: l10n.passwordChangeSubtitle,
                  onTap: () {
                    context.push(RouteNames.changePassword);
                  },
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: l10n.chatSupportTitle,
                  subtitle: l10n.chatSupportSubtitle,
                  onTap: () {
                    context.push(RouteNames.chatList);
                  },
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.notifications_none_rounded,
                  title: l10n.notificationsTitle,
                  subtitle: l10n.notificationSettingsSubtitle,
                  onTap: () {
                    context.push(RouteNames.notifications);
                  },
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.language_rounded,
                  title: l10n.changeLanguage,
                  subtitle: ref.watch(appLocaleProvider).code.toUpperCase(),
                  onTap: () => _showLanguagePicker(context, ref),
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: theme.brightness == Brightness.dark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: l10n.changeTheme,
                  subtitle: _getThemeName(context, ref.watch(appThemeModeProvider)),
                  onTap: () => _showThemePicker(context, ref),
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  title: l10n.aboutAppTitle,
                  subtitle: l10n.versionLabel('1.0.0'),
                  onTap: () {
                    // Show about dialog
                    showAboutDialog(
                      context: context,
                      applicationName: l10n.schoolAppName,
                      applicationVersion: '1.0.0',
                      applicationIcon: Icon(
                        Icons.school_rounded,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ─── Logout Button ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogout(context, ref),
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(l10n.logoutTitle),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authProvider.notifier).logout();
              ref.read(userProvider.notifier).clear();
              ref.read(paymentProvider.notifier).clear();
              if (context.mounted) {
                context.go(RouteNames.login);
              }
            },
            child: Text(
              l10n.logoutAction,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeName(BuildContext context, ThemeMode mode) {
    final l10n = context.l10n;
    switch (mode) {
      case ThemeMode.system:
        return l10n.themeSystem;
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
    }
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.changeLanguage,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: Text(l10n.langUz),
                trailing: ref.read(appLocaleProvider) == AppLocale.uz
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(appLocaleProvider.notifier).setLocale(AppLocale.uz);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(l10n.langRu),
                trailing: ref.read(appLocaleProvider) == AppLocale.ru
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(appLocaleProvider.notifier).setLocale(AppLocale.ru);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(l10n.langEn),
                trailing: ref.read(appLocaleProvider) == AppLocale.en
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(appLocaleProvider.notifier).setLocale(AppLocale.en);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.changeTheme,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.brightness_auto_rounded),
                title: Text(l10n.themeSystem),
                trailing: ref.read(appThemeModeProvider) == ThemeMode.system
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode_rounded),
                title: Text(l10n.themeLight),
                trailing: ref.read(appThemeModeProvider) == ThemeMode.light
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_rounded),
                title: Text(l10n.themeDark),
                trailing: ref.read(appThemeModeProvider) == ThemeMode.dark
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════
// Stat Card Widget
// ═══════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final onHeroColor = Theme.of(context).colorScheme.onPrimary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: onHeroColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: onHeroColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: onHeroColor, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: onHeroColor.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: onHeroColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Settings Item Widget
// ═══════════════════════════════════════════════════════

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

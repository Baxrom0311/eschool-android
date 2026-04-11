import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/app_locale_provider.dart';
import '../../providers/app_theme_mode_provider.dart';
import '../../../core/localization/app_locale.dart';
import '../../widgets/common/page_background.dart';

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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: PageBackground(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                  background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // ─── Avatar ───
                        Hero(
                          tag: 'profile_avatar',
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.brightness == Brightness.dark 
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : theme.colorScheme.primaryContainer,
                              backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                              child: user?.avatarUrl == null
                                  ? Icon(
                                      Icons.person_rounded, 
                                      size: 44, 
                                      color: theme.brightness == Brightness.dark ? Colors.white70 : theme.colorScheme.primary,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.fullName ?? l10n.userFallbackName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.phoneDisplay(user?.phone ?? '---'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            // ─── Quick Stats Row ───
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.account_balance_wallet_outlined,
                    label: l10n.balanceLabel,
                    value: hasFinancialData ? Formatters.formatCurrency(paymentState.balance!.balance.toDouble()) : '0',
                    suffix: ' UZS',
                    onTap: () => context.push(RouteNames.payments),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.group_outlined,
                    label: l10n.childrenLabel,
                    value: '${userState.children.length}',
                    suffix: ' ${l10n.childrenLabel}',
                    onTap: () => context.push(RouteNames.childrenList),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ─── Academic Section ───
            _SettingsGroup(
              title: l10n.academicsTitle,
              items: [
                _SettingsItem(
                  icon: Icons.emoji_events_outlined,
                  title: l10n.achievementsTitle,
                  subtitle: l10n.achievementsSubtitle,
                  onTap: () => context.push(RouteNames.leaderboard),
                  iconColor: AppColors.warning,
                ),
                _SettingsItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: l10n.conferencesTitle,
                  subtitle: l10n.conferencesSubtitle,
                  onTap: () => context.push(RouteNames.conference),
                  iconColor: AppColors.info,
                ),
                _SettingsItem(
                  icon: Icons.assignment_late_outlined,
                  title: l10n.absenceAppealTitle,
                  subtitle: l10n.absenceAppealSubtitle,
                  onTap: () => context.push(RouteNames.absences),
                  iconColor: AppColors.danger,
                ),
                _SettingsItem(
                  icon: Icons.local_library_outlined,
                  title: l10n.digitalLibraryTitle,
                  subtitle: l10n.digitalLibrarySubtitle,
                  onTap: () => context.push(RouteNames.library),
                  iconColor: AppColors.success,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─── Settings Section ───
            _SettingsGroup(
              title: l10n.personalInfoTitle,
              items: [
                _SettingsItem(
                  icon: Icons.person_outline_rounded,
                  title: l10n.personalInfoTitle,
                  subtitle: l10n.personalInfoSubtitle,
                  onTap: () => context.push(RouteNames.editProfile),
                ),
                _SettingsItem(
                  icon: Icons.lock_outline_rounded,
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
                  icon: theme.brightness == Brightness.dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  title: l10n.changeTheme,
                  subtitle: _getThemeName(context, ref.watch(appThemeModeProvider)),
                  onTap: () => _showThemePicker(context, ref),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ─── Logout ───
            _LogoutButton(onTap: () => _handleLogout(context, ref)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

  void _handleLogout(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.logoutTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel, style: const TextStyle(color: AppColors.slate500, fontWeight: FontWeight.w700)),
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
              style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w900),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.slate200, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(l10n.changeLanguage, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
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
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.slate200, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(l10n.changeTheme, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              ),
              _buildPickerItem(context, l10n.themeSystem, ref.read(appThemeModeProvider) == ThemeMode.system, () {
                ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              }, icon: Icons.brightness_auto_outlined),
              _buildPickerItem(context, l10n.themeLight, ref.read(appThemeModeProvider) == ThemeMode.light, () {
                ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              }, icon: Icons.light_mode_outlined),
              _buildPickerItem(context, l10n.themeDark, ref.read(appThemeModeProvider) == ThemeMode.dark, () {
                ref.read(appThemeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              }, icon: Icons.dark_mode_outlined),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickerItem(BuildContext context, String title, bool isSelected, VoidCallback onTap, {IconData? icon}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListTile(
      onTap: onTap,
      leading: icon != null ? Icon(icon, color: isSelected ? colorScheme.primary : AppColors.slate400, size: 22) : null,
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, 
          color: isSelected ? colorScheme.primary : theme.textTheme.bodyLarge?.color,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: colorScheme.primary) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.slate400, letterSpacing: 1.0),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(children: items),
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
  final Color? iconColor;
  final bool isLast;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                      const SizedBox(height: 1),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.slate500, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.slate300, size: 20),
              ],
            ),
          ),
          if (!isLast)
            Padding(
              padding: const EdgeInsets.only(left: 74),
              child: Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1), thickness: 1),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String suffix;
  final VoidCallback onTap;

  const _StatCard({required this.icon, required this.label, required this.value, required this.suffix, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(height: 16),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: value, style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.headlineLarge?.color, fontWeight: FontWeight.w900)),
                    TextSpan(text: suffix, style: const TextStyle(fontSize: 11, color: AppColors.slate400, fontWeight: FontWeight.w600)),
                  ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
            const SizedBox(width: 12),
            Text(
              context.l10n.logoutTitle.toUpperCase(),
              style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

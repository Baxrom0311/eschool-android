import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/user_provider.dart';

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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
              ),
              borderRadius: BorderRadius.only(
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
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 47,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? const Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: AppColors.primaryBlue,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      user?.fullName ?? l10n.userFallbackName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      l10n.phoneDisplay(user?.phone ?? '---'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
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
                  icon: Icons.info_outline_rounded,
                  title: l10n.aboutAppTitle,
                  subtitle: l10n.versionLabel('1.0.0'),
                  onTap: () {
                    // Show about dialog
                    showAboutDialog(
                      context: context,
                      applicationName: l10n.schoolAppName,
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.school_rounded,
                        size: 48,
                        color: AppColors.primaryBlue,
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
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(
                        color: AppColors.danger,
                        width: 1.5,
                      ),
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
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
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

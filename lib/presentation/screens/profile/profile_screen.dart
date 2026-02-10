import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';

/// Profile Screen - User Profile and Settings
///
/// Sprint 2 - Task 2
/// Dev1 Responsibility
///
/// Design:
/// - Blue header with rounded bottom corners
/// - User avatar, name, ID
/// - Stats row (Balance, Children count)
/// - Settings list
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chiqish'),
        content: const Text('Haqiqatan ham tizimdan chiqmoqchimisiz?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Yo\'q'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text('Ha, chiqish'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Call logout provider (Dev2 will provide)
      // await ref.read(authProvider.notifier).logout();

      // Navigate to login
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                colors: [
                  AppColors.primaryBlue,
                  AppColors.secondaryBlue,
                ],
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
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 47,
                        backgroundColor: Color(0xFFE8F0FF),
                        child: Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Azizbek Rahimov',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      'ID: 2023-8841',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
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
                              label: 'Balans',
                              value: '450,000 UZS',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => context.push(RouteNames.childrenList),
                            child: _StatCard(
                              icon: Icons.people_rounded,
                              label: 'Farzandlar',
                              value: '2 ta',
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
                  icon: Icons.person_outline_rounded,
                  title: 'Shaxsiy ma\'lumotlar',
                  subtitle: 'Profilingizni tahrirlash',
                  onTap: () {
                    // TODO: Navigate to edit profile screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tez orada...'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.lock_outline_rounded,
                  title: 'Parolni o\'zgartirish',
                  subtitle: 'Xavfsizlik sozlamalari',
                  onTap: () {
                    // TODO: Navigate to change password screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tez orada...'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Chat / Yordam',
                  subtitle: 'Qo\'llab-quvvatlash xizmati',
                  onTap: () {
                    context.push(RouteNames.chatList);
                  },
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Bildirishnomalar',
                  subtitle: 'Bildirishnoma sozlamalari',
                  onTap: () {
                    // TODO: Navigate to notifications settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tez orada...'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  title: 'Ilova haqida',
                  subtitle: 'Versiya 1.0.0',
                  onTap: () {
                    // Show about dialog
                    showAboutDialog(
                      context: context,
                      applicationName: 'E-School',
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
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Tizimdan chiqish'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(
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
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }
}

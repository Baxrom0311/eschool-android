import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../../core/routing/route_names.dart';
import '../../../widgets/common/animated_pressable.dart';

class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    
    final services = [
      _ServiceItem(
        title: l10n.conferenceServiceTitle,
        icon: Icons.chat_bubble_rounded,
        colors: AppColors.liquidIndigo,
        route: RouteNames.conference,
      ),
      _ServiceItem(
        title: l10n.absenceServiceTitle,
        icon: Icons.assignment_late_rounded,
        colors: AppColors.liquidRose,
        route: RouteNames.absences,
      ),
      _ServiceItem(
        title: l10n.libraryServiceTitle,
        icon: Icons.local_library_rounded,
        colors: AppColors.liquidEmerald,
        route: RouteNames.library,
      ),
      _ServiceItem(
        title: l10n.ratingServiceTitle,
        icon: Icons.emoji_events_rounded,
        colors: AppColors.liquidAmber,
        route: RouteNames.leaderboard,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.servicesTitle,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              AnimatedPressable(
                onTap: () {}, // Future: View all services
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      Text(
                        l10n.viewAllAction,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 16, color: theme.colorScheme.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.1,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final isDark = theme.brightness == Brightness.dark;
              
              return AnimatedPressable(
                onTap: () => context.push(service.route),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              service.colors.first.withValues(alpha: 0.15),
                              service.colors.last.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: service.colors.first.withValues(alpha: 0.1)),
                        ),
                        child: Icon(
                          service.icon,
                          color: service.colors.first,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          service.title,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceItem {
  final String title;
  final IconData icon;
  final List<Color> colors;
  final String route;

  _ServiceItem({
    required this.title,
    required this.icon,
    required this.colors,
    required this.route,
  });
}

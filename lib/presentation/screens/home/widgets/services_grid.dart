import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/route_names.dart';

class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final services = [
      _ServiceItem(
        title: l10n.conferenceServiceTitle,
        icon: Icons.chat_bubble_outline_rounded,
        color: AppColors.info,
        route: RouteNames.conference,
      ),
      _ServiceItem(
        title: l10n.absenceServiceTitle,
        icon: Icons.assignment_late_outlined,
        color: AppColors.danger,
        route: RouteNames.absences,
      ),
      _ServiceItem(
        title: l10n.libraryServiceTitle,
        icon: Icons.local_library_outlined,
        color: AppColors.success,
        route: RouteNames.library,
      ),
      _ServiceItem(
        title: l10n.ratingServiceTitle,
        icon: Icons.emoji_events_outlined,
        color: const Color(0xFFF59E0B),
        route: RouteNames.leaderboard,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.servicesTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_rounded, size: 16, color: theme.colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
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
              return Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => context.push(service.route),
                  borderRadius: BorderRadius.circular(32),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: service.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            service.icon,
                            color: service.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            service.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              height: 1.1,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
  final Color color;
  final String route;

  _ServiceItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}

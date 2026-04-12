import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../providers/academic_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/common/animated_pressable.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    
    final dateLabel = DateFormat(
      'EEEE, d MMMM',
      l10n.appLocale.name,
    ).format(selectedDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeGreeting('').trim().toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Hero(
                        tag: 'user_greeting_name',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            ref.watch(selectedChildProvider)?.fullName.split(' ').first ?? l10n.userFallbackName,
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Premium Date Selector
              AnimatedPressable(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) => Theme(
                      data: theme.copyWith(
                        colorScheme: theme.colorScheme.copyWith(
                          primary: theme.colorScheme.primary,
                          surface: theme.cardColor,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    ref.read(selectedDateProvider.notifier).state = picked;
                    ref.read(scheduleProvider.notifier).selectDay(picked.weekday);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.calendar_today_rounded, size: 20, color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Liquid Glass Child Selector
          AnimatedPressable(
            onTap: () => context.push(RouteNames.childrenList),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.08),
                    theme.colorScheme.primary.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    ref.watch(selectedChildProvider)?.className ?? l10n.noClassLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: theme.colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

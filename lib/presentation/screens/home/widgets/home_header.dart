import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../../core/routing/route_names.dart';
import '../../../providers/academic_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/common/animated_pressable.dart';
import '../../../widgets/common/liquid_glass.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                child: LiquidGlassPanel(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(100),
                  backgroundColor: theme.cardColor.withValues(alpha: 0.80),
                  borderColor: theme.colorScheme.outline.withValues(alpha: 0.10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  blurSigma: 12,
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Liquid Glass Child Selector
          AnimatedPressable(
            onTap: () => context.push(RouteNames.childrenList),
            child: LiquidGlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              borderRadius: BorderRadius.circular(100),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                  theme.colorScheme.primary.withValues(alpha: 0.02),
                ],
              ),
              borderColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              boxShadow: const [],
              blurSigma: 10,
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

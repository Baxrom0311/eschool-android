import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/route_names.dart';
import '../../../providers/academic_provider.dart';
import '../../../providers/user_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final child = ref.watch(selectedChildProvider);
    final greetingName = child?.fullName ?? l10n.userFallbackName;
    
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    
    final dateLabel = DateFormat(
      'EEEE, d-MMMM',
      l10n.appLocale.name,
    ).format(selectedDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Premium Date Chip (Interactive)
              InkWell(
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
                          onPrimary: Colors.white,
                          surface: theme.cardColor,
                          onSurface: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    HapticFeedback.lightImpact();
                    ref.read(selectedDateProvider.notifier).state = picked;
                    ref.read(scheduleProvider.notifier).selectDay(picked.weekday);
                  }
                },
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Notifications removed (moved to global AppBar)
              const SizedBox(width: 32), // Spacer to maintain alignment if needed
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeGreeting('').trim(),
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              greetingName,
              style: TextStyle(
                color: theme.textTheme.headlineLarge?.color,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

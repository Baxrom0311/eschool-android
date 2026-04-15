import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';

import '../../../data/models/event_model.dart';
import '../../providers/event_provider.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventListProvider.notifier).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(eventListProvider);
    final isDark = theme.brightness == Brightness.dark;

    final types = ['all', 'holiday', 'exam', 'meeting', 'sport', 'other'];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventsTitle), centerTitle: true),
      body: Column(
        children: [
          // Type filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: types.length,
              itemBuilder: (context, index) {
                final type = types[index];
                final isSelected = (state.selectedType ?? 'all') == type ||
                    (type == 'all' && state.selectedType == null);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(_typeLabel(type, l10n)),
                    onSelected: (_) {
                      ref.read(eventListProvider.notifier).loadEvents(
                            type: type == 'all' ? null : type,
                          );
                    },
                    selectedColor: AppColors.skyBlue100,
                    checkmarkColor: AppColors.skyBlue600,
                  ),
                );
              },
            ),
          ),
          // Events list
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                            const SizedBox(height: 12),
                            Text(l10n.eventsLoadFailed, style: theme.textTheme.bodyLarge),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () => ref.read(eventListProvider.notifier).loadEvents(),
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(l10n.refreshAction),
                            ),
                          ],
                        ),
                      )
                    : state.events.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_busy_rounded, size: 56, color: AppColors.slate400),
                                const SizedBox(height: 12),
                                Text(l10n.eventsEmpty,
                                    style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate500)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => ref.read(eventListProvider.notifier).loadEvents(type: state.selectedType),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.events.length,
                              itemBuilder: (context, index) =>
                                  _EventCard(event: state.events[index], isDark: isDark),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type, dynamic l10n) {
    switch (type) {
      case 'all':
        return l10n.eventsAll;
      case 'holiday':
        return l10n.eventsHoliday;
      case 'exam':
        return l10n.eventsExam;
      case 'meeting':
        return l10n.eventsMeeting;
      case 'sport':
        return l10n.eventsSport;
      default:
        return l10n.eventsOther;
    }
  }
}

class _EventCard extends StatelessWidget {
  final SchoolEventModel event;
  final bool isDark;

  const _EventCard({required this.event, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _typeColor(event.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_typeIcon(event.type), color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (event.description != null && event.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      event.description!,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (event.startDate != null)
                      _InfoChip(icon: Icons.calendar_today_rounded, text: event.startDate!),
                    if (event.startTime != null)
                      _InfoChip(icon: Icons.access_time_rounded, text: event.startTime!),
                    if (event.location != null)
                      _InfoChip(icon: Icons.location_on_outlined, text: event.location!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'holiday':
        return AppColors.success;
      case 'exam':
        return AppColors.danger;
      case 'meeting':
        return AppColors.skyBlue600;
      case 'sport':
        return AppColors.warning;
      default:
        return AppColors.slate500;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'holiday':
        return Icons.celebration_rounded;
      case 'exam':
        return Icons.assignment_rounded;
      case 'meeting':
        return Icons.groups_rounded;
      case 'sport':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.event_rounded;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.slate400),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11, color: AppColors.slate500, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

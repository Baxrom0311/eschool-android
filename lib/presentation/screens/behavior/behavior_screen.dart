import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';

import '../../../data/models/behavior_model.dart';
import '../../providers/behavior_provider.dart';
import '../../providers/user_provider.dart';

class BehaviorScreen extends ConsumerStatefulWidget {
  const BehaviorScreen({super.key});

  @override
  ConsumerState<BehaviorScreen> createState() => _BehaviorScreenState();
}

class _BehaviorScreenState extends ConsumerState<BehaviorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final child = ref.read(selectedChildProvider);
      if (child != null) {
        ref.read(behaviorProvider.notifier).loadBehavior(child.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(behaviorProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.behaviorTitle), centerTitle: true),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 12),
                      Text(l10n.behaviorLoadFailed, style: theme.textTheme.bodyLarge),
                    ],
                  ),
                )
              : state.summary == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      onRefresh: () async {
                        final child = ref.read(selectedChildProvider);
                        if (child != null) {
                          ref.read(behaviorProvider.notifier).loadBehavior(child.id);
                        }
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _SummaryCard(summary: state.summary!, isDark: isDark),
                          const SizedBox(height: 20),
                          Text(
                            l10n.behaviorHistory,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          if (state.summary!.incidents.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Column(
                                  children: [
                                    Icon(Icons.sentiment_satisfied_alt_rounded,
                                        size: 56, color: AppColors.slate400),
                                    const SizedBox(height: 12),
                                    Text(l10n.behaviorEmpty,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(color: AppColors.slate500)),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...state.summary!.incidents.map(
                              (incident) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _IncidentCard(incident: incident, isDark: isDark),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final BehaviorSummaryModel summary;
  final bool isDark;

  const _SummaryCard({required this.summary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final scoreColor = summary.netScore >= 0 ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Net score
          Text(
            '${summary.netScore >= 0 ? '+' : ''}${summary.netScore}',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: scoreColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.behaviorNetScore,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate400),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.thumb_up_rounded,
                  color: Colors.green,
                  value: '+${summary.totalPositive}',
                  label: l10n.behaviorPositive,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.slate200),
              Expanded(
                child: _StatItem(
                  icon: Icons.thumb_down_rounded,
                  color: Colors.red,
                  value: '${summary.totalNegative}',
                  label: l10n.behaviorNegative,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.slate200),
              Expanded(
                child: _StatItem(
                  icon: Icons.list_alt_rounded,
                  color: AppColors.skyBlue500,
                  value: '${summary.incidentsCount}',
                  label: l10n.behaviorTotal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: AppColors.slate400)),
      ],
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final BehaviorIncidentModel incident;
  final bool isDark;

  const _IncidentCard({required this.incident, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = incident.isPositive;
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPositive ? Icons.star_rounded : Icons.warning_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        incident.category,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${isPositive ? '+' : ''}${incident.points}',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                if (incident.description != null && incident.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    incident.description!,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (incident.reporterName != null) ...[
                      Icon(Icons.person_outline, size: 14, color: AppColors.slate400),
                      const SizedBox(width: 4),
                      Text(
                        incident.reporterName!,
                        style: theme.textTheme.labelSmall?.copyWith(color: AppColors.slate400),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (incident.incidentDate != null) ...[
                      Icon(Icons.calendar_today, size: 14, color: AppColors.slate400),
                      const SizedBox(width: 4),
                      Text(
                        incident.incidentDate!,
                        style: theme.textTheme.labelSmall?.copyWith(color: AppColors.slate400),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

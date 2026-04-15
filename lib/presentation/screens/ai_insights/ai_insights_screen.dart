import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/ai_provider.dart';
import '../../providers/user_provider.dart';

class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInsights();
    });
  }

  void _loadInsights() {
    final child = ref.read(selectedChildProvider);
    if (child != null) {
      ref.read(aiInsightProvider.notifier).loadInsights(child.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(aiInsightProvider);

    ref.listen(selectedChildProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        _loadInsights();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.aiInsightsTitle),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        foregroundColor: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(l10n.aiInsightsError(state.error!)))
              : state.insight == null
                  ? Center(child: Text(l10n.aiInsightsEmpty))
                  : _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, AiInsightState state) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final insight = state.insight!;
    final risk = insight.riskPrediction;

    final Color riskColor;
    switch (risk.riskLevel) {
      case 'High':
        riskColor = AppColors.danger;
      case 'Medium':
        riskColor = AppColors.warning;
      default:
        riskColor = AppColors.success;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Risk Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: riskColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: riskColor.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.warning_amber_rounded, color: riskColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      l10n.aiRiskLevelLabel(risk.riskLevel),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: riskColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                risk.aiAnalysis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                ),
                child: Text(
                  l10n.aiAttendanceAndGrade(
                    risk.attendanceRate?.toStringAsFixed(0) ?? '-',
                    risk.avgGrade?.toStringAsFixed(1) ?? '-',
                  ),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Weak Areas
        Text(
          l10n.aiWeakAreasTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        ...insight.weakAreasSuggestions.map((topic) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.book_rounded, color: AppColors.info, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.subject,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          topic.aiAdvice,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (topic.currentScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        topic.currentScore!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.amber,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            )),
      ],
    );
  }
}

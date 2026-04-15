import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';

import '../../../core/routing/route_names.dart';
import '../../../data/models/quiz_model.dart';
import '../../providers/quiz_provider.dart';

class QuizListScreen extends ConsumerStatefulWidget {
  const QuizListScreen({super.key});

  @override
  ConsumerState<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends ConsumerState<QuizListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizListProvider.notifier).loadQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(quizListProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizTitle), centerTitle: true),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 12),
                      Text(l10n.quizLoadFailed, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => ref.read(quizListProvider.notifier).loadQuizzes(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(l10n.refreshAction),
                      ),
                    ],
                  ),
                )
              : state.quizzes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.quiz_outlined, size: 56, color: AppColors.slate400),
                          const SizedBox(height: 12),
                          Text(l10n.quizEmpty, style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate500)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.read(quizListProvider.notifier).loadQuizzes(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.quizzes.length,
                        itemBuilder: (context, index) => _QuizCard(
                          quiz: state.quizzes[index],
                          isDark: isDark,
                        ),
                      ),
                    ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final bool isDark;

  const _QuizCard({required this.quiz, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return GestureDetector(
      onTap: quiz.isAttempted ? null : () => context.push(RouteNames.quizSession, extra: quiz),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: quiz.isAttempted
                          ? [AppColors.success, AppColors.successLight]
                          : [AppColors.skyBlue500, AppColors.skyBlue700],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    quiz.isAttempted ? Icons.check_circle_rounded : Icons.quiz_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (quiz.subjectName != null)
                        Text(
                          quiz.subjectName!,
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500),
                        ),
                    ],
                  ),
                ),
                if (quiz.isAttempted && quiz.lastPercent != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _scoreColor(quiz.lastPercent!).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${quiz.lastPercent!.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _scoreColor(quiz.lastPercent!),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (quiz.timeLimitMinutes != null) ...[
                  Icon(Icons.timer_outlined, size: 14, color: AppColors.slate400),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.timeLimitMinutes} ${l10n.quizMinutes}',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(Icons.star_outline_rounded, size: 14, color: AppColors.slate400),
                const SizedBox(width: 4),
                Text(
                  '${l10n.quizMaxScore}: ${quiz.maxScore}',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500),
                ),
              ],
            ),
            if (quiz.isAttempted)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.quizAlreadyAttempted,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double percent) {
    if (percent >= 80) return AppColors.success;
    if (percent >= 60) return AppColors.skyBlue600;
    if (percent >= 40) return AppColors.warning;
    return AppColors.danger;
  }
}

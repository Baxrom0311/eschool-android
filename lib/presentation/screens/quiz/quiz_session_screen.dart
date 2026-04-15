import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';

import '../../../data/models/quiz_model.dart';
import '../../providers/quiz_provider.dart';

class QuizSessionScreen extends ConsumerStatefulWidget {
  final QuizModel quiz;

  const QuizSessionScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends ConsumerState<QuizSessionScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizSessionProvider.notifier).startQuiz(widget.quiz.id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(quizSessionProvider);

    // Show result
    if (state.result != null) {
      return _QuizResultView(result: state.result!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        centerTitle: true,
        actions: [
          if (state.attempt != null && state.attempt!.timeLimitMinutes != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, size: 16, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      '${state.attempt!.timeLimitMinutes} min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 12),
                      Text(l10n.quizStartFailed, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.pop(),
                        child: Text(l10n.close),
                      ),
                    ],
                  ),
                )
              : state.attempt == null
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        // Progress bar
                        LinearProgressIndicator(
                          value: state.attempt!.questions.isEmpty
                              ? 0
                              : (_currentPage + 1) / state.attempt!.questions.length,
                          backgroundColor: AppColors.slate200,
                          color: AppColors.skyBlue600,
                          minHeight: 4,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${l10n.quizQuestion} ${_currentPage + 1}/${state.attempt!.questions.length}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate500,
                                ),
                              ),
                              Text(
                                '${state.answers.length}/${state.attempt!.questions.length} ${l10n.quizAnswered}',
                                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate400),
                              ),
                            ],
                          ),
                        ),
                        // Questions
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (p) => setState(() => _currentPage = p),
                            itemCount: state.attempt!.questions.length,
                            itemBuilder: (context, index) {
                              final q = state.attempt!.questions[index];
                              final selectedIdx = state.answers[q.index];
                              return _QuestionPage(
                                question: q,
                                selectedIndex: selectedIdx,
                                onSelect: (optIdx) {
                                  ref.read(quizSessionProvider.notifier).selectAnswer(q.index, optIdx);
                                },
                              );
                            },
                          ),
                        ),
                        // Bottom nav
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: Row(
                              children: [
                                if (_currentPage > 0)
                                  OutlinedButton(
                                    onPressed: () => _pageController.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    ),
                                    child: Text(l10n.quizPrevious),
                                  ),
                                const Spacer(),
                                if (_currentPage < state.attempt!.questions.length - 1)
                                  FilledButton(
                                    onPressed: () => _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    ),
                                    child: Text(l10n.quizNext),
                                  )
                                else
                                  FilledButton(
                                    onPressed: state.isSubmitting
                                        ? null
                                        : () => ref.read(quizSessionProvider.notifier).submitQuiz(widget.quiz.id),
                                    child: state.isSubmitting
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : Text(l10n.quizSubmit),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const _QuestionPage({
    required this.question,
    this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ...question.options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;
            final isSelected = selectedIndex == idx;

            return GestureDetector(
              onTap: () => onSelect(idx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.skyBlue600.withValues(alpha: 0.08)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.skyBlue600 : AppColors.slate200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.skyBlue600 : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.skyBlue600 : AppColors.slate300,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        option,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  final QuizSubmitResult result;

  const _QuizResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final color = _scoreColor(result.percent);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${result.percent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  result.percent >= 60 ? l10n.quizResultGreat : l10n.quizResultTryAgain,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.quizScore}: ${result.score}/${result.maxScore}',
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate500),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.quizBackToList),
                ),
              ],
            ),
          ),
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

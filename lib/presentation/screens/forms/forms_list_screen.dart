import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';

import '../../../core/routing/route_names.dart';
import '../../../data/models/form_model.dart';
import '../../providers/forms_provider.dart';

class FormsListScreen extends ConsumerStatefulWidget {
  const FormsListScreen({super.key});

  @override
  ConsumerState<FormsListScreen> createState() => _FormsListScreenState();
}

class _FormsListScreenState extends ConsumerState<FormsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(formsListProvider.notifier).loadForms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(formsListProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.formsTitle), centerTitle: true),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 12),
                      Text(l10n.formsLoadFailed, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => ref.read(formsListProvider.notifier).loadForms(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(l10n.refreshAction),
                      ),
                    ],
                  ),
                )
              : state.forms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.assignment_outlined, size: 56, color: AppColors.slate400),
                          const SizedBox(height: 12),
                          Text(l10n.formsEmpty,
                              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate500)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.read(formsListProvider.notifier).loadForms(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.forms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _FormCard(
                          form: state.forms[index],
                          isDark: isDark,
                        ),
                      ),
                    ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final DynamicFormModel form;
  final bool isDark;

  const _FormCard({required this.form, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isExpired = form.expiresAt != null && form.expiresAt!.isBefore(DateTime.now());

    return GestureDetector(
      onTap: isExpired ? null : () => context.push(RouteNames.formDetail, extra: form.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: form.hasSubmitted
                      ? [Colors.green.withValues(alpha: 0.15), Colors.green.withValues(alpha: 0.05)]
                      : [AppColors.skyBlue500.withValues(alpha: 0.15), AppColors.skyBlue500.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                form.hasSubmitted ? Icons.check_circle_rounded : Icons.assignment_rounded,
                color: form.hasSubmitted ? Colors.green : AppColors.skyBlue500,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    form.title,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (form.description != null && form.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      form.description!,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (form.hasSubmitted)
                        _Badge(text: l10n.formsSubmitted, color: Colors.green)
                      else if (isExpired)
                        _Badge(text: l10n.formsExpired, color: Colors.red)
                      else
                        _Badge(text: l10n.formsPending, color: AppColors.skyBlue500),
                      if (form.expiresAt != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.schedule, size: 14, color: AppColors.slate400),
                        const SizedBox(width: 2),
                        Text(
                          _formatDate(form.expiresAt!),
                          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.slate400),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (!isExpired && !form.hasSubmitted)
              Icon(Icons.chevron_right_rounded, color: AppColors.slate300),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

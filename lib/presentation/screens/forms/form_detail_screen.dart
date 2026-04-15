import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';

import '../../../data/models/form_model.dart';
import '../../providers/forms_provider.dart';

class FormDetailScreen extends ConsumerStatefulWidget {
  final int formId;

  const FormDetailScreen({super.key, required this.formId});

  @override
  ConsumerState<FormDetailScreen> createState() => _FormDetailScreenState();
}

class _FormDetailScreenState extends ConsumerState<FormDetailScreen> {
  final List<TextEditingController> _controllers = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(formDetailProvider.notifier).loadForm(widget.formId);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _initControllers(FormDetailModel form) {
    if (_controllers.isNotEmpty) return;
    for (int i = 0; i < form.fieldsSchema.length; i++) {
      final prefill = (form.myAnswers != null && i < form.myAnswers!.length)
          ? form.myAnswers![i]
          : '';
      _controllers.add(TextEditingController(text: prefill));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(formDetailProvider);

    if (state.form != null) {
      _initControllers(state.form!);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.formsTitle), centerTitle: true),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.form == null
              ? Center(child: Text(l10n.formsLoadFailed))
              : state.submitted
                  ? _SuccessView(theme: theme, l10n: l10n)
                  : state.form == null
                      ? const SizedBox.shrink()
                      : Form(
                          key: _formKey,
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              // Title
                              Text(
                                state.form!.title,
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              if (state.form!.description != null &&
                                  state.form!.description!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  state.form!.description!,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.slate500),
                                ),
                              ],
                              const SizedBox(height: 24),

                              // Fields
                              ...List.generate(state.form!.fieldsSchema.length, (i) {
                                final field = state.form!.fieldsSchema[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _buildField(context, field, i),
                                );
                              }),

                              const SizedBox(height: 16),

                              // Submit
                              if (!state.form!.hasSubmitted)
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: FilledButton(
                                    onPressed: state.isSubmitting ? null : () => _submit(),
                                    child: state.isSubmitting
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(l10n.formsSubmitAction),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Colors.green),
                                      const SizedBox(width: 12),
                                      Text(
                                        l10n.formsAlreadySubmitted,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
    );
  }

  Widget _buildField(BuildContext context, FormFieldSchema field, int index) {
    final theme = Theme.of(context);

    switch (field.type) {
      case 'textarea':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(label: field.label, required: field.required),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controllers[index],
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: field.required
                  ? (v) => (v == null || v.trim().isEmpty) ? '' : null
                  : null,
            ),
          ],
        );

      case 'select':
      case 'radio':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(label: field.label, required: field.required),
            const SizedBox(height: 8),
            ...field.options.map((option) {
              final selected = _controllers[index].text == option;
              return RadioListTile<String>(
                title: Text(option, style: theme.textTheme.bodyMedium),
                value: option,
                groupValue: _controllers[index].text.isEmpty ? null : _controllers[index].text,
                onChanged: (v) => setState(() => _controllers[index].text = v ?? ''),
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }),
          ],
        );

      case 'checkbox':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(label: field.label, required: field.required),
            const SizedBox(height: 8),
            ...field.options.map((option) {
              final currentValues = _controllers[index].text.isEmpty
                  ? <String>[]
                  : _controllers[index].text.split('||');
              final checked = currentValues.contains(option);
              return CheckboxListTile(
                title: Text(option, style: theme.textTheme.bodyMedium),
                value: checked,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      currentValues.add(option);
                    } else {
                      currentValues.remove(option);
                    }
                    _controllers[index].text = currentValues.join('||');
                  });
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }),
          ],
        );

      case 'number':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(label: field.label, required: field.required),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controllers[index],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: field.required
                  ? (v) => (v == null || v.trim().isEmpty) ? '' : null
                  : null,
            ),
          ],
        );

      default: // text, date
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(label: field.label, required: field.required),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controllers[index],
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: field.required
                  ? (v) => (v == null || v.trim().isEmpty) ? '' : null
                  : null,
            ),
          ],
        );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final answers = _controllers.map((c) => c.text).toList();
    final ok = await ref.read(formDetailProvider.notifier).submitForm(widget.formId, answers);
    if (!ok && mounted) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.formsSubmitFailed)),
      );
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _FieldLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        children: required
            ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
            : null,
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final ThemeData theme;
  final dynamic l10n;

  const _SuccessView({required this.theme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            l10n.formsSubmittedSuccess,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.formsBackToList),
          ),
        ],
      ),
    );
  }
}

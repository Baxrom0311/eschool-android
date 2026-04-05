import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import 'app_error_widget.dart';
import 'loading_indicator.dart';

class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.child,
    this.isLoading = false,
    this.errorMessage,
    this.isEmpty = false,
    this.emptyMessage,
    this.onRetry,
    this.loadingMessage,
  });

  final Widget child;
  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final String? emptyMessage;
  final VoidCallback? onRetry;
  final String? loadingMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingIndicator(message: loadingMessage);
    }

    final normalizedError = errorMessage?.trim();
    if (normalizedError != null && normalizedError.isNotEmpty) {
      return AppErrorWidget(message: normalizedError, onRetry: onRetry);
    }

    if (isEmpty) {
      return AppErrorWidget.empty(message: emptyMessage ?? AppStrings.noData);
    }

    return child;
  }
}

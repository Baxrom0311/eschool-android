import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parent_school_app/core/localization/l10n_extension.dart';
import 'package:parent_school_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/routing/route_names.dart';
import '../../providers/payment_provider.dart';
import '../../providers/user_provider.dart';
import '../../../core/services/socket_service.dart';
import '../../widgets/payments/balance_header.dart';
import '../../widgets/common/glass_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/page_background.dart';
import '../../widgets/common/liquid_glass.dart';

/// Payments Screen - Main view for billing and payments
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  int? _lastLoadedStudentId;

  void _loadPaymentDataForSelectedChild({bool force = false}) {
    final studentId = ref.read(selectedChildProvider)?.id;
    final paymentState = ref.read(paymentProvider);
    final hasData =
        paymentState.selectedStudentId == studentId &&
        (paymentState.balance != null ||
            paymentState.payments.isNotEmpty ||
            paymentState.paymentMethods.isNotEmpty) &&
        paymentState.error == null;
    if (!force &&
        paymentState.isLoading &&
        paymentState.selectedStudentId == studentId) {
      return;
    }
    if (!force && _lastLoadedStudentId == studentId && hasData) {
      return;
    }

    _lastLoadedStudentId = studentId;
    ref.read(paymentProvider.notifier).loadInitialData(studentId: studentId);
  }

  String _formatLastUpdated(AppLocalizations l10n, String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return l10n.notUpdatedLabel;
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return l10n.notUpdatedLabel;

    final now = DateTime.now();
    if (now.year == parsed.year &&
        now.month == parsed.month &&
        now.day == parsed.day) {
      return l10n.todayLabel;
    }

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day.$month.${parsed.year}';
  }

  String _formatCurrencyAmount(AppLocalizations l10n, num amount) {
    return '${Formatters.formatCurrency(amount.toDouble())} ${l10n.currencyCode}';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadPaymentDataForSelectedChild();
      _initSocketListener();
    });
  }

  void _initSocketListener() {
    final parentId = ref.read(userProvider).user?.id;
    final socket = ref.read(socketServiceProvider);
    if (parentId == null || socket == null) return;

    final channelName = 'parent.$parentId';

    // Payment received eventini tinglash
    socket.listenPrivate(
      channelName,
      'payment.received',
      (data) {
        debugPrint('💰 Real-time Payment: $data');
        if (mounted) {
          final child = ref.read(selectedChildProvider);
          ref.read(paymentProvider.notifier).refresh(studentId: child?.id);
        }
      },
    );
  }

  @override
  void dispose() {
    final parentId = ref.read(userProvider).user?.id;
    final socket = ref.read(socketServiceProvider);
    if (parentId != null && socket != null) {
      socket.leaveChannel('parent.$parentId');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(paymentProvider);
    final userState = ref.watch(userProvider);
    final child = userState.selectedChild;
    final hasFinancialData = state.balance?.hasFinancialData ?? false;
    final hasDebt = hasFinancialData && (state.balance?.hasDebt ?? false);
    final debtAmount = state.balance?.debtAmount ?? 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Text(l10n.paymentsTitle, style: theme.appBarTheme.titleTextStyle),
      ),
      body: PageBackground(
        child: state.isLoading && state.balance == null
            ? const LoadingIndicator()
            : RefreshIndicator(
                onRefresh: () => ref
                    .read(paymentProvider.notifier)
                    .refresh(studentId: child?.id),
                color: theme.colorScheme.primary,
                backgroundColor: theme.cardColor,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 56 + 12),

                    // ─── Header Section ───
                    BalanceHeader(
                      balance: hasFinancialData
                          ? _formatCurrencyAmount(
                              l10n,
                              state.balance?.balance ?? 0,
                            )
                          : l10n.noFinancialData,
                      lastUpdated: _formatLastUpdated(
                        l10n,
                        state.balance?.nextPaymentDate,
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (state.error != null)
                      LiquidGlassPanel(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(16),
                        backgroundColor: theme.colorScheme.error.withValues(
                          alpha: 0.10,
                        ),
                        borderColor: theme.colorScheme.error.withValues(alpha: 0.20),
                        boxShadow: const [],
                        blurSigma: 10,
                        child: Text(
                          state.error!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                    // ─── Contract Info Card ───
                    if (child != null || state.balance?.contractNumber != null)
                      _InfoCard(
                        title: l10n.contractInfoTitle,
                        icon: Icons.description_rounded,
                        items: [
                          if (state.balance?.contractNumber != null)
                            {
                              'label': l10n.contractLabel,
                              'value': state.balance!.contractNumber!,
                            },
                          if (child != null)
                            {'label': l10n.studentLabel, 'value': child.fullName},
                          if (child != null)
                            {'label': l10n.classLabel, 'value': child.className},
                          if (hasFinancialData &&
                              (state.balance?.monthlyFee ?? 0) > 0)
                            {
                              'label': l10n.monthlyPaymentLabel,
                              'value': _formatCurrencyAmount(
                                l10n,
                                state.balance!.monthlyFee,
                              ),
                            },
                        ],
                      ),

                    if (hasDebt) ...[
                      const SizedBox(height: 16),
                      LiquidGlassPanel(
                        padding: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.liquidAmber.first.withValues(alpha: 0.15),
                            AppColors.liquidAmber.last.withValues(alpha: 0.05),
                          ],
                        ),
                        borderColor: AppColors.liquidAmber.first.withValues(
                          alpha: 0.14,
                        ),
                        boxShadow: const [],
                        blurSigma: 10,
                        child: Row(
                          children: [
                            LiquidGlassPanel(
                              padding: const EdgeInsets.all(12),
                              borderRadius: BorderRadius.circular(100),
                              gradient: LinearGradient(
                                colors: AppColors.liquidAmber,
                              ),
                              borderColor: Colors.white.withValues(alpha: 0.14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.liquidAmber.first.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              blurSigma: 8,
                              child: const Icon(
                                Icons.priority_high_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.debtExistsTitle.toUpperCase(),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: AppColors.amber,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.debtPaymentPrompt(
                                      _formatCurrencyAmount(l10n, debtAmount),
                                    ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ─── Action Buttons ───
                    CustomButton(
                      text: l10n.payNowAction,
                      icon: Icons.payments_rounded,
                      height: 72,
                      borderRadius: 24,
                      onPressed: () => context.push(RouteNames.paymentMethod),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: l10n.paymentHistoryTitle,
                      icon: Icons.history_rounded,
                      height: 72,
                      borderRadius: 24,
                      isOutlined: true,
                      onPressed: () => context.push(RouteNames.paymentHistory),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Map<String, String>> items;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.20 : 0.04,
          ),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(
        children: [
          Row(
            children: [
              LiquidGlassPanel(
                padding: const EdgeInsets.all(10),
                borderRadius: BorderRadius.circular(12),
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.10,
                ),
                borderColor: theme.colorScheme.primary.withValues(alpha: 0.14),
                boxShadow: const [],
                blurSigma: 8,
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label']!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.4,
                      ),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item['value']!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
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

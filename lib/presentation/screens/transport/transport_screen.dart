import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';

import '../../../data/models/transport_model.dart';
import '../../providers/selected_child_provider.dart';
import '../../providers/transport_provider.dart';

class TransportScreen extends ConsumerStatefulWidget {
  const TransportScreen({super.key});

  @override
  ConsumerState<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends ConsumerState<TransportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final child = ref.read(selectedChildProvider);
    final studentId = child?.id;
    if (studentId != null) {
      ref.read(transportProvider.notifier).loadLocation(studentId);
      ref.read(transportProvider.notifier).startAutoRefresh(studentId);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(transportProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transportTitle),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.skyBlue100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.directions_bus_rounded,
                              size: 36, color: AppColors.skyBlue600),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.transportNoBus,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.transportNoBusDesc,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.slate500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : state.data == null
                  ? const SizedBox.shrink()
                  : _TransportContent(data: state.data!, isDark: isDark),
    );
  }
}

class _TransportContent extends StatelessWidget {
  final BusRouteInfoModel data;
  final bool isDark;

  const _TransportContent({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bus info card
        _InfoCard(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.skyBlue500, AppColors.skyBlue700],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.directions_bus_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (data.vehicleNumber != null)
                          Text(
                            data.vehicleNumber!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.slate500),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (data.driverName != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person_rounded,
                        size: 18, color: AppColors.slate400),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.transportDriver}: ${data.driverName}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Current location card
        if (data.currentLocation != null) ...[
          _InfoCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.transportLiveLocation,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.speed_rounded,
                      label:
                          '${data.currentLocation!.speed.toStringAsFixed(0)} km/h',
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.access_time_rounded,
                      label: _formatUpdatedAt(
                          data.currentLocation!.updatedAt, l10n),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Stops timeline
        if (data.stops.isNotEmpty) ...[
          Text(
            l10n.transportStops,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...data.stops.asMap().entries.map((entry) {
            final index = entry.key;
            final stop = entry.value;
            final isPickup = stop.id == data.pickupStopId;
            final isDropoff = stop.id == data.dropoffStopId;
            final isLast = index == data.stops.length - 1;

            return _StopTimeline(
              stop: stop,
              isPickup: isPickup,
              isDropoff: isDropoff,
              isLast: isLast,
              isDark: isDark,
            );
          }),
        ],
      ],
    );
  }

  String _formatUpdatedAt(DateTime? updatedAt, dynamic l10n) {
    if (updatedAt == null) return '-';
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inSeconds < 60) return l10n.transportJustNow;
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    return '${diff.inHours}h';
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _InfoCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.slate500),
          const SizedBox(width: 6),
          Text(label,
              style:
                  theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StopTimeline extends StatelessWidget {
  final BusStopModel stop;
  final bool isPickup;
  final bool isDropoff;
  final bool isLast;
  final bool isDark;

  const _StopTimeline({
    required this.stop,
    required this.isPickup,
    required this.isDropoff,
    required this.isLast,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final highlight = isPickup || isDropoff;

    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: highlight ? AppColors.skyBlue600 : AppColors.slate300,
                    shape: BoxShape.circle,
                    border: highlight
                        ? Border.all(color: AppColors.skyBlue200, width: 3)
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.slate200,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: highlight
                    ? AppColors.skyBlue50
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: highlight
                      ? AppColors.skyBlue200
                      : theme.colorScheme.outline.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        if (stop.estimatedTime != null)
                          Text(
                            stop.estimatedTime!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.slate400),
                          ),
                      ],
                    ),
                  ),
                  if (isPickup)
                    _Badge(
                      label: l10n.transportPickup,
                      color: AppColors.success,
                    ),
                  if (isDropoff)
                    _Badge(
                      label: l10n.transportDropoff,
                      color: AppColors.skyBlue600,
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

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

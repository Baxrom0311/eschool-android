import 'package:flutter/material.dart';

import 'liquid_glass.dart';

/// Loading indicator widgeti - Liquid Glass loading surface.
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const LoadingIndicator({super.key, this.size = 40, this.color, this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: LiquidGlassPanel(
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? colorScheme.primary,
                ),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.64),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Butun ekranni qoplaydigan loading
  static Widget fullScreen({String? message, Color? barrierColor}) {
    return Builder(
      builder: (context) {
        final overlayColor =
            barrierColor ??
            Theme.of(context).colorScheme.scrim.withValues(alpha: 0.12);
        return Container(
          color: overlayColor,
          child: LoadingIndicator(message: message),
        );
      },
    );
  }
}

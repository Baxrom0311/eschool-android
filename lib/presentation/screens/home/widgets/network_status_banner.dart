import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../providers/connectivity_provider.dart';

class NetworkStatusBanner extends ConsumerWidget {
  final Widget child;

  const NetworkStatusBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(connectivityProvider);
    final isOffline = networkStatus == NetworkStatus.offline;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          child,
          if (isOffline)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                bottom: true,
                child: Material(
                  color: AppColors.danger,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Internet aloqasi yo\'q',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

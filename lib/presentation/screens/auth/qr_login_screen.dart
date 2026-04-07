import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/routing/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

/// QR Kod orqali login ekrani
///
/// Kamera ochiladi, QR kodni skanerlaydi va avtomatik login qiladi.
/// QR kodda 64-belgi token saqlanadi.
class QrLoginScreen extends ConsumerStatefulWidget {
  const QrLoginScreen({super.key});

  @override
  ConsumerState<QrLoginScreen> createState() => _QrLoginScreenState();
}

class _QrLoginScreenState extends ConsumerState<QrLoginScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;
  bool _hasScanned = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final l10n = context.l10n;
    if (_isProcessing || _hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final qrToken = barcode.rawValue!.trim();

    // QR token 64 belgidan iborat bo'lishi kerak
    if (qrToken.length != 64) {
      _showError(l10n.qrInvalidFormat);
      return;
    }

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    try {
      await ref.read(authProvider.notifier).qrLogin(qrToken: qrToken);

      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        // Profil ma'lumotlarini yuklash
        await ref.read(userProvider.notifier).loadProfile();
        if (mounted) {
          context.go(RouteNames.home);
        }
      } else {
        _showError(authState.error ?? l10n.qrLoginFailed);
        setState(() {
          _isProcessing = false;
          _hasScanned = false;
        });
      }
    } catch (e) {
      _showError(
        ApiErrorHandler.readableMessage(e, fallback: l10n.qrLoginFailed),
      );
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorScheme.errorContainer,
        content: Text(
          message,
          style: TextStyle(color: colorScheme.onErrorContainer),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final overlayForeground = colorScheme.onPrimary;
    return Scaffold(
      backgroundColor: colorScheme.scrim,
      appBar: AppBar(
        title: Text(l10n.qrLoginTitle),
        backgroundColor: Colors.transparent,
        foregroundColor: overlayForeground,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Kamera
          MobileScanner(controller: _cameraController, onDetect: _onDetect),

          // Overlay — markazda QR kod ramka
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing
                      ? colorScheme.primary
                      : overlayForeground,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Qorong'i overlay tashqarida
          _buildOverlay(context),

          // Pastda ko'rsatma
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_isProcessing)
                  CircularProgressIndicator(color: colorScheme.primary)
                else ...[
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    color: overlayForeground.withValues(alpha: 0.78),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.qrScanInstruction,
                    style: TextStyle(
                      color: overlayForeground.withValues(alpha: 0.78),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.qrAdminInstruction,
                    style: TextStyle(
                      color: overlayForeground.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final overlayColor = Theme.of(
      context,
    ).colorScheme.scrim.withValues(alpha: 0.62);
    return LayoutBuilder(
      builder: (context, constraints) {
        const scanArea = 260.0;
        final left = (constraints.maxWidth - scanArea) / 2;
        final top = (constraints.maxHeight - scanArea) / 2;

        return Stack(
          children: [
            // Top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: top,
              child: Container(color: overlayColor),
            ),
            // Bottom
            Positioned(
              top: top + scanArea,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(color: overlayColor),
            ),
            // Left
            Positioned(
              top: top,
              left: 0,
              width: left,
              height: scanArea,
              child: Container(color: overlayColor),
            ),
            // Right
            Positioned(
              top: top,
              right: 0,
              width: left,
              height: scanArea,
              child: Container(color: overlayColor),
            ),
          ],
        );
      },
    );
  }
}

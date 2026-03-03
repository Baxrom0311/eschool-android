import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_colors.dart';
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
    if (_isProcessing || _hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final qrToken = barcode.rawValue!.trim();

    // QR token 64 belgidan iborat bo'lishi kerak
    if (qrToken.length != 64) {
      _showError('Noto\'g\'ri QR kod formati');
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
        _showError(authState.error ?? 'QR orqali kirish amalga oshmadi');
        setState(() {
          _isProcessing = false;
          _hasScanned = false;
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('QR Kod bilan kirish'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Kamera
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),

          // Overlay — markazda QR kod ramka
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing ? AppColors.success : Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Qorong'i overlay tashqarida
          _buildOverlay(),

          // Pastda ko'rsatma
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_isProcessing)
                  const CircularProgressIndicator(color: Colors.white)
                else ...[
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white70,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'QR kodni kamera oldiga tuting',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Maktab administratori bergan QR kodni skanerlang',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
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

  Widget _buildOverlay() {
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
              child: Container(color: Colors.black54),
            ),
            // Bottom
            Positioned(
              top: top + scanArea,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(color: Colors.black54),
            ),
            // Left
            Positioned(
              top: top,
              left: 0,
              width: left,
              height: scanArea,
              child: Container(color: Colors.black54),
            ),
            // Right
            Positioned(
              top: top,
              right: 0,
              width: left,
              height: scanArea,
              child: Container(color: Colors.black54),
            ),
          ],
        );
      },
    );
  }
}

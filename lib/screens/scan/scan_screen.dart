import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../services/camera_service.dart';
import '../results/results_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _cameraService = CameraService();
  bool _isInitializing = true;
  // Stores a translation *key*, not display text -- this widget builds
  // before we know it's mounted with a valid context for context.tr(), so
  // the message is resolved at build time instead.
  String? _initErrorKey;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _cameraService.initialize();
    } catch (e) {
      _initErrorKey = 'cameraPermissionError';
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  Future<void> _capture() async {
    try {
      final file = await _cameraService.captureImage();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultsScreen(imageFile: File(file.path))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('captureError'))),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _cameraService.pickFromGallery();
      if (picked == null || !mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultsScreen(imageFile: File(picked.path))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('galleryError'))),
      );
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitializing
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _initErrorKey != null
                ? _CameraError(
                    message: context.tr(_initErrorKey!),
                    onPickGallery: _pickFromGallery,
                    onClose: () => Navigator.of(context).pop(),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(_cameraService.controller!),
                      const _LeafFrameOverlay(),
                      Positioned(
                        top: AppConstants.space16,
                        left: AppConstants.space16,
                        child: _CloseButton(onTap: () => Navigator.of(context).pop()),
                      ),
                      Positioned(
                        bottom: AppConstants.space32 + 100,
                        left: AppConstants.space24,
                        right: AppConstants.space24,
                        child: Text(
                          context.tr('scanInstruction'),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(color: Colors.white70),
                        ),
                      ),
                      Positioned(
                        bottom: AppConstants.space32,
                        left: 0,
                        right: 0,
                        child: Center(child: _CaptureButton(onTap: _capture)),
                      ),
                      Positioned(
                        bottom: AppConstants.space32 + 10,
                        left: AppConstants.space24 + 8,
                        child: _GalleryButton(onTap: _pickFromGallery),
                      ),
                    ],
                  ),
      ),
    );
  }
}

/// A framing guide specific to close-up leaf photography, not a generic
/// camera crosshair -- corner brackets rather than a full rectangle, the
/// width a single leaf typically fills, so the farmer knows how close to
/// get before shooting without a heavy shape sitting over the preview.
class _LeafFrameOverlay extends StatelessWidget {
  const _LeafFrameOverlay();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 270,
        height: 270,
        child: const CustomPaint(painter: _CornerFramePainter()),
      ),
    );
  }
}

class _CornerFramePainter extends CustomPainter {
  const _CornerFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.92)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 28.0;
    const r = 22.0;

    canvas.drawPath(
      Path()
        ..moveTo(0, len + r)
        ..lineTo(0, r)
        ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
        ..lineTo(len + r, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len - r, 0)
        ..lineTo(size.width - r, 0)
        ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
        ..lineTo(size.width, len + r),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len - r)
        ..lineTo(0, size.height - r)
        ..arcToPoint(Offset(r, size.height), radius: const Radius.circular(r))
        ..lineTo(len + r, size.height),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len - r, size.height)
        ..lineTo(size.width - r, size.height)
        ..arcToPoint(Offset(size.width, size.height - r), radius: const Radius.circular(r))
        ..lineTo(size.width, size.height - len - r),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerFramePainter oldDelegate) => false;
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CaptureButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12)],
        ),
        child: const DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        ),
      ),
    );
  }
}

/// Opens the system photo picker as an alternative to the live camera --
/// placed beside, not on top of, the capture button so both stay reachable
/// with a thumb without guessing which one is primary.
class _GalleryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GalleryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.16),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.4),
        ),
        child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  final String message;
  final VoidCallback onPickGallery;
  final VoidCallback onClose;
  const _CameraError({required this.message, required this.onPickGallery, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_rounded, color: Colors.white70, size: 40),
            const SizedBox(height: AppConstants.space16),
            Text(message, style: AppTextStyles.bodyLarge.copyWith(color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: AppConstants.space24),
            // Camera access denied doesn't have to be a dead end -- the
            // farmer can still diagnose a leaf photo from their gallery.
            OutlinedButton.icon(
              onPressed: onPickGallery,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
              ),
              icon: const Icon(Icons.photo_library_rounded, size: 18),
              label: Text(context.tr('galleryLabel')),
            ),
            const SizedBox(height: AppConstants.space12),
            TextButton(
              onPressed: onClose,
              child: Text(context.tr('goBack'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

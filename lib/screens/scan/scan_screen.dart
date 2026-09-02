import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
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
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _cameraService.initialize();
    } catch (e) {
      _initError = "Couldn't access the camera. Check camera permissions in Settings.";
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
        const SnackBar(content: Text("Couldn't capture that photo. Try again.")),
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
            : _initError != null
                ? _CameraError(message: _initError!, onClose: () => Navigator.of(context).pop())
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
                        bottom: AppConstants.space32 + 96,
                        left: AppConstants.space24,
                        right: AppConstants.space24,
                        child: Text(
                          'Center the leaf, fill the frame, avoid shadows',
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
                    ],
                  ),
      ),
    );
  }
}

/// A framing guide specific to close-up leaf photography, not a generic
/// camera crosshair -- rounded corners the width a single leaf typically
/// fills, so the farmer knows how close to get before shooting.
class _LeafFrameOverlay extends StatelessWidget {
  const _LeafFrameOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.85), width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
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
        ),
        child: const DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        ),
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
  final VoidCallback onClose;
  const _CameraError({required this.message, required this.onClose});

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
            TextButton(
              onPressed: onClose,
              child: const Text('Go back', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

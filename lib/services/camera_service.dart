import 'package:camera/camera.dart';

/// Wraps the device camera controller. Kept separate from the scan screen so
/// the camera lifecycle (initialize/dispose) is easy to reason about and
/// test independently of the UI.
class CameraService {
  CameraController? controller;
  List<CameraDescription> _cameras = [];

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw StateError('No camera found on this device.');
    }
    controller = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller!.initialize();
  }

  Future<XFile> captureImage() async {
    if (controller == null || !controller!.value.isInitialized) {
      throw StateError('Camera is not initialized.');
    }
    return controller!.takePicture();
  }

  void dispose() {
    controller?.dispose();
  }
}

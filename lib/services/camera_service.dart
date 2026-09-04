import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

/// Wraps the device camera controller and gallery access. Kept separate
/// from the scan screen so the camera lifecycle (initialize/dispose) is
/// easy to reason about and test independently of the UI.
class CameraService {
  CameraController? controller;
  List<CameraDescription> _cameras = [];
  final ImagePicker _picker = ImagePicker();

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

  /// Lets the farmer pick an existing photo instead of using the live
  /// camera -- useful for a leaf photographed earlier, or shared to them by
  /// someone else. Returns null if they cancel the picker; that's a normal
  /// outcome, not an error.
  Future<XFile?> pickFromGallery() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      imageQuality: 92,
    );
  }

  void dispose() {
    controller?.dispose();
  }
}

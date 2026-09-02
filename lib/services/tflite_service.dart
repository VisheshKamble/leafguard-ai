import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../core/constants/app_constants.dart';

class Prediction {
  final int labelIndex;
  final String label;
  final double confidence;

  const Prediction({
    required this.labelIndex,
    required this.label,
    required this.confidence,
  });
}

/// Wraps the on-device TFLite interpreter. Loads once at app startup and is
/// reused across scans -- there is no network call anywhere in this class,
/// by design, since offline inference is the entire point of this app.
class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  bool get isReady => _interpreter != null && _labels.isNotEmpty;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(AppConstants.modelAssetPath);
    final labelsRaw = await rootBundle.loadString(AppConstants.labelsAssetPath);
    _labels = labelsRaw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<Prediction> predict(File imageFile) async {
    if (!isReady) {
      throw StateError('TFLiteService.loadModel() must complete before predict() is called.');
    }

    final rawBytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw ArgumentError('Could not decode image at ${imageFile.path}');
    }

    final resized = img.copyResize(
      decoded,
      width: AppConstants.modelInputSize,
      height: AppConstants.modelInputSize,
    );

    // Model expects a uint8 input tensor (full-integer quantized),
    // shape [1, height, width, 3].
    final input = List.generate(
      1,
      (_) => List.generate(
        AppConstants.modelInputSize,
        (y) => List.generate(
          AppConstants.modelInputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
          },
        ),
      ),
    );

    final output = List.generate(1, (_) => List.filled(_labels.length, 0));

    _interpreter!.run(input, output);

    final scores = output[0];
    var bestIndex = 0;
    var bestScore = 0;
    for (var i = 0; i < scores.length; i++) {
      final score = scores[i] as int;
      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }

    // Output is quantized uint8 (0-255) representing the softmax probability
    // of the top class -- scale back to 0.0-1.0. Adjust this if your export
    // used different output quantization parameters than the training
    // notebook's defaults.
    return Prediction(
      labelIndex: bestIndex,
      label: _labels[bestIndex],
      confidence: bestScore / 255.0,
    );
  }

  void dispose() {
    _interpreter?.close();
  }
}

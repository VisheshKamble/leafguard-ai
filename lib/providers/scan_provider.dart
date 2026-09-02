import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/data/disease_catalog.dart';
import '../models/scan_result.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_service.dart';
import '../services/tflite_service.dart';

enum ScanStatus { idle, analyzing, done, error }

/// Drives the scan -> analyze -> result flow. This is the core loop of the
/// app: everything here runs on-device except the best-effort cloud sync,
/// which never blocks or fails the result the farmer sees.
class ScanProvider extends ChangeNotifier {
  final TFLiteService _tfliteService;
  final LocalStorageService _localStorageService;
  final SupabaseService _supabaseService;

  ScanProvider(this._tfliteService, this._localStorageService, this._supabaseService);

  ScanStatus status = ScanStatus.idle;
  ScanResult? lastResult;
  String? errorMessage;

  Future<void> analyzeImage(File imageFile) async {
    status = ScanStatus.analyzing;
    errorMessage = null;
    notifyListeners();

    try {
      final prediction = await _tfliteService.predict(imageFile);
      final diagnosis = DiseaseCatalog.lookup(prediction.label);

      final severity = diagnosis.isHealthy
          ? Severity.healthy
          : (prediction.confidence >= 0.75 ? Severity.severe : Severity.mild);

      final result = ScanResult(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        imagePath: imageFile.path,
        diagnosis: diagnosis,
        confidence: prediction.confidence,
        severity: severity,
      );

      await _localStorageService.saveScan(result);
      unawaited(_supabaseService.syncScan(result.toMap()));

      lastResult = result;
      status = ScanStatus.done;
    } catch (e) {
      errorMessage = "Couldn't analyze that photo. Try again with the leaf centered and well lit.";
      status = ScanStatus.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    status = ScanStatus.idle;
    lastResult = null;
    errorMessage = null;
    notifyListeners();
  }
}

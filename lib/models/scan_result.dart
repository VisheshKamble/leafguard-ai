import 'disease_info.dart';

enum Severity { healthy, mild, severe }

class ScanResult {
  final String id;
  final DateTime timestamp;
  final String imagePath;
  final DiseaseInfo diagnosis;
  final double confidence; // 0.0 - 1.0
  final Severity severity;

  const ScanResult({
    required this.id,
    required this.timestamp,
    required this.imagePath,
    required this.diagnosis,
    required this.confidence,
    required this.severity,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'imagePath': imagePath,
        'className': diagnosis.className,
        'confidence': confidence,
        'severity': severity.name,
      };
}

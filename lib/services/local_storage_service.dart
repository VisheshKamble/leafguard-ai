import 'package:hive_flutter/hive_flutter.dart';
import '../models/scan_result.dart';

/// Local-first storage for scan history using Hive. This is the source of
/// truth for what the app shows -- it works fully offline. SupabaseService
/// mirrors saved scans to the cloud opportunistically, but the app never
/// waits on that to function.
class LocalStorageService {
  static const String _boxName = 'scan_history';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  Future<void> saveScan(ScanResult result) async {
    await _box.put(result.id, result.toMap());
  }

  List<Map> getAllScans() {
    final scans = _box.values.cast<Map>().toList();
    scans.sort((a, b) => (b['timestamp'] as String).compareTo(a['timestamp'] as String));
    return scans;
  }

  Future<void> deleteScan(String id) async {
    await _box.delete(id);
  }
}

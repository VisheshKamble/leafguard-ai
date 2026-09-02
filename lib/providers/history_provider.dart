import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  final LocalStorageService _localStorageService;

  HistoryProvider(this._localStorageService);

  List<Map> get scans => _localStorageService.getAllScans();

  void refresh() => notifyListeners();

  Future<void> deleteScan(String id) async {
    await _localStorageService.deleteScan(id);
    notifyListeners();
  }
}

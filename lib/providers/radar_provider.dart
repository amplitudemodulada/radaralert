import 'package:flutter/material.dart';
import '../models/radar_point.dart';
import '../services/radar_database.dart';
import '../services/radar_update_service.dart';
import '../utils/constants.dart';

enum UpdateStatus { idle, updating, success, error }

class RadarProvider extends ChangeNotifier {
  final RadarDatabase _db = RadarDatabase();
  final RadarUpdateService _updateService = RadarUpdateService();

  List<RadarPoint> _nearby = [];
  List<RadarPoint> _all = [];
  UpdateStatus _updateStatus = UpdateStatus.idle;
  String _updateMessage = '';
  int _dbCount = 0;
  bool _initialized = false;

  List<RadarPoint> get nearby => _nearby;
  List<RadarPoint> get all => _all;
  UpdateStatus get updateStatus => _updateStatus;
  String get updateMessage => _updateMessage;
  int get dbCount => _dbCount;
  bool get initialized => _initialized;

  RadarPoint? get nearest => _nearby.isEmpty ? null : _nearby.first;

  Future<void> init() async {
    _dbCount = await _db.count();
    _all = await _db.getAll();
    _initialized = true;
    notifyListeners();
  }

  Future<void> updateNearby(double lat, double lon) async {
    final radius = AppConstants.nearbyRadarRadiusKm.toDouble();
    final list = await _db.getNearby(lat, lon, radius);
    list.sort((a, b) =>
        a.distanceTo(lat, lon).compareTo(b.distanceTo(lat, lon)));
    _nearby = list;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    _all = await _db.getAll();
    _dbCount = _all.length;
    notifyListeners();
  }

  Future<void> checkForUpdates() async {
    _updateStatus = UpdateStatus.updating;
    _updateMessage = 'Verificando atualizações...';
    notifyListeners();

    final result = await _updateService.fetchUpdates();
    if (result.success) {
      _dbCount = await _db.count();
      _all = await _db.getAll();
      _updateStatus = UpdateStatus.success;
      _updateMessage = '${result.count} radares atualizados';
    } else {
      _updateStatus = UpdateStatus.error;
      _updateMessage = result.error ?? 'Erro desconhecido';
    }
    notifyListeners();

    await Future.delayed(const Duration(seconds: 3));
    _updateStatus = UpdateStatus.idle;
    notifyListeners();
  }
}

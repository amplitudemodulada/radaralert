import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alert_config.dart';
import '../models/radar_point.dart';
import '../services/alert_service.dart';
import '../utils/constants.dart';
import 'speed_provider.dart';
import 'radar_provider.dart';

enum AlertType { none, radarNear, radarCritical, speedExcess }

class AlertProvider extends ChangeNotifier {
  final AlertService _alertService = AlertService();

  AlertConfig _config = AlertConfig();
  AlertType _activeAlert = AlertType.none;
  RadarPoint? _alertRadar;
  double _alertDistance = 0;
  DateTime? _lastAlertTime;

  AlertConfig get config => _config;
  AlertType get activeAlert => _activeAlert;
  RadarPoint? get alertRadar => _alertRadar;
  double get alertDistance => _alertDistance;
  bool get isAlerting => _activeAlert != AlertType.none;

  AlertProvider() {
    _alertService.init();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('alert_config');
    if (raw != null) {
      _config =
          AlertConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      notifyListeners();
    }
  }

  Future<void> saveConfig(AlertConfig config) async {
    _config = config;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alert_config', jsonEncode(config.toJson()));
    notifyListeners();
  }

  void update(SpeedProvider speed, RadarProvider radar) {
    if (!speed.hasLocation) return;
    final nearest = radar.nearest;

    if (nearest == null) {
      _clearAlert();
      return;
    }

    final dist = nearest.distanceTo(speed.latitude!, speed.longitude!);
    final alertDist = _config.alertDistanceMeters.toDouble();
    final tolerance = _config.speedTolerancePercent / 100;
    final speedLimit = nearest.velocidadeMaxima * (1 + tolerance);
    final isOverSpeed = speed.speedKmh > speedLimit;

    if (dist <= AppConstants.criticalDistanceMeters && isOverSpeed) {
      _triggerAlert(AlertType.radarCritical, nearest, dist);
    } else if (dist <= alertDist) {
      _triggerAlert(AlertType.radarNear, nearest, dist);
    } else if (isOverSpeed) {
      _triggerAlert(AlertType.speedExcess, nearest, dist);
    } else {
      _clearAlert();
    }
  }

  void _triggerAlert(AlertType type, RadarPoint radar, double dist) {
    final now = DateTime.now();
    const cooldown = Duration(seconds: 5);
    if (_lastAlertTime != null &&
        now.difference(_lastAlertTime!) < cooldown) {
      _activeAlert = type;
      _alertRadar = radar;
      _alertDistance = dist;
      notifyListeners();
      return;
    }

    _lastAlertTime = now;
    _activeAlert = type;
    _alertRadar = radar;
    _alertDistance = dist;
    notifyListeners();

    if (type == AlertType.radarCritical || type == AlertType.speedExcess) {
      _alertService.playSpeedAlert(_config);
      _alertService.vibrate(_config, intense: true);
      _alertService.showNotification(
        title: '⚠️ Atenção!',
        body: type == AlertType.radarCritical
            ? 'Radar a ${dist.round()}m - Velocidade: ${radar.velocidadeMaxima} km/h'
            : 'Velocidade acima do limite: ${radar.velocidadeMaxima} km/h',
        config: _config,
      );
    } else {
      _alertService.playRadarAlert(_config);
      _alertService.vibrate(_config);
    }
  }

  void _clearAlert() {
    if (_activeAlert != AlertType.none) {
      _activeAlert = AlertType.none;
      _alertRadar = null;
      _alertDistance = 0;
      notifyListeners();
    }
  }

  void dismiss() => _clearAlert();

  @override
  void dispose() {
    _alertService.dispose();
    super.dispose();
  }
}

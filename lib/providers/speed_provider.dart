import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/gps_service.dart';

enum GpsStatus { disabled, searching, active }

class SpeedProvider extends ChangeNotifier {
  final GpsService _gps = GpsService();

  GpsStatus _status = GpsStatus.searching;
  double _speedKmh = 0;
  double _heading = 0;
  double? _latitude;
  double? _longitude;
  double _accuracy = 0;
  int _satellites = 0;
  double _maxSpeed = 0;
  double _distanceKm = 0;
  Position? _lastPosition;

  GpsStatus get status => _status;
  double get speedKmh => _speedKmh;
  double get heading => _heading;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  double get accuracy => _accuracy;
  int get satellites => _satellites;
  double get maxSpeed => _maxSpeed;
  double get distanceKm => _distanceKm;
  bool get hasLocation => _latitude != null && _longitude != null;

  Future<void> init() async {
    final granted = await _gps.requestPermissions();
    if (!granted) {
      _status = GpsStatus.disabled;
      notifyListeners();
      return;
    }

    final last = await _gps.lastKnownPosition();
    if (last != null) _applyPosition(last);

    _gps.positionStream().listen(
      _applyPosition,
      onError: (_) {
        _status = GpsStatus.searching;
        notifyListeners();
      },
    );
  }

  void _applyPosition(Position pos) {
    if (_lastPosition != null) {
      _distanceKm += Geolocator.distanceBetween(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            pos.latitude,
            pos.longitude,
          ) /
          1000;
    }
    _lastPosition = pos;
    _latitude = pos.latitude;
    _longitude = pos.longitude;
    _speedKmh = (pos.speed * 3.6).clamp(0, 300);
    _heading = pos.heading;
    _accuracy = pos.accuracy;
    _status = GpsStatus.active;
    if (_speedKmh > _maxSpeed) _maxSpeed = _speedKmh;
    notifyListeners();
  }

  String get headingLabel {
    final dirs = ['N', 'NE', 'L', 'SE', 'S', 'SO', 'O', 'NO'];
    return dirs[((_heading + 22.5) / 45).floor() % 8];
  }
}

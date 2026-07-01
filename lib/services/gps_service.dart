import 'package:geolocator/geolocator.dart';

class GpsService {
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 5,
  );

  Future<bool> requestPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Stream<Position> positionStream() =>
      Geolocator.getPositionStream(locationSettings: _locationSettings);

  Future<Position?> lastKnownPosition() =>
      Geolocator.getLastKnownPosition();
}

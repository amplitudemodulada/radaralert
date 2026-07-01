class AppConstants {
  static const String appName = 'RadarAlert';
  static const double defaultAlertDistanceMeters = 500.0;
  static const double criticalDistanceMeters = 200.0;
  static const double warningDistanceMeters = 300.0;
  static const double maxSpeedKmh = 300.0;
  static const String radarApiUrl = 'https://api.radares.com.br/v1/radares';
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const double defaultMapZoom = 16.0;
  static const int nearbyRadarRadiusKm = 3;
  static const String dbName = 'radaralert.db';
  static const int dbVersion = 1;
}

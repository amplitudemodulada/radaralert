class AlertConfig {
  bool soundEnabled;
  bool vibrationEnabled;
  bool notificationEnabled;
  int alertDistanceMeters;
  double speedTolerancePercent;
  double volume;

  AlertConfig({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.notificationEnabled = true,
    this.alertDistanceMeters = 500,
    this.speedTolerancePercent = 0.0,
    this.volume = 0.8,
  });

  factory AlertConfig.fromJson(Map<String, dynamic> json) => AlertConfig(
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
        notificationEnabled: json['notificationEnabled'] as bool? ?? true,
        alertDistanceMeters: json['alertDistanceMeters'] as int? ?? 500,
        speedTolerancePercent:
            (json['speedTolerancePercent'] as num?)?.toDouble() ?? 0.0,
        volume: (json['volume'] as num?)?.toDouble() ?? 0.8,
      );

  Map<String, dynamic> toJson() => {
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'notificationEnabled': notificationEnabled,
        'alertDistanceMeters': alertDistanceMeters,
        'speedTolerancePercent': speedTolerancePercent,
        'volume': volume,
      };

  AlertConfig copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? notificationEnabled,
    int? alertDistanceMeters,
    double? speedTolerancePercent,
    double? volume,
  }) =>
      AlertConfig(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
        notificationEnabled: notificationEnabled ?? this.notificationEnabled,
        alertDistanceMeters: alertDistanceMeters ?? this.alertDistanceMeters,
        speedTolerancePercent:
            speedTolerancePercent ?? this.speedTolerancePercent,
        volume: volume ?? this.volume,
      );
}

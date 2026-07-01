import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/speed_provider.dart';
import '../providers/radar_provider.dart';
import '../widgets/analog_speedometer.dart';
import '../widgets/digital_speed.dart';
import '../widgets/gps_status_indicator.dart';
import '../widgets/radar_alert_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _radarTimer;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _radarTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final speed = context.read<SpeedProvider>();
      if (speed.hasLocation) {
        context.read<RadarProvider>().updateNearby(
              speed.latitude!,
              speed.longitude!,
            );
      }
    });
  }

  @override
  void dispose() {
    _radarTimer?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speed = context.watch<SpeedProvider>();
    final radar = context.watch<RadarProvider>();
    final nearest = radar.nearest;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      const Text(
                        'RadarAlert',
                        style: TextStyle(
                          color: Color(0xFF00BCD4),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      const GpsStatusIndicator(),
                      const SizedBox(width: 8),
                      IconButton(
                        icon:
                            const Icon(Icons.settings, color: Colors.white54),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/settings'),
                      ),
                    ],
                  ),
                ),

                // Speedometer
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AnalogSpeedometer(speedKmh: speed.speedKmh),
                  ),
                ),

                // Speed limit badge (if near radar)
                if (nearest != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: nearest.tipoColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: nearest.tipoColor.withOpacity(0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(nearest.tipoIcon,
                            color: nearest.tipoColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${nearest.tipoLabel}  •  LIMITE: ${nearest.velocidadeMaxima} km/h',
                          style: TextStyle(
                              color: nearest.tipoColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                // Digital speed + stats
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: DigitalSpeedCard(),
                ),

                // Bottom stats
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.speed,
                          label: 'Vel. Máx.',
                          value: '${speed.maxSpeed.round()} km/h',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.route,
                          label: 'Distância',
                          value: speed.distanceKm < 1
                              ? '${(speed.distanceKm * 1000).round()} m'
                              : '${speed.distanceKm.toStringAsFixed(1)} km',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.radar,
                          label: 'Radares',
                          value: '${radar.dbCount}',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Alert overlay
          const RadarAlertOverlay(),

          // Map FAB
          Positioned(
            right: 16,
            bottom: 90,
            child: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/map'),
              backgroundColor: const Color(0xFF00BCD4),
              child: const Icon(Icons.map, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141824),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00BCD4), size: 16),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

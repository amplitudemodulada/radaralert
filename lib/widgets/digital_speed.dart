import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/speed_provider.dart';

class DigitalSpeedCard extends StatelessWidget {
  const DigitalSpeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final speed = context.watch<SpeedProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141824),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
            icon: Icons.speed,
            label: 'Velocidade',
            value: '${speed.speedKmh.round()}',
            unit: 'km/h',
            color: _speedColor(speed.speedKmh),
          ),
          _Stat(
            icon: Icons.explore,
            label: 'Direção',
            value: speed.headingLabel,
            unit: '${speed.heading.round()}°',
            color: Colors.white70,
          ),
          _Stat(
            icon: Icons.my_location,
            label: 'Precisão',
            value: '${speed.accuracy.round()}',
            unit: 'm',
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Color _speedColor(double kmh) {
    if (kmh < 60) return const Color(0xFF4CAF50);
    if (kmh < 100) return const Color(0xFFFFEB3B);
    if (kmh < 140) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(unit,
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 9)),
      ],
    );
  }
}

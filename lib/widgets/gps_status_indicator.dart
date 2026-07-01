import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/speed_provider.dart';

class GpsStatusIndicator extends StatelessWidget {
  const GpsStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<SpeedProvider, GpsStatus>((p) => p.status);
    final (color, label, icon) = switch (status) {
      GpsStatus.active => (
          const Color(0xFF4CAF50),
          'GPS Ativo',
          Icons.gps_fixed
        ),
      GpsStatus.searching => (
          const Color(0xFFFFEB3B),
          'Buscando...',
          Icons.gps_not_fixed
        ),
      GpsStatus.disabled => (
          const Color(0xFFF44336),
          'GPS Inativo',
          Icons.gps_off
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';

class RadarAlertOverlay extends StatefulWidget {
  const RadarAlertOverlay({super.key});

  @override
  State<RadarAlertOverlay> createState() => _RadarAlertOverlayState();
}

class _RadarAlertOverlayState extends State<RadarAlertOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(_pulse);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alert = context.watch<AlertProvider>();
    if (!alert.isAlerting) return const SizedBox.shrink();

    final radar = alert.alertRadar;
    final dist = alert.alertDistance.round();
    final isCritical = alert.activeAlert == AlertType.radarCritical ||
        alert.activeAlert == AlertType.speedExcess;

    final color =
        isCritical ? const Color(0xFFF44336) : const Color(0xFFFF9800);
    final icon = isCritical ? Icons.warning_rounded : Icons.radar;
    final title = switch (alert.activeAlert) {
      AlertType.radarCritical => 'RADAR CRÍTICO',
      AlertType.speedExcess => 'EXCESSO DE VELOCIDADE',
      AlertType.radarNear => 'RADAR À FRENTE',
      AlertType.none => '',
    };

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Transform.scale(
          scaleY: _pulseAnim.value,
          alignment: Alignment.topCenter,
          child: child,
        ),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 50, 12, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.92),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    if (radar != null) ...[
                      Text(
                        '${radar.tipoLabel} • ${radar.velocidadeMaxima} km/h',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        'Distância: ${dist}m',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      if (radar.descricao.isNotEmpty)
                        Text(radar.descricao,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => context.read<AlertProvider>().dismiss(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

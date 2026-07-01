import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/alert_provider.dart';
import '../providers/radar_provider.dart';
import '../models/alert_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alertProv = context.watch<AlertProvider>();
    final radarProv = context.watch<RadarProvider>();
    final config = alertProv.config;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141824),
        title: const Text('Configurações',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Alertas',
            icon: Icons.notifications,
            children: [
              _SwitchTile(
                label: 'Alertas sonoros',
                icon: Icons.volume_up,
                value: config.soundEnabled,
                onChanged: (v) =>
                    alertProv.saveConfig(config.copyWith(soundEnabled: v)),
              ),
              if (config.soundEnabled)
                _SliderTile(
                  label: 'Volume',
                  icon: Icons.speaker,
                  value: config.volume,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  display: '${(config.volume * 100).round()}%',
                  onChanged: (v) =>
                      alertProv.saveConfig(config.copyWith(volume: v)),
                ),
              _SwitchTile(
                label: 'Vibração',
                icon: Icons.vibration,
                value: config.vibrationEnabled,
                onChanged: (v) => alertProv
                    .saveConfig(config.copyWith(vibrationEnabled: v)),
              ),
              _SwitchTile(
                label: 'Notificações',
                icon: Icons.notifications_active,
                value: config.notificationEnabled,
                onChanged: (v) => alertProv
                    .saveConfig(config.copyWith(notificationEnabled: v)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Detecção',
            icon: Icons.radar,
            children: [
              _SliderTile(
                label: 'Distância de alerta',
                icon: Icons.social_distance,
                value: config.alertDistanceMeters.toDouble(),
                min: 100,
                max: 2000,
                divisions: 19,
                display: '${config.alertDistanceMeters} m',
                onChanged: (v) => alertProv.saveConfig(
                    config.copyWith(alertDistanceMeters: v.round())),
              ),
              _SliderTile(
                label: 'Tolerância de velocidade',
                icon: Icons.speed,
                value: config.speedTolerancePercent,
                min: 0,
                max: 20,
                divisions: 20,
                display: '${config.speedTolerancePercent.round()}%',
                onChanged: (v) => alertProv
                    .saveConfig(config.copyWith(speedTolerancePercent: v)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Banco de Dados',
            icon: Icons.storage,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.radar, color: Colors.white70),
                title: const Text('Radares cadastrados',
                    style: TextStyle(color: Colors.white70)),
                trailing: Text('${radarProv.dbCount}',
                    style: const TextStyle(
                        color: Color(0xFF00BCD4),
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (radarProv.updateStatus == UpdateStatus.updating)
                      const LinearProgressIndicator(
                          color: Color(0xFF00BCD4)),
                    if (radarProv.updateMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          radarProv.updateMessage,
                          style: TextStyle(
                            color: radarProv.updateStatus ==
                                    UpdateStatus.error
                                ? Colors.red
                                : const Color(0xFF4CAF50),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Atualizar Radares Online'),
                      onPressed:
                          radarProv.updateStatus == UpdateStatus.updating
                              ? null
                              : () async {
                                  final conn = await Connectivity()
                                      .checkConnectivity();
                                  if (conn == ConnectivityResult.none &&
                                      context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Sem conexão com a internet')),
                                    );
                                    return;
                                  }
                                  radarProv.checkForUpdates();
                                },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Sobre',
            icon: Icons.info,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.apps, color: Colors.white54),
                title: const Text('RadarAlert',
                    style: TextStyle(color: Colors.white70)),
                trailing: const Text('v1.0.0',
                    style: TextStyle(color: Colors.white38)),
              ),
              const ListTile(
                leading: Icon(Icons.map, color: Colors.white54),
                title: Text('Mapa',
                    style: TextStyle(color: Colors.white70)),
                trailing: Text('OpenStreetMap',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section(
      {required this.title,
      required this.icon,
      required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141824),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF00BCD4), size: 18),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFF00BCD4),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.white54),
      title: Text(label,
          style: const TextStyle(color: Colors.white70)),
      value: value,
      activeColor: const Color(0xFF00BCD4),
      onChanged: onChanged,
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
              const Spacer(),
              Text(display,
                  style: const TextStyle(
                      color: Color(0xFF00BCD4),
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: const Color(0xFF00BCD4),
            inactiveColor: Colors.white12,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

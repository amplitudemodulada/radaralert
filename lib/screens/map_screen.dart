import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/speed_provider.dart';
import '../providers/radar_provider.dart';
import '../models/radar_point.dart';
import '../utils/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _followUser = true;

  @override
  Widget build(BuildContext context) {
    final speed = context.watch<SpeedProvider>();
    final radar = context.watch<RadarProvider>();

    final userLatLng = speed.hasLocation
        ? LatLng(speed.latitude!, speed.longitude!)
        : const LatLng(-23.5505, -46.6333);

    if (_followUser && speed.hasLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(userLatLng, AppConstants.defaultMapZoom);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141824),
        title: const Text('Mapa de Radares',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _followUser ? Icons.gps_fixed : Icons.gps_not_fixed,
              color: _followUser
                  ? const Color(0xFF00BCD4)
                  : Colors.white54,
            ),
            onPressed: () => setState(() => _followUser = !_followUser),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: userLatLng,
          initialZoom: AppConstants.defaultMapZoom,
          onPositionChanged: (_, hasGesture) {
            if (hasGesture) setState(() => _followUser = false);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: AppConstants.osmTileUrl,
            userAgentPackageName: 'com.radaralert.app',
            maxNativeZoom: 19,
          ),
          MarkerLayer(
            markers: [
              // Radar markers
              ...radar.all.map((r) => Marker(
                    point: LatLng(r.latitude, r.longitude),
                    width: 36,
                    height: 36,
                    child: _RadarMarker(radar: r),
                  )),
              // User location marker
              if (speed.hasLocation)
                Marker(
                  point: userLatLng,
                  width: 50,
                  height: 50,
                  child: const _UserMarker(),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: const Color(0xFF00BCD4),
        onPressed: () {
          setState(() => _followUser = true);
          _mapController.move(userLatLng, AppConstants.defaultMapZoom);
        },
        child: const Icon(Icons.my_location, color: Colors.black),
      ),
    );
  }
}

class _RadarMarker extends StatelessWidget {
  final RadarPoint radar;
  const _RadarMarker({required this.radar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF141824),
          builder: (_) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(radar.tipoIcon, color: radar.tipoColor),
                  const SizedBox(width: 8),
                  Text(radar.tipoLabel,
                      style: TextStyle(
                          color: radar.tipoColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ]),
                const SizedBox(height: 8),
                Text('Limite: ${radar.velocidadeMaxima} km/h',
                    style:
                        const TextStyle(color: Colors.white, fontSize: 14)),
                if (radar.descricao.isNotEmpty)
                  Text(radar.descricao,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                Text('Direção: ${radar.direcao}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: radar.tipoColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: radar.tipoColor.withOpacity(0.5), blurRadius: 6)
          ],
        ),
        child: Icon(radar.tipoIcon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _UserMarker extends StatelessWidget {
  const _UserMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF00BCD4).withOpacity(0.2),
        border: Border.all(color: const Color(0xFF00BCD4), width: 2),
      ),
      child: const Icon(Icons.navigation,
          color: Color(0xFF00BCD4), size: 28),
    );
  }
}

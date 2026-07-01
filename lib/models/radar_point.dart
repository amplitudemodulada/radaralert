import 'dart:math';
import 'package:flutter/material.dart';

class RadarPoint {
  final int id;
  final double latitude;
  final double longitude;
  final String tipo;
  final int velocidadeMaxima;
  final String direcao;
  final String descricao;
  final bool ativo;

  const RadarPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.tipo,
    required this.velocidadeMaxima,
    required this.direcao,
    required this.descricao,
    required this.ativo,
  });

  factory RadarPoint.fromJson(Map<String, dynamic> json) => RadarPoint(
        id: json['id'] as int,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        tipo: json['tipo'] as String,
        velocidadeMaxima: json['velocidade_maxima'] as int,
        direcao: json['direcao'] as String? ?? 'ambos',
        descricao: json['descricao'] as String? ?? '',
        ativo: json['ativo'] == true || json['ativo'] == 1,
      );

  factory RadarPoint.fromDb(Map<String, dynamic> row) => RadarPoint(
        id: row['id'] as int,
        latitude: row['latitude'] as double,
        longitude: row['longitude'] as double,
        tipo: row['tipo'] as String,
        velocidadeMaxima: row['velocidade_maxima'] as int,
        direcao: row['direcao'] as String,
        descricao: row['descricao'] as String,
        ativo: (row['ativo'] as int) == 1,
      );

  Map<String, dynamic> toDb() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'tipo': tipo,
        'velocidade_maxima': velocidadeMaxima,
        'direcao': direcao,
        'descricao': descricao,
        'ativo': ativo ? 1 : 0,
      };

  double distanceTo(double lat, double lon) {
    const R = 6371000.0;
    final dLat = _rad(lat - latitude);
    final dLon = _rad(lon - longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(latitude)) * cos(_rad(lat)) * sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _rad(double deg) => deg * pi / 180;

  String get tipoLabel {
    switch (tipo) {
      case 'fixo':
        return 'Fixo';
      case 'movel':
        return 'Móvel';
      case 'pedagio':
        return 'Pedágio';
      case 'semaforo':
        return 'Semáforo';
      default:
        return tipo;
    }
  }

  Color get tipoColor {
    switch (tipo) {
      case 'fixo':
        return const Color(0xFFE53935);
      case 'movel':
        return const Color(0xFFFF6F00);
      case 'pedagio':
        return const Color(0xFF8E24AA);
      case 'semaforo':
        return const Color(0xFF1E88E5);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData get tipoIcon {
    switch (tipo) {
      case 'fixo':
        return Icons.speed;
      case 'movel':
        return Icons.local_police;
      case 'pedagio':
        return Icons.toll;
      case 'semaforo':
        return Icons.traffic;
      default:
        return Icons.radar;
    }
  }
}

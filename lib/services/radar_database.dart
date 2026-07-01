import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/radar_point.dart';
import '../utils/constants.dart';

class RadarDatabase {
  Database? _db;

  Future<Database> get _database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = p.join(await getDatabasesPath(), AppConstants.dbName);
    return openDatabase(
      dbPath,
      version: AppConstants.dbVersion,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE radares (
            id INTEGER PRIMARY KEY,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            tipo TEXT NOT NULL,
            velocidade_maxima INTEGER NOT NULL,
            direcao TEXT DEFAULT 'ambos',
            descricao TEXT DEFAULT '',
            ativo INTEGER DEFAULT 1
          )
        ''');
        await _seed(db);
      },
    );
  }

  Future<void> _seed(Database db) async {
    final raw = await rootBundle.loadString('assets/data/radares.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final list = data['radares'] as List;
    final batch = db.batch();
    for (final item in list) {
      batch.insert(
        'radares',
        RadarPoint.fromJson(item as Map<String, dynamic>).toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<RadarPoint>> getNearby(
      double lat, double lon, double radiusKm) async {
    final db = await _database;
    final latD = radiusKm / 111.0;
    final lonD = radiusKm / (111.0 * cos(lat * pi / 180));
    final rows = await db.query(
      'radares',
      where:
          'ativo=1 AND latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?',
      whereArgs: [lat - latD, lat + latD, lon - lonD, lon + lonD],
    );
    return rows.map(RadarPoint.fromDb).toList();
  }

  Future<List<RadarPoint>> getAll() async {
    final db = await _database;
    final rows = await db.query('radares', where: 'ativo=1');
    return rows.map(RadarPoint.fromDb).toList();
  }

  Future<int> count() async {
    final db = await _database;
    final r = await db.rawQuery('SELECT COUNT(*) as c FROM radares');
    return r.first['c'] as int;
  }

  Future<void> upsertAll(List<RadarPoint> radares) async {
    final db = await _database;
    final batch = db.batch();
    for (final r in radares) {
      batch.insert('radares', r.toDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}

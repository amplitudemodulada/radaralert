import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import '../models/alert_config.dart';

class AlertService {
  final AudioPlayer _player = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notif =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _notif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialized = true;
  }

  Future<void> playRadarAlert(AlertConfig config) async {
    if (!config.soundEnabled) return;
    final wav = _generateBeep(frequency: 1200, durationMs: 300);
    await _player.setVolume(config.volume);
    await _player.play(BytesSource(wav));
  }

  Future<void> playSpeedAlert(AlertConfig config) async {
    if (!config.soundEnabled) return;
    // Two quick high beeps for speed excess
    final wav = _generateBeep(frequency: 1800, durationMs: 200);
    await _player.setVolume(config.volume);
    await _player.play(BytesSource(wav));
  }

  Future<void> vibrate(AlertConfig config, {bool intense = false}) async {
    if (!config.vibrationEnabled) return;
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;
    if (intense) {
      Vibration.vibrate(pattern: [0, 300, 100, 300]);
    } else {
      Vibration.vibrate(duration: 200);
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required AlertConfig config,
  }) async {
    if (!config.notificationEnabled) return;
    await _notif.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'radar_alerts',
          'Alertas de Radar',
          channelDescription: 'Notificações de radares próximos',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  void dispose() {
    _player.dispose();
  }

  static Uint8List _generateBeep({
    double frequency = 1000,
    int durationMs = 300,
    int sampleRate = 22050,
  }) {
    final numSamples = (sampleRate * durationMs / 1000).round();
    final samples = Int16List(numSamples);
    const amp = 20000;
    const fadeLen = 500;

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      double env = 1.0;
      if (i < fadeLen) env = i / fadeLen;
      if (i > numSamples - fadeLen) env = (numSamples - i) / fadeLen;
      samples[i] = (sin(2 * pi * frequency * t) * amp * env).round();
    }

    // WAV header (44 bytes) + PCM data
    final dataBytes = samples.buffer.asUint8List();
    final header = ByteData(44);
    void setStr(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    setStr(0, 'RIFF');
    header.setUint32(4, 36 + dataBytes.length, Endian.little);
    setStr(8, 'WAVE');
    setStr(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    setStr(36, 'data');
    header.setUint32(40, dataBytes.length, Endian.little);

    return Uint8List.fromList(
        [...header.buffer.asUint8List(), ...dataBytes]);
  }
}

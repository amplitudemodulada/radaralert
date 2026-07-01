import 'dart:math';
import 'package:flutter/material.dart';

class AnalogSpeedometer extends StatefulWidget {
  final double speedKmh;
  final double maxSpeed;

  const AnalogSpeedometer({
    super.key,
    required this.speedKmh,
    this.maxSpeed = 260,
  });

  @override
  State<AnalogSpeedometer> createState() => _AnalogSpeedometerState();
}

class _AnalogSpeedometerState extends State<AnalogSpeedometer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentSpeed = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(AnalogSpeedometer old) {
    super.didUpdateWidget(old);
    if ((widget.speedKmh - _currentSpeed).abs() > 0.5) {
      _animation = Tween<double>(
        begin: _currentSpeed,
        end: widget.speedKmh,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
      _currentSpeed = widget.speedKmh;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => CustomPaint(
        painter: _SpeedometerPainter(
          speedKmh: _animation.value,
          maxSpeed: widget.maxSpeed,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double speedKmh;
  final double maxSpeed;

  _SpeedometerPainter({required this.speedKmh, required this.maxSpeed});

  static const double _startAngle = 150 * pi / 180;
  static const double _sweepAngle = 240 * pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    _drawBackground(canvas, center, radius);
    _drawArcs(canvas, center, radius);
    _drawTicks(canvas, center, radius);
    _drawLabels(canvas, center, radius);
    _drawNeedle(canvas, center, radius);
    _drawCenter(canvas, center);
    _drawSpeedText(canvas, center, size);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF1A2035), const Color(0xFF0A0E1A)],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2));
    canvas.drawCircle(center, radius * 1.15, paint);

    final borderPaint = Paint()
      ..color = const Color(0xFF00BCD4).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 1.15, borderPaint);
  }

  void _drawArcs(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius * 0.85);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final segments = [
      (0.0, 0.5, const Color(0xFF4CAF50)),
      (0.5, 0.7, const Color(0xFFFFEB3B)),
      (0.7, 0.85, const Color(0xFFFF9800)),
      (0.85, 1.0, const Color(0xFFF44336)),
    ];

    for (final seg in segments) {
      arcPaint.color = seg.$3.withOpacity(0.7);
      canvas.drawArc(
        rect,
        _startAngle + _sweepAngle * seg.$1,
        _sweepAngle * (seg.$2 - seg.$1),
        false,
        arcPaint,
      );
    }

    // Active arc (fill up to current speed)
    final pct = (speedKmh / maxSpeed).clamp(0.0, 1.0);
    if (pct > 0) {
      final activePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = _speedColor(pct);
      canvas.drawArc(rect, _startAngle, _sweepAngle * pct, false, activePaint);
    }
  }

  Color _speedColor(double pct) {
    if (pct < 0.5) return const Color(0xFF4CAF50);
    if (pct < 0.7) return const Color(0xFFFFEB3B);
    if (pct < 0.85) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    final majorPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final minorPaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const steps = 26;
    for (int i = 0; i <= steps; i++) {
      final angle = _startAngle + _sweepAngle * i / steps;
      final isMajor = i % 2 == 0;
      final paint = isMajor ? majorPaint : minorPaint;
      final len = isMajor ? radius * 0.12 : radius * 0.07;
      final outer = Offset(
        center.dx + cos(angle) * radius * 0.78,
        center.dy + sin(angle) * radius * 0.78,
      );
      final inner = Offset(
        center.dx + cos(angle) * (radius * 0.78 - len),
        center.dy + sin(angle) * (radius * 0.78 - len),
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final labels = [0, 40, 80, 120, 160, 200, 260];
    for (final label in labels) {
      final pct = label / maxSpeed;
      final angle = _startAngle + _sweepAngle * pct;
      final pos = Offset(
        center.dx + cos(angle) * radius * 0.62,
        center.dy + sin(angle) * radius * 0.62,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '$label',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final pct = (speedKmh / maxSpeed).clamp(0.0, 1.0);
    final angle = _startAngle + _sweepAngle * pct;

    final tip = Offset(
      center.dx + cos(angle) * radius * 0.72,
      center.dy + sin(angle) * radius * 0.72,
    );
    final tail = Offset(
      center.dx - cos(angle) * radius * 0.15,
      center.dy - sin(angle) * radius * 0.15,
    );

    // Glow effect (draw first, underneath)
    final glowPaint = Paint()
      ..color = const Color(0xFFF44336).withOpacity(0.3)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tail, tip, glowPaint);

    // Main needle
    final needlePaint = Paint()
      ..color = const Color(0xFFF44336)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tail, tip, needlePaint);
  }

  void _drawCenter(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 10, Paint()..color = const Color(0xFF1A2035));
    canvas.drawCircle(
        center,
        10,
        Paint()
          ..color = const Color(0xFF00BCD4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.drawCircle(center, 4, Paint()..color = const Color(0xFF00BCD4));
  }

  void _drawSpeedText(Canvas canvas, Offset center, Size size) {
    final speed = speedKmh.round();
    final tpSpeed = TextPainter(
      text: TextSpan(
        text: '$speed',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: -1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpSpeed.paint(
        canvas,
        Offset(center.dx - tpSpeed.width / 2,
            center.dy + size.height * 0.15));

    final tpUnit = TextPainter(
      text: const TextSpan(
        text: 'km/h',
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpUnit.paint(
        canvas,
        Offset(center.dx - tpUnit.width / 2,
            center.dy + size.height * 0.15 + tpSpeed.height));
  }

  @override
  bool shouldRepaint(_SpeedometerPainter old) => old.speedKmh != speedKmh;
}

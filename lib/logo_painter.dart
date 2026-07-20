import 'dart:math';
import 'package:flutter/material.dart';

class LogoPainter extends CustomPainter {
  final double size;
  LogoPainter({this.size = 1.0});

  static const double pi = 3.14159265358979323846;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cx = canvasSize.width / 2;
    final cy = canvasSize.height / 2;
    final scale = min(canvasSize.width, canvasSize.height) / 128;

    // Background circle
    final bgPaint = Paint()..color = const Color(0xFF1a1a2e);
    canvas.drawCircle(Offset(cx, cy), 58 * scale, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFF303050)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;
    canvas.drawCircle(Offset(cx, cy), 58 * scale, borderPaint);

    // Orbit ring (dashed - simulated with line segments)
    final orbitPaint = Paint()
      ..color = const Color(0xFF606078)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;
    final orbitRadius = 35 * scale;
    const dashCount = 36;
    for (int i = 0; i < dashCount; i += 2) {
      final a1 = 2 * pi * i / dashCount;
      final a2 = 2 * pi * (i + 0.7) / dashCount;
      canvas.drawLine(
        Offset(cx + orbitRadius * cos(a1), cy + orbitRadius * sin(a1)),
        Offset(cx + orbitRadius * cos(a2), cy + orbitRadius * sin(a2)),
        orbitPaint,
      );
    }

    // Center dot
    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 2.5 * scale, centerPaint);

    // Orbiting object
    final objAngle = -pi * 0.25;
    final objX = cx + orbitRadius * cos(objAngle);
    final objY = cy + orbitRadius * sin(objAngle);

    final glowPaint = Paint()
      ..color = const Color(0x66FFFF00)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(objX, objY), 6 * scale, glowPaint);

    final objPaint = Paint()..color = const Color(0xFFFFFF00);
    canvas.drawCircle(Offset(objX, objY), 4.5 * scale, objPaint);

    // Centripetal force arrow (blue)
    final arrowLen = 22 * scale;
    final dirX = (cx - objX) / orbitRadius;
    final dirY = (cy - objY) / orbitRadius;
    final tipX = objX + dirX * arrowLen;
    final tipY = objY + dirY * arrowLen;

    final arrowPaint = Paint()
      ..color = const Color(0xFF0080FF)
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(objX, objY), Offset(tipX, tipY), arrowPaint);

    // Arrowhead
    final ah = 5 * scale;
    final arrowPath = Path()
      ..moveTo(tipX, tipY)
      ..lineTo(tipX + dirX * ah + dirY * ah * 0.5,
          tipY + dirY * ah - dirX * ah * 0.5)
      ..lineTo(tipX + dirX * ah - dirY * ah * 0.5,
          tipY + dirY * ah + dirX * ah * 0.5)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = const Color(0xFF0080FF));

    // Velocity arrow (green, tangential)
    final velLen = 16 * scale;
    final velTipX = objX + (-dirY) * velLen;
    final velTipY = objY + dirX * velLen;

    final velPaint = Paint()
      ..color = const Color(0xFF00CC00)
      ..strokeWidth = 2 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(objX, objY), Offset(velTipX, velTipY), velPaint);

    final vah = 4 * scale;
    final vDirX = -dirY;
    final vDirY = dirX;
    final velArrow = Path()
      ..moveTo(velTipX, velTipY)
      ..lineTo(velTipX + vDirX * vah + vDirY * vah * 0.5,
          velTipY + vDirY * vah - vDirX * vah * 0.5)
      ..lineTo(velTipX + vDirX * vah - vDirY * vah * 0.5,
          velTipY + vDirY * vah + vDirX * vah * 0.5)
      ..close();
    canvas.drawPath(velArrow, Paint()..color = const Color(0xFF00CC00));
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) => false;
}

class LogoWidget extends StatelessWidget {
  final double size;
  const LogoWidget({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: LogoPainter(),
    );
  }
}

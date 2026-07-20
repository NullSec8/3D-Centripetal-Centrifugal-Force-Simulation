import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'simulation_state.dart';
import 'math3d.dart';

class SimulationPainter extends CustomPainter {
  final SimulationState state;

  SimulationPainter(this.state);

  static const double pi = 3.14159265358979323846;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final camX = state.cameraDistance *
        sin(state.cameraAngleY * pi / 180.0) *
        cos(state.cameraAngleX * pi / 180.0);
    final camZ = state.cameraDistance *
        sin(state.cameraAngleY * pi / 180.0) *
        sin(state.cameraAngleX * pi / 180.0);
    final camY = state.cameraDistance * cos(state.cameraAngleY * pi / 180.0);
    final eye = Vec3(camX, camY, camZ);
    final viewMat = Mat4.lookAt(eye, Vec3.zero, Vec3(0, 0, 1));

    Mat4 viewProj;
    if (state.perspektiva3D) {
      final projMat = Mat4.perspective(45.0, w / h, 0.1, 100.0);
      viewProj = multiplyMat4(projMat, viewMat);
    } else {
      final aspect = w / h;
      final projMat =
          Mat4.ortho(-10.0 * aspect, 10.0 * aspect, -10.0, 10.0, -100.0, 100.0);
      viewProj = multiplyMat4(projMat, viewMat);
    }

    final bgPaint = Paint()..color = const Color(0xFF141420);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    _drawGrid(canvas, w, h, viewProj);
    _drawAxes(canvas, w, h, viewProj);

    if (state.shfaqRrugen) {
      _drawOrbit(canvas, w, h, viewProj);
      _drawSpeedTrail(canvas, w, h, viewProj);
    }

    _drawSphere(canvas, w, h, viewProj, Vec3.zero, 0.1, const Color(0xFFFFFFFF),
        8, 0.3);
    _drawSphere(
        canvas,
        w,
        h,
        viewProj,
        Vec3(state.objX, state.objY, state.objZ),
        0.3,
        const Color(0xFFFFFF00),
        10,
        1.0);

    final fc = state.fc;
    final v = state.v;
    final angle = atan2(state.objY, state.objX);
    final cosA = cos(angle);
    final sinA = sin(angle);

    if (state.shfaqForcenCentripetale) {
      final scale = fc * state.shkallaVizuale;
      final obj = Vec3(state.objX, state.objY, state.objZ);
      final tip = Vec3(
        state.objX - cosA * scale,
        state.objY - sinA * scale,
        state.objZ,
      );
      _drawArrow(canvas, w, h, viewProj, obj, tip, const Color(0xFF0080FF), 3.0);
    }

    if (state.shfaqForcenCentrifugale) {
      final scale = fc * state.shkallaVizuale;
      final obj = Vec3(state.objX, state.objY, state.objZ);
      final tip = Vec3(
        state.objX + cosA * scale,
        state.objY + sinA * scale,
        state.objZ,
      );
      _drawArrow(canvas, w, h, viewProj, obj, tip, const Color(0xFFFF0000), 2.0);
    }

    if (state.shfaqShpejtesine) {
      final scale = v * 0.5;
      final obj = Vec3(state.objX, state.objY, state.objZ);
      final tip = Vec3(
        state.objX - sinA * scale,
        state.objY + cosA * scale,
        state.objZ,
      );
      _drawArrow(
          canvas, w, h, viewProj, obj, tip, const Color(0xFF00CC00), 2.0);
    }
  }

  Vec3 _project(Vec3 p, Mat4 vp, double w, double h) {
    return Mat4.projectPoint(p, vp, w, h);
  }

  void _drawGrid(Canvas canvas, double w, double h, Mat4 vp) {
    final paint = Paint()
      ..color = const Color(0xFF4D4D4D)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (int i = -10; i <= 10; i++) {
      final p1 = _project(Vec3(-10, i.toDouble(), 0), vp, w, h);
      final p2 = _project(Vec3(10, i.toDouble(), 0), vp, w, h);
      canvas.drawLine(Offset(p1.x, p1.y), Offset(p2.x, p2.y), paint);
      final p3 = _project(Vec3(i.toDouble(), -10, 0), vp, w, h);
      final p4 = _project(Vec3(i.toDouble(), 10, 0), vp, w, h);
      canvas.drawLine(Offset(p3.x, p3.y), Offset(p4.x, p4.y), paint);
    }
  }

  void _drawAxes(Canvas canvas, double w, double h, Mat4 vp) {
    final red = Paint()..color = const Color(0xFFFF0000)..strokeWidth = 2.0;
    final green = Paint()..color = const Color(0xFF00FF00)..strokeWidth = 2.0;
    final blue = Paint()..color = const Color(0xFF0000FF)..strokeWidth = 2.0;

    final o = _project(Vec3.zero, vp, w, h);
    final x = _project(Vec3(8, 0, 0), vp, w, h);
    canvas.drawLine(Offset(o.x, o.y), Offset(x.x, x.y), red);

    final y = _project(Vec3(0, 8, 0), vp, w, h);
    canvas.drawLine(Offset(o.x, o.y), Offset(y.x, y.y), green);

    final z = _project(Vec3(0, 0, 8), vp, w, h);
    canvas.drawLine(Offset(o.x, o.y), Offset(z.x, z.y), blue);

    final tp = TextPainter(textDirection: ui.TextDirection.ltr);
    tp.text = const TextSpan(
      text: 'X',
      style: TextStyle(color: Color(0xFFFF0000), fontSize: 12, fontWeight: FontWeight.bold),
    );
    tp.layout();
    tp.paint(canvas, Offset(x.x + 4, x.y - 4));

    tp.text = const TextSpan(
      text: 'Y',
      style: TextStyle(color: Color(0xFF00FF00), fontSize: 12, fontWeight: FontWeight.bold),
    );
    tp.layout();
    tp.paint(canvas, Offset(y.x + 4, y.y - 4));

    tp.text = const TextSpan(
      text: 'Z',
      style: TextStyle(color: Color(0xFF0000FF), fontSize: 12, fontWeight: FontWeight.bold),
    );
    tp.layout();
    tp.paint(canvas, Offset(z.x + 4, z.y - 4));
  }

  void _drawOrbit(Canvas canvas, double w, double h, Mat4 vp) {
    final paint = Paint()
      ..color = const Color(0xFF808080)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final path = Path();
    const segments = 64;
    for (int i = 0; i <= segments; i++) {
      final angle = 2.0 * pi * i / segments;
      final p = _project(
        Vec3(state.rrezja * cos(angle), state.rrezja * sin(angle), 0),
        vp,
        w,
        h,
      );
      if (i == 0) {
        path.moveTo(p.x, p.y);
      } else {
        path.lineTo(p.x, p.y);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawSpeedTrail(Canvas canvas, double w, double h, Mat4 vp) {
    if (state.rruga.length < 2) return;

    for (int i = 1; i < state.rruga.length; i++) {
      final p0 = _project(state.rruga[i - 1], vp, w, h);
      final p1 = _project(state.rruga[i], vp, w, h);

      final t = i / state.rruga.length;
      final r = (255 * (1 - t) * 0.2).round();
      final g = (200 * t).round();
      final b = (255 * t * 0.3).round();
      final alpha = (40 + 180 * t).round();

      final paint = Paint()
        ..color = Color.fromARGB(alpha, r, g, b)
        ..strokeWidth = 1.0 + t * 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(p0.x, p0.y), Offset(p1.x, p1.y), paint);
    }
  }

  void _drawSphere(Canvas canvas, double w, double h, Mat4 vp, Vec3 center,
      double radius, Color color, int segments, double opacity) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = color.withAlpha((opacity * 255).round())
      ..style = PaintingStyle.fill;

    _drawCircleOnPlane(canvas, w, h, vp, center, radius, segments,
        strokePaint, fillPaint, 0);
    _drawCircleOnPlane(canvas, w, h, vp, center, radius, segments,
        strokePaint, fillPaint, 1);
    _drawCircleOnPlane(canvas, w, h, vp, center, radius, segments,
        strokePaint, fillPaint, 2);
  }

  void _drawCircleOnPlane(Canvas canvas, double w, double h, Mat4 vp,
      Vec3 center, double radius, int segments, Paint strokePaint,
      Paint fillPaint, int plane) {
    final path = Path();
    final fillPath = Path();
    bool started = false;
    for (int i = 0; i <= segments; i++) {
      final angle = 2.0 * pi * i / segments;
      final c = cos(angle);
      final s = sin(angle);
      Vec3 p;
      if (plane == 0) {
        p = Vec3(
            center.x + radius * c, center.y + radius * s, center.z);
      } else if (plane == 1) {
        p = Vec3(
            center.x + radius * c, center.y, center.z + radius * s);
      } else {
        p = Vec3(
            center.x, center.y + radius * c, center.z + radius * s);
      }
      final proj = _project(p, vp, w, h);
      if (!started) {
        path.moveTo(proj.x, proj.y);
        fillPath.moveTo(proj.x, proj.y);
        started = true;
      } else {
        path.lineTo(proj.x, proj.y);
        fillPath.lineTo(proj.x, proj.y);
      }
    }
    canvas.drawPath(path, strokePaint);
    if (plane == 0) {
      canvas.drawPath(fillPath, fillPaint);
    }
  }

  void _drawArrow(Canvas canvas, double w, double h, Mat4 vp, Vec3 from,
      Vec3 to, Color color, double thickness) {
    final p1 = _project(from, vp, w, h);
    final p2 = _project(to, vp, w, h);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(p1.x, p1.y), Offset(p2.x, p2.y), linePaint);

    final dir = to - from;
    final len = dir.length;
    if (len < 0.01) return;

    final nd = dir.normalized();
    var px = -nd.y;
    var py = nd.x;
    var pz = 0.0;
    if (px.abs() < 0.1 && py.abs() < 0.1) {
      px = 0;
      py = -nd.z;
      pz = nd.y;
    }
    final pLen = sqrt(px * px + py * py + pz * pz);
    if (pLen > 0.01) {
      px /= pLen;
      py /= pLen;
      pz /= pLen;
    }
    px *= 0.1;
    py *= 0.1;
    pz *= 0.1;

    const headSize = 0.3;
    final head1 = Vec3(
      to.x - nd.x * headSize + px,
      to.y - nd.y * headSize + py,
      to.z - nd.z * headSize + pz,
    );
    final head2 = Vec3(
      to.x - nd.x * headSize - px,
      to.y - nd.y * headSize - py,
      to.z - nd.z * headSize - pz,
    );

    final ph1 = _project(head1, vp, w, h);
    final ph2 = _project(head2, vp, w, h);

    final triPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final triPath = Path()
      ..moveTo(p2.x, p2.y)
      ..lineTo(ph1.x, ph1.y)
      ..lineTo(ph2.x, ph2.y)
      ..close();
    canvas.drawPath(triPath, triPaint);
  }

  @override
  bool shouldRepaint(covariant SimulationPainter oldDelegate) => true;
}

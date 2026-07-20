import 'dart:math';
import 'simulation_state.dart';

class Mat4 {
  final List<double> m;
  const Mat4(this.m);

  static Mat4 identity() => Mat4([
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1,
  ]);

  static Mat4 perspective(double fovy, double aspect, double zNear, double zFar) {
    final f = 1.0 / tan(fovy * 0.5 * pi / 180.0);
    return Mat4([
      f / aspect, 0, 0, 0,
      0, f, 0, 0,
      0, 0, (zFar + zNear) / (zNear - zFar), -1,
      0, 0, (2.0 * zFar * zNear) / (zNear - zFar), 0,
    ]);
  }

  static Mat4 lookAt(Vec3 eye, Vec3 center, Vec3 up) {
    var f = (center - eye).normalized();
    if (f.length < 1e-6) f = const Vec3(0, 0, -1);
    var s = Vec3.cross(f, up).normalized();
    if (s.length < 1e-6) {
      s = Vec3.cross(f, Vec3(0, 1, 0)).normalized();
      if (s.length < 1e-6) {
        s = Vec3.cross(f, Vec3(1, 0, 0)).normalized();
      }
    }
    final u = Vec3.cross(s, f);
    return Mat4([
      s.x, u.x, -f.x, 0,
      s.y, u.y, -f.y, 0,
      s.z, u.z, -f.z, 0,
      -Vec3.dot(s, eye), -Vec3.dot(u, eye), Vec3.dot(f, eye), 1,
    ]);
  }

  static Mat4 ortho(double left, double right, double bottom, double top, double near, double far) {
    return Mat4([
      2.0 / (right - left), 0, 0, 0,
      0, 2.0 / (top - bottom), 0, 0,
      0, 0, -2.0 / (far - near), 0,
      -(right + left) / (right - left), -(top + bottom) / (top - bottom), -(far + near) / (far - near), 1,
    ]);
  }

  Vec3 transformPoint(Vec3 p) {
    final w = m[3] * p.x + m[7] * p.y + m[11] * p.z + m[15];
    if (w.abs() < 1e-10) return Vec3.zero;
    return Vec3(
      (m[0] * p.x + m[4] * p.y + m[8] * p.z + m[12]) / w,
      (m[1] * p.x + m[5] * p.y + m[9] * p.z + m[13]) / w,
      (m[2] * p.x + m[6] * p.y + m[10] * p.z + m[14]) / w,
    );
  }

  static Vec3 projectPoint(Vec3 worldPos, Mat4 viewProj, double width, double height) {
    final clip = viewProj.transformPoint(worldPos);
    return Vec3(
      (clip.x * 0.5 + 0.5) * width,
      (1.0 - (clip.y * 0.5 + 0.5)) * height,
      clip.z,
    );
  }
}

Mat4 multiplyMat4(Mat4 a, Mat4 b) {
  final r = List<double>.filled(16, 0);
  for (int col = 0; col < 4; col++) {
    for (int row = 0; row < 4; row++) {
      for (int k = 0; k < 4; k++) {
        r[col * 4 + row] += a.m[k * 4 + row] * b.m[col * 4 + k];
      }
    }
  }
  return Mat4(r);
}

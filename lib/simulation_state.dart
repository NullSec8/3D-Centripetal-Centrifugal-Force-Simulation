import 'dart:math';

class Vec3 {
  final double x, y, z;
  const Vec3(this.x, this.y, this.z);

  static const zero = Vec3(0, 0, 0);

  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 operator *(double s) => Vec3(x * s, y * s, z * s);

  double get length => sqrt(x * x + y * y + z * z);

  Vec3 normalized() {
    final len = length;
    if (len < 1e-6) return const Vec3(0, 0, 0);
    return Vec3(x / len, y / len, z / len);
  }

  static Vec3 cross(Vec3 a, Vec3 b) => Vec3(
    a.y * b.z - a.z * b.y,
    a.z * b.x - a.x * b.z,
    a.x * b.y - a.y * b.x,
  );

  static double dot(Vec3 a, Vec3 b) => a.x * b.x + a.y * b.y + a.z * b.z;
}

class SimulationState {
  double rrezja = 4.0;
  double omega = 1.5;
  double masa = 1.0;
  double koha = 0.0;
  bool pauzuar = false;
  bool shfaqForcenCentripetale = true;
  bool shfaqForcenCentrifugale = false;
  bool shfaqShpejtesine = true;
  bool shfaqRrugen = true;
  bool perspektiva3D = true;
  double shkallaVizuale = 0.1;

  double cameraAngleX = 45.0;
  double cameraAngleY = 30.0;
  double cameraDistance = 15.0;

  double objX = 4.0;
  double objY = 0.0;
  double objZ = 0.0;

  final List<Vec3> rruga = [];

  static const double pi = 3.14159265358979323846;

  void reset() {
    rrezja = 4.0;
    omega = 1.5;
    masa = 1.0;
    koha = 0.0;
    rruga.clear();
  }

  void update(double deltaTime) {
    if (pauzuar) return;
    koha += deltaTime;
    objX = rrezja * cos(omega * koha);
    objY = rrezja * sin(omega * koha);
    objZ = 0.0;
    rruga.add(Vec3(objX, objY, objZ));
    if (rruga.length > 100) {
      rruga.removeAt(0);
    }
  }

  double get fc => masa * omega * omega * rrezja;
  double get v => omega * rrezja;
  double get T => 2.0 * pi / omega;
  double get ac => v * v / rrezja;

  String getPhysicsInfo() =>
      'FORCA CENTRIPETALE | F=${fc.toStringAsFixed(2)}N | m=${masa.toStringAsFixed(1)}kg | '
      '\u03C9=${omega.toStringAsFixed(1)}rad/s | r=${rrezja.toStringAsFixed(1)}m | '
      'v=${v.toStringAsFixed(2)}m/s | a=${ac.toStringAsFixed(2)}m/s\u00B2 | T=${T.toStringAsFixed(2)}s';
}

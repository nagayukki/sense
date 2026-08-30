import 'dart:math' as math;

import 'lab.dart';

double _deg(double rad) => rad * 180 / math.pi;
double _rad(double deg) => deg * math.pi / 180;

/// CIEDE2000 色差 (ΔE00)。知覚的な色の差。目安: 1.0 前後が識別の限界。
double ciede2000(Lab c1, Lab c2) {
  final c1ab = math.sqrt(c1.a * c1.a + c1.b * c1.b);
  final c2ab = math.sqrt(c2.a * c2.a + c2.b * c2.b);
  final cAvg = (c1ab + c2ab) / 2;

  final c7 = math.pow(cAvg, 7).toDouble();
  final g = 0.5 * (1 - math.sqrt(c7 / (c7 + math.pow(25, 7))));

  final a1p = (1 + g) * c1.a;
  final a2p = (1 + g) * c2.a;
  final c1p = math.sqrt(a1p * a1p + c1.b * c1.b);
  final c2p = math.sqrt(a2p * a2p + c2.b * c2.b);

  double hp(double a, double b) {
    if (a == 0 && b == 0) return 0;
    final h = _deg(math.atan2(b, a));
    return h < 0 ? h + 360 : h;
  }

  final h1p = hp(a1p, c1.b);
  final h2p = hp(a2p, c2.b);

  final dLp = c2.l - c1.l;
  final dCp = c2p - c1p;

  double dhp;
  if (c1p * c2p == 0) {
    dhp = 0;
  } else {
    dhp = h2p - h1p;
    if (dhp > 180) dhp -= 360;
    if (dhp < -180) dhp += 360;
  }
  final dHp = 2 * math.sqrt(c1p * c2p) * math.sin(_rad(dhp) / 2);

  final lAvg = (c1.l + c2.l) / 2;
  final cpAvg = (c1p + c2p) / 2;

  double hpAvg;
  if (c1p * c2p == 0) {
    hpAvg = h1p + h2p;
  } else {
    final diff = (h1p - h2p).abs();
    if (diff <= 180) {
      hpAvg = (h1p + h2p) / 2;
    } else if (h1p + h2p < 360) {
      hpAvg = (h1p + h2p + 360) / 2;
    } else {
      hpAvg = (h1p + h2p - 360) / 2;
    }
  }

  final t = 1 -
      0.17 * math.cos(_rad(hpAvg - 30)) +
      0.24 * math.cos(_rad(2 * hpAvg)) +
      0.32 * math.cos(_rad(3 * hpAvg + 6)) -
      0.20 * math.cos(_rad(4 * hpAvg - 63));

  final dTheta = 30 * math.exp(-math.pow((hpAvg - 275) / 25, 2).toDouble());
  final cp7 = math.pow(cpAvg, 7).toDouble();
  final rc = 2 * math.sqrt(cp7 / (cp7 + math.pow(25, 7)));
  final l50 = math.pow(lAvg - 50, 2).toDouble();
  final sl = 1 + 0.015 * l50 / math.sqrt(20 + l50);
  final sc = 1 + 0.045 * cpAvg;
  final sh = 1 + 0.015 * cpAvg * t;
  final rt = -math.sin(_rad(2 * dTheta)) * rc;

  final dl = dLp / sl;
  final dc = dCp / sc;
  final dh = dHp / sh;
  return math.sqrt(dl * dl + dc * dc + dh * dh + rt * dc * dh);
}

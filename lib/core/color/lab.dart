import 'dart:math' as math;
import 'dart:ui';

/// CIELAB (D65) の色。色差計算 (CIEDE2000) の入力に使う。
class Lab {
  const Lab(this.l, this.a, this.b);

  final double l;
  final double a;
  final double b;

  @override
  String toString() => 'Lab(${l.toStringAsFixed(2)}, '
      '${a.toStringAsFixed(2)}, ${b.toStringAsFixed(2)})';
}

/// sRGB (0-255) → CIELAB (D65)。
Lab srgbToLab(int r8, int g8, int b8) {
  double lin(int c) {
    final v = c / 255.0;
    return v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = lin(r8), g = lin(g8), b = lin(b8);

  // sRGB D65 → XYZ
  final x = 0.4124564 * r + 0.3575761 * g + 0.1804375 * b;
  final y = 0.2126729 * r + 0.7151522 * g + 0.0721750 * b;
  final z = 0.0193339 * r + 0.1191920 * g + 0.9503041 * b;

  // D65 白色点
  const xn = 0.95047, yn = 1.0, zn = 1.08883;

  double f(double t) =>
      t > 216 / 24389 ? math.pow(t, 1 / 3).toDouble() : (24389 / 27 * t + 16) / 116;

  final fx = f(x / xn), fy = f(y / yn), fz = f(z / zn);
  return Lab(116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz));
}

/// CIELAB (D65) → sRGB。色域外は null。
Color? labToSrgb(Lab lab) {
  final fy = (lab.l + 16) / 116;
  final fx = fy + lab.a / 500;
  final fz = fy - lab.b / 200;

  double fInv(double t) {
    final t3 = t * t * t;
    return t3 > 216 / 24389 ? t3 : (116 * t - 16) * 27 / 24389;
  }

  const xn = 0.95047, yn = 1.0, zn = 1.08883;
  final x = fInv(fx) * xn, y = fInv(fy) * yn, z = fInv(fz) * zn;

  final r = 3.2404542 * x - 1.5371385 * y - 0.4985314 * z;
  final g = -0.9692660 * x + 1.8760108 * y + 0.0415560 * z;
  final b = 0.0556434 * x - 0.2040259 * y + 1.0572252 * z;

  int? gamma(double c) {
    if (c < -0.0005 || c > 1.0005) return null;
    final v = c <= 0.0031308
        ? 12.92 * c
        : 1.055 * math.pow(c, 1 / 2.4).toDouble() - 0.055;
    return (v.clamp(0.0, 1.0) * 255).round();
  }

  final r8 = gamma(r), g8 = gamma(g), b8 = gamma(b);
  if (r8 == null || g8 == null || b8 == null) return null;
  return Color.fromARGB(255, r8, g8, b8);
}

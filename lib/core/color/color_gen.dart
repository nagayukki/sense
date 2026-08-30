import 'dart:math';
import 'dart:ui';

import 'ciede2000.dart';
import 'lab.dart';

/// [base] から CIEDE2000 でちょうど [deltaE] 離れた色を探す。
/// Lab 空間のランダム方向へ二分探索。色域外や量子化ズレは null。
Color? colorAtDeltaE(Color base, double deltaE, Random rng) {
  final baseLab = srgbToLab(
    (base.r * 255).round(),
    (base.g * 255).round(),
    (base.b * 255).round(),
  );
  final theta = rng.nextDouble() * 2 * pi;
  final lSign = rng.nextBool() ? 1.0 : -1.0;
  Lab at(double t) => Lab(
        baseLab.l + lSign * t * 0.4,
        baseLab.a + cos(theta) * t,
        baseLab.b + sin(theta) * t,
      );

  var lo = 0.0, hi = 60.0;
  if (ciede2000(baseLab, at(hi)) < deltaE) return null;
  for (var i = 0; i < 40; i++) {
    final mid = (lo + hi) / 2;
    if (ciede2000(baseLab, at(mid)) < deltaE) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  final result = labToSrgb(at(hi));
  if (result == null) return null;

  final actual = ciede2000(
    baseLab,
    srgbToLab(
      (result.r * 255).round(),
      (result.g * 255).round(),
      (result.b * 255).round(),
    ),
  );
  if ((actual - deltaE).abs() > deltaE * 0.25 + 0.15) return null;
  return result;
}

/// 端に寄りすぎないランダムな基準色。
Color randomBaseColor(Random rng) => Color.fromARGB(
      255,
      40 + rng.nextInt(176),
      40 + rng.nextInt(176),
      40 + rng.nextInt(176),
    );

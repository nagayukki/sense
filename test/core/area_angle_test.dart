import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sense/features/angle_training/angle_compare.dart';
import 'package:sense/features/area_training/area_compare.dart';

void main() {
  group('generateAreaTrial', () {
    test('面積差は指定どおり', () {
      final rng = Random(11);
      for (final diff in [40.0, 15.0, 5.0, 1.0]) {
        for (var i = 0; i < 20; i++) {
          final t = generateAreaTrial(diffPercent: diff, random: rng);
          final larger = max(t.areaA, t.areaB);
          final smaller = min(t.areaA, t.areaB);
          expect((larger / smaller - 1) * 100, closeTo(diff, 1e-9));
        }
      }
    });

    test('図形がカードに収まる', () {
      final rng = Random(12);
      for (var i = 0; i < 100; i++) {
        final t = generateAreaTrial(diffPercent: 80, random: rng);
        for (final (shape, area, aspect) in [
          (t.shapeA, t.areaA, t.aspectA),
          (t.shapeB, t.areaB, t.aspectB),
        ]) {
          // 最長の描画寸法 (円は直径、rect は長辺)
          final side = shape == AreaShape.circle
              ? 2 * sqrt(area / pi)
              : sqrt(area * aspect);
          expect(side, lessThanOrEqualTo(0.91));
        }
      }
    });
  });

  group('generateAngleTrial', () {
    test('角度差は指定どおり (上限クランプ以外)', () {
      final rng = Random(13);
      for (var i = 0; i < 50; i++) {
        final t = generateAngleTrial(diffDegrees: 10, random: rng);
        final wider = max(t.angleA, t.angleB);
        final narrower = min(t.angleA, t.angleB);
        expect(wider - narrower, closeTo(t.diffDegrees, 1e-9));
        expect(wider, lessThanOrEqualTo(165.0));
        expect(narrower, greaterThanOrEqualTo(25.0));
      }
    });
  });

  test('セッションが完走し閾値が出る', () {
    final area = AreaSession(trialCount: 6, random: Random(14));
    while (!area.isFinished) {
      area.answer(choseA: area.trial!.aIsLarger);
    }
    expect(area.threshold, isNot(isNaN));

    final angle = AngleSession(trialCount: 6, random: Random(15));
    while (!angle.isFinished) {
      angle.answer(choseA: !angle.trial!.aIsWider); // 全部不正解でも動く
    }
    expect(angle.threshold, isNot(isNaN));
  });
}

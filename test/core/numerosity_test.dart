import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sense/features/numerosity_training/numerosity_compare.dart';

void main() {
  test('点の数の差はおおむね指定どおり', () {
    final rng = Random(41);
    for (final diff in [60.0, 25.0, 8.0]) {
      for (var i = 0; i < 20; i++) {
        final t = generateNumerosityTrial(diffPercent: diff, random: rng);
        final larger = max(t.countA, t.countB);
        final smaller = min(t.countA, t.countB);
        expect(larger, greaterThan(smaller));
        final actual = (larger / smaller - 1) * 100;
        // 丸めがあるので緩めに
        expect((actual - diff).abs(), lessThanOrEqualTo(6));
      }
    }
  });

  test('点はカード内に収まる', () {
    final rng = Random(42);
    for (var i = 0; i < 20; i++) {
      final t = generateNumerosityTrial(diffPercent: 30, random: rng);
      for (final d in [...t.dotsA, ...t.dotsB]) {
        expect(d.x - d.r, greaterThanOrEqualTo(0));
        expect(d.x + d.r, lessThanOrEqualTo(1));
        expect(d.y - d.r, greaterThanOrEqualTo(0));
        expect(d.y + d.r, lessThanOrEqualTo(1));
      }
    }
  });

  test('面積を揃えた問題では合計面積が一致する', () {
    final rng = Random(43);
    var checked = 0;
    for (var i = 0; i < 50 && checked < 10; i++) {
      final t = generateNumerosityTrial(diffPercent: 40, random: rng);
      if (!t.areaEqualized) continue;
      double area(List<Dot> dots) {
        var a = 0.0;
        for (final d in dots) {
          a += d.r * d.r;
        }
        return a;
      }

      expect(area(t.dotsA) / area(t.dotsB), closeTo(1.0, 0.01));
      checked++;
    }
    expect(checked, greaterThan(0));
  });

  test('セッションが完走し閾値が出る', () {
    final s = NumerositySession(trialCount: 6, random: Random(44));
    while (!s.isFinished) {
      s.answer(choseA: s.trial!.aHasMore);
    }
    expect(s.threshold, isNot(isNaN));
  });
}

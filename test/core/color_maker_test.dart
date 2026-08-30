import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sense/features/color_maker/color_maker.dart';

void main() {
  test('同じ色は ΔE 0', () {
    const c = Color(0xFF6A8CD4);
    expect(scoreColorMatch(c, c), 0);
  });

  test('セッション: 提出で進み、平均とベストが出る', () {
    final s = ColorMakerSession(roundCount: 3, random: Random(81));
    expect(s.answered, 0);
    final targets = <Color>[];
    while (!s.isFinished) {
      targets.add(s.target!);
      s.submit(s.target!); // 完全一致で提出
    }
    expect(s.answered, 3);
    expect(s.averageDeltaE, 0);
    expect(s.bestDeltaE, 0);
    expect(s.target, isNull);
    expect(() => s.submit(const Color(0xFF000000)), throwsStateError);
    // 見本は毎回変わる
    expect(targets.toSet().length, greaterThan(1));
  });

  test('外した分だけ平均が上がる', () {
    final s = ColorMakerSession(roundCount: 2, random: Random(82));
    final t1 = s.target!;
    final d1 = s.submit(t1); // 0
    final d2 = s.submit(const Color(0xFF000000)); // 大きい
    expect(d1, 0);
    expect(d2, greaterThan(5));
    expect(s.averageDeltaE, closeTo((d1 + d2) / 2, 1e-9));
    expect(s.bestDeltaE, 0);
  });
}

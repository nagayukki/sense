import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sense/features/length_training/length_compare.dart';

void main() {
  test('生成された問題は指定の差を持つ', () {
    final rng = Random(7);
    for (final diff in [30.0, 10.0, 3.0, 1.0]) {
      for (var i = 0; i < 20; i++) {
        final t = generateLengthTrial(diffPercent: diff, random: rng);
        final longer = max(t.lengthA, t.lengthB);
        final shorter = min(t.lengthA, t.lengthB);
        expect((longer / shorter - 1) * 100, closeTo(diff, 1e-9));
        expect(longer, lessThanOrEqualTo(1.0));
      }
    }
  });

  test('セッションは正誤で難易度が動き閾値が出る', () {
    final s = LengthSession(trialCount: 6, random: Random(3));
    final d0 = s.trial!.diffPercent;
    s.answer(choseA: s.trial!.aIsLonger);
    expect(s.trial!.diffPercent, lessThan(d0));
    while (!s.isFinished) {
      s.answer(choseA: s.trial!.aIsLonger);
    }
    expect(s.threshold, isNot(isNaN));
  });
}

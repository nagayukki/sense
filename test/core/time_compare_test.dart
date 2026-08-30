import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sense/features/time_training/time_compare.dart';

void main() {
  test('時間差は指定どおり (丸め誤差内)', () {
    final rng = Random(31);
    for (final diff in [50.0, 20.0, 5.0]) {
      for (var i = 0; i < 20; i++) {
        final t = generateTimeTrial(diffPercent: diff, random: rng);
        final longer = max(
            t.durationA.inMilliseconds, t.durationB.inMilliseconds);
        final shorter = min(
            t.durationA.inMilliseconds, t.durationB.inMilliseconds);
        expect((longer / shorter - 1) * 100, closeTo(diff, 0.2));
        expect(shorter, inInclusiveRange(800, 2000));
      }
    }
  });

  test('セッションが完走し閾値が出る', () {
    final s = TimeSession(trialCount: 6, random: Random(32));
    final d0 = s.trial!.diffPercent;
    s.answer(choseA: s.trial!.aIsLonger);
    expect(s.trial!.diffPercent, lessThan(d0));
    while (!s.isFinished) {
      s.answer(choseA: s.trial!.aIsLonger);
    }
    expect(s.threshold, isNot(isNaN));
  });
}

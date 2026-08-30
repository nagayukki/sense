import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sense/features/color_training/odd_one_out.dart';

void main() {
  group('generateTrial', () {
    test('生成された問題の色差は目標に近い', () {
      final rng = Random(42);
      for (final target in [20.0, 8.0, 3.0, 1.0]) {
        for (var i = 0; i < 20; i++) {
          final t = generateTrial(deltaE: target, tileCount: 16, random: rng);
          expect((t.actualDeltaE - target).abs(),
              lessThanOrEqualTo(target * 0.25 + 0.15),
              reason: 'target=$target actual=${t.actualDeltaE}');
          expect(t.oddIndex, inInclusiveRange(0, 15));
        }
      }
    });
  });

  group('OddOneOutSession', () {
    test('正解で狭まり不正解で広がる', () {
      final s = OddOneOutSession(random: Random(1));
      final d0 = s.trial!.targetDeltaE;
      s.answer(s.trial!.oddIndex); // 正解
      final d1 = s.trial!.targetDeltaE;
      expect(d1, lessThan(d0));
      s.answer((s.trial!.oddIndex + 1) % 16); // 不正解
      expect(s.trial!.targetDeltaE, greaterThan(d1));
    });

    test('規定回数で終了し閾値が出る', () {
      final s = OddOneOutSession(trialCount: 8, random: Random(2));
      var guard = 0;
      while (!s.isFinished && guard++ < 20) {
        s.answer(s.trial!.oddIndex);
      }
      expect(s.answered, 8);
      expect(s.trial, isNull);
      expect(s.threshold, isNot(isNaN));
      expect(() => s.answer(0), throwsStateError);
    });
  });
}

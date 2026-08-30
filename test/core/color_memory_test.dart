import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sense/core/color/ciede2000.dart';
import 'package:sense/core/color/lab.dart';
import 'package:sense/features/color_memory/color_memory.dart';

void main() {
  test('選択肢は6つ、正解は target と一致、distractor は指定色差', () {
    final rng = Random(71);
    for (final deltaE in [20.0, 8.0, 2.0]) {
      for (var i = 0; i < 10; i++) {
        final t = generateColorMemoryTrial(deltaE: deltaE, random: rng);
        expect(t.choices.length, 6);
        expect(t.choices[t.answerIndex], t.target);
        final targetLab = srgbToLab(
          (t.target.r * 255).round(),
          (t.target.g * 255).round(),
          (t.target.b * 255).round(),
        );
        for (var c = 0; c < t.choices.length; c++) {
          if (c == t.answerIndex) continue;
          final d = ciede2000(
            targetLab,
            srgbToLab(
              (t.choices[c].r * 255).round(),
              (t.choices[c].g * 255).round(),
              (t.choices[c].b * 255).round(),
            ),
          );
          expect((d - deltaE).abs(), lessThanOrEqualTo(deltaE * 0.25 + 0.15),
              reason: 'deltaE=$deltaE actual=$d');
        }
      }
    }
  });

  test('セッションが完走し閾値が出る', () {
    final s = ColorMemorySession(trialCount: 6, random: Random(72));
    final d0 = s.trial!.deltaE;
    s.answer(s.trial!.answerIndex);
    expect(s.trial!.deltaE, lessThan(d0));
    while (!s.isFinished) {
      s.answer(s.trial!.answerIndex);
    }
    expect(s.threshold, isNot(isNaN));
  });
}

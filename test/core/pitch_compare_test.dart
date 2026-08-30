import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sense/features/pitch_training/pitch_compare.dart';

void main() {
  test('周波数比が指定のセントに一致する', () {
    final rng = Random(21);
    for (final cents in [200.0, 50.0, 10.0, 2.0]) {
      for (var i = 0; i < 20; i++) {
        final t = generatePitchTrial(diffCents: cents, random: rng);
        final ratio = max(t.freqA, t.freqB) / min(t.freqA, t.freqB);
        expect(1200 * log(ratio) / ln2, closeTo(cents, 1e-6));
        expect(min(t.freqA, t.freqB), greaterThanOrEqualTo(220 * 0.99));
        expect(max(t.freqA, t.freqB), lessThan(880 * 1.5));
      }
    }
  });

  test('mixTimbres=false では音色が揃う', () {
    final rng = Random(22);
    for (var i = 0; i < 20; i++) {
      final t =
          generatePitchTrial(diffCents: 50, mixTimbres: false, random: rng);
      expect(t.timbreA, t.timbreB);
    }
  });

  test('セッションが完走し閾値が出る', () {
    final s = PitchSession(trialCount: 6, random: Random(23));
    final d0 = s.trial!.diffCents;
    s.answer(choseA: s.trial!.aIsHigher);
    expect(s.trial!.diffCents, lessThan(d0));
    while (!s.isFinished) {
      s.answer(choseA: s.trial!.aIsHigher);
    }
    expect(s.threshold, isNot(isNaN));
  });
}

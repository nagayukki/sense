import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sense/core/audio/click_sequence.dart';
import 'package:sense/core/audio/tone_synth.dart';
import 'package:sense/features/rhythm_keep/rhythm_keep.dart';
import 'package:sense/features/tempo_training/tempo_compare.dart';

void main() {
  group('clickSequenceWav', () {
    test('長さがサンプル精度で正しい', () {
      final wav = clickSequenceWav(
        interval: const Duration(milliseconds: 500),
        count: 5,
      );
      final intervalSamples = (0.5 * sampleRate).round();
      final clickSamples = (0.03 * sampleRate).round();
      final expected = intervalSamples * 4 + clickSamples + sampleRate ~/ 10;
      expect(wav.length, 44 + expected * 2);
    });

    test('クリック位置に音があり、間は無音', () {
      final wav = clickSequenceWav(
        interval: const Duration(milliseconds: 400),
        count: 3,
      );
      final data = wav.buffer.asByteData(44);
      int sampleAt(int index) => data.getInt16(index * 2, Endian.little);
      final intervalSamples = (0.4 * sampleRate).round();
      // 2打目の頭付近は鳴っている
      var peak = 0;
      for (var i = 0; i < 500; i++) {
        peak = max(peak, sampleAt(intervalSamples + 100 + i).abs());
      }
      expect(peak, greaterThan(1000));
      // 打の中間は無音
      var mid = 0;
      for (var i = 0; i < 500; i++) {
        mid = max(mid, sampleAt(intervalSamples ~/ 2 + i).abs());
      }
      expect(mid, lessThan(50));
    });
  });

  group('generateTempoTrial', () {
    test('間隔差は指定どおり', () {
      final rng = Random(61);
      for (final diff in [30.0, 10.0, 2.0]) {
        for (var i = 0; i < 20; i++) {
          final t = generateTempoTrial(diffPercent: diff, random: rng);
          final slower =
              max(t.intervalA.inMicroseconds, t.intervalB.inMicroseconds);
          final faster =
              min(t.intervalA.inMicroseconds, t.intervalB.inMicroseconds);
          expect((slower / faster - 1) * 100, closeTo(diff, 0.05));
          expect(faster ~/ 1000, inInclusiveRange(300, 600));
        }
      }
    });
  });

  group('scoreRhythmKeep', () {
    test('完璧なタップはズレ 0', () {
      final r = scoreRhythmKeep(
        tapTimesMs: [0, 500, 1000, 1500, 2000],
        targetInterval: const Duration(milliseconds: 500),
      );
      expect(r.meanAbsDeviationPercent, 0);
      expect(r.variabilityPercent, 0);
      expect(r.intervalCount, 4);
    });

    test('一定のレイテンシは影響しない (間隔で評価)', () {
      final r = scoreRhythmKeep(
        tapTimesMs: [80, 580, 1080, 1580],
        targetInterval: const Duration(milliseconds: 500),
      );
      expect(r.meanAbsDeviationPercent, 0);
    });

    test('ズレは%で出る', () {
      // 間隔 550, 450 → 平均ズレ 50/500 = 10%
      final r = scoreRhythmKeep(
        tapTimesMs: [0, 550, 1000],
        targetInterval: const Duration(milliseconds: 500),
      );
      expect(r.meanAbsDeviationPercent, closeTo(10, 1e-9));
    });

    test('タップ不足は NaN', () {
      final r = scoreRhythmKeep(
        tapTimesMs: [100],
        targetInterval: const Duration(milliseconds: 500),
      );
      expect(r.meanAbsDeviationPercent, isNaN);
      expect(r.intervalCount, 0);
    });
  });
}

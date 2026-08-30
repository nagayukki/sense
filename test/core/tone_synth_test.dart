import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sense/core/audio/tone_synth.dart';

void main() {
  test('WAV ヘッダが正しい', () {
    final wav = toneWav(440, Timbre.sine, duration: 0.5);
    expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
    expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE');
    final n = (0.5 * sampleRate).round();
    expect(wav.length, 44 + n * 2);
  });

  test('純音の周波数はゼロ交差数と一致する', () {
    final samples = synthesize(440, Timbre.sine, duration: 0.5);
    // アタック/フェードを避けて中央 0.3 秒だけ数える
    final start = (0.1 * sampleRate).round();
    final end = (0.4 * sampleRate).round();
    var crossings = 0;
    for (var i = start + 1; i < end; i++) {
      if ((samples[i - 1] < 0) != (samples[i] < 0)) crossings++;
    }
    // 0.3 秒 × 440Hz × 2 交差 = 264
    expect(crossings, inInclusiveRange(262, 266));
  });

  test('全音色で RMS が揃っている (ラウドネス手がかりの排除)', () {
    for (final timbre in Timbre.values) {
      final samples = synthesize(330, timbre);
      var sq = 0.0;
      for (final s in samples) {
        sq += s * s;
      }
      final rms = sqrt(sq / samples.length);
      expect(rms, closeTo(0.15, 0.02), reason: timbre.name);
    }
  });

  test('クリップしない', () {
    for (final timbre in Timbre.values) {
      final samples = synthesize(880, timbre);
      for (final s in samples) {
        expect(s.abs(), lessThanOrEqualTo(1.0));
      }
    }
  });
}

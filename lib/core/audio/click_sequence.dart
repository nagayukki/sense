import 'dart:math';
import 'dart:typed_data';

import 'tone_synth.dart';

/// クリック1打ぶんのサンプル (短いピング音)。
Float64List _clickSamples({double frequency = 1800}) {
  const dur = 0.03;
  final n = (dur * sampleRate).round();
  final samples = Float64List(n);
  for (var i = 0; i < n; i++) {
    final t = i / sampleRate;
    // 1ms アタック + 急速減衰
    var env = exp(-t / 0.008);
    if (t < 0.001) env *= t / 0.001;
    samples[i] = 0.6 * env * sin(2 * pi * frequency * t);
  }
  return samples;
}

/// 等間隔クリック列を1つの WAV に描画する。
///
/// Future.delayed で逐次鳴らすとタイミングが揺れるため、
/// サンプル精度で1本のバッファに置いてから再生する。
Uint8List clickSequenceWav({
  required Duration interval,
  required int count,
  double frequency = 1800,
}) {
  final click = _clickSamples(frequency: frequency);
  final intervalSamples =
      (interval.inMicroseconds * sampleRate / 1e6).round();
  final total = intervalSamples * (count - 1) + click.length + sampleRate ~/ 10;
  final buffer = Float64List(total);
  for (var i = 0; i < count; i++) {
    final offset = i * intervalSamples;
    for (var j = 0; j < click.length; j++) {
      buffer[offset + j] += click[j];
    }
  }
  return toWav(buffer);
}

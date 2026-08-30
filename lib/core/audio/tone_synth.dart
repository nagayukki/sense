import 'dart:math';
import 'dart:typed_data';

/// 簡易シンセの音色。倍音構成とエンベロープで楽器っぽさを出す。
/// 本物の録音ではなく合成音 (〜風)。
enum Timbre {
  sine('純音'),
  piano('ピアノ風'),
  violin('バイオリン風'),
  flute('フルート風'),
  organ('オルガン風');

  const Timbre(this.label);

  final String label;

  /// 倍音の振幅 (基音 = index 0)。
  List<double> get harmonics => switch (this) {
        Timbre.sine => const [1.0],
        Timbre.piano => const [1.0, 0.5, 0.33, 0.2, 0.14, 0.1, 0.07, 0.05],
        Timbre.violin => const [1.0, 0.55, 0.35, 0.25, 0.2, 0.16, 0.13, 0.1],
        Timbre.flute => const [1.0, 0.15, 0.05, 0.02],
        Timbre.organ => const [1.0, 0.6, 0.0, 0.4, 0.0, 0.0, 0.0, 0.3],
      };

  /// アタック (秒)。
  double get attack => switch (this) {
        Timbre.piano => 0.005,
        Timbre.violin => 0.08,
        Timbre.flute => 0.04,
        _ => 0.01,
      };

  /// 減衰の時定数 (秒)。null なら持続音。
  double? get decayTau => this == Timbre.piano ? 0.35 : null;
}

const int sampleRate = 44100;

/// [frequency] Hz の音を [duration] 秒ぶん合成する (-1..1 の float)。
/// ラウドネスの手がかりを消すため RMS を [targetRms] に正規化する。
Float64List synthesize(
  double frequency,
  Timbre timbre, {
  double duration = 0.7,
  double targetRms = 0.15,
}) {
  final n = (duration * sampleRate).round();
  final samples = Float64List(n);
  final harmonics = timbre.harmonics;
  final release = 0.06; // 終端のフェード (秒)

  for (var i = 0; i < n; i++) {
    final t = i / sampleRate;
    var v = 0.0;
    for (var h = 0; h < harmonics.length; h++) {
      final amp = harmonics[h];
      if (amp == 0) continue;
      final f = frequency * (h + 1);
      if (f * 2 >= sampleRate) break; // ナイキスト超えは足さない
      v += amp * sin(2 * pi * f * t);
    }
    // エンベロープ
    var env = 1.0;
    if (t < timbre.attack) env = t / timbre.attack;
    final tau = timbre.decayTau;
    if (tau != null) env *= exp(-(t - timbre.attack).clamp(0, duration) / tau);
    final tail = duration - t;
    if (tail < release) env *= tail / release;
    samples[i] = v * env;
  }

  // RMS 正規化 + クリップ
  var sq = 0.0;
  for (final s in samples) {
    sq += s * s;
  }
  final rms = sqrt(sq / n);
  final gain = rms == 0 ? 0 : targetRms / rms;
  for (var i = 0; i < n; i++) {
    samples[i] = (samples[i] * gain).clamp(-1.0, 1.0);
  }
  return samples;
}

/// -1..1 の float サンプルを 16bit PCM mono の WAV バイト列にする。
Uint8List toWav(Float64List samples) {
  final n = samples.length;
  final dataSize = n * 2;
  final bytes = ByteData(44 + dataSize);

  void writeAscii(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      bytes.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  writeAscii(0, 'RIFF');
  bytes.setUint32(4, 36 + dataSize, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little); // fmt チャンクサイズ
  bytes.setUint16(20, 1, Endian.little); // PCM
  bytes.setUint16(22, 1, Endian.little); // mono
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  bytes.setUint16(32, 2, Endian.little); // block align
  bytes.setUint16(34, 16, Endian.little); // bits
  writeAscii(36, 'data');
  bytes.setUint32(40, dataSize, Endian.little);
  for (var i = 0; i < n; i++) {
    bytes.setInt16(44 + i * 2, (samples[i] * 32767).round(), Endian.little);
  }
  return bytes.buffer.asUint8List();
}

/// 音を WAV バイト列で得る。
Uint8List toneWav(double frequency, Timbre timbre, {double duration = 0.7}) =>
    toWav(synthesize(frequency, timbre, duration: duration));

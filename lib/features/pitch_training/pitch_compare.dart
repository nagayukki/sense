import 'dart:math';

import '../../core/audio/tone_synth.dart';
import '../../core/training/staircase.dart';

/// 「どちらが高い」の1問。
class PitchTrial {
  const PitchTrial({
    required this.freqA,
    required this.freqB,
    required this.timbreA,
    required this.timbreB,
    required this.diffCents,
  });

  final double freqA;
  final double freqB;
  final Timbre timbreA;
  final Timbre timbreB;

  /// 高い方と低い方の差 (セント)。
  final double diffCents;

  bool get aIsHigher => freqA > freqB;
}

/// 指定した差 (セント) の問題を生成する。
///
/// [mixTimbres] が true なら A と B で音色を変える (高さだけで比べる力を試す)。
PitchTrial generatePitchTrial({
  required double diffCents,
  bool mixTimbres = true,
  Random? random,
}) {
  final rng = random ?? Random();
  // 基準 220-880Hz を対数一様に。毎回変えてアンカーを防ぐ
  final base = 220 * pow(2, rng.nextDouble() * 2).toDouble();
  final higher = base * pow(2, diffCents / 1200).toDouble();
  final aHigher = rng.nextBool();

  Timbre pick() => Timbre.values[rng.nextInt(Timbre.values.length)];
  final ta = pick();
  final tb = mixTimbres ? pick() : ta;

  return PitchTrial(
    freqA: aHigher ? higher : base,
    freqB: aHigher ? base : higher,
    timbreA: ta,
    timbreB: tb,
    diffCents: diffCents,
  );
}

/// 1 セッション。差 (セント) の階段法。
class PitchSession {
  PitchSession({int trialCount = 12, this.mixTimbres = true, Random? random})
      : _staircase = Staircase(
          start: 100, // 半音からスタート
          min: 1,
          max: 600,
          trialCount: trialCount,
        ),
        _random = random ?? Random() {
    _next();
  }

  final bool mixTimbres;
  final Staircase _staircase;
  final Random _random;

  PitchTrial? _trial;
  PitchTrial? get trial => _trial;
  int get trialCount => _staircase.trialCount;
  int get answered => _staircase.answered;
  bool get isFinished => _staircase.isFinished;
  int get correctCount => _staircase.correctCount;

  bool answer({required bool choseA}) {
    final trial = _trial;
    if (trial == null) throw StateError('セッションは終了している');
    final correct = choseA == trial.aIsHigher;
    _staircase.record(presented: trial.diffCents, correct: correct);
    _next();
    return correct;
  }

  void _next() {
    _trial = isFinished
        ? null
        : generatePitchTrial(
            diffCents: _staircase.value,
            mixTimbres: mixTimbres,
            random: _random,
          );
  }

  double get threshold => _staircase.threshold();
}

/// 閾値の評価コメント。一般の弁別限界は 10-25 セント、音楽家は 5-10 と言われる。
String pitchRating(double cents) {
  if (cents < 5) return '超人級。調律師の耳です';
  if (cents < 10) return '音楽家級。鋭い耳の持ち主です';
  if (cents < 25) return '良好。標準的な音感です';
  if (cents < 60) return 'のびしろあり。また挑戦してみよう';
  return 'まずは大きな差から楽しもう (半音 = 100 セント)';
}

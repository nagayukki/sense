import 'dart:math';

import '../../core/training/staircase.dart';

/// 「どちらが開いている」の1問。
class AngleTrial {
  const AngleTrial({
    required this.angleA,
    required this.angleB,
    required this.rotationA,
    required this.rotationB,
    required this.diffDegrees,
  });

  /// 開き (度)。
  final double angleA;
  final double angleB;

  /// 全体の回転 (ラジアン)。向きで判断させないための揺らぎ。
  final double rotationA;
  final double rotationB;

  final double diffDegrees;

  bool get aIsWider => angleA > angleB;
}

/// 指定した差 (度) の問題を生成する。
AngleTrial generateAngleTrial({
  required double diffDegrees,
  Random? random,
}) {
  final rng = random ?? Random();
  // 基準の開き 25-140°。大きい方も 165° に収める
  final base = 25 + rng.nextDouble() * (140 - 25).toDouble();
  final wider = min(base + diffDegrees, 165.0);
  final actualDiff = wider - base;
  final aWider = rng.nextBool();
  double rot() => rng.nextDouble() * 2 * pi;
  return AngleTrial(
    angleA: aWider ? wider : base,
    angleB: aWider ? base : wider,
    rotationA: rot(),
    rotationB: rot(),
    diffDegrees: actualDiff,
  );
}

/// 1 セッション。差 (度) の階段法。
class AngleSession {
  AngleSession({int trialCount = 12, Random? random})
      : _staircase = Staircase(
          start: 15,
          min: 0.2,
          max: 40,
          trialCount: trialCount,
        ),
        _random = random ?? Random() {
    _next();
  }

  final Staircase _staircase;
  final Random _random;

  AngleTrial? _trial;
  AngleTrial? get trial => _trial;
  int get trialCount => _staircase.trialCount;
  int get answered => _staircase.answered;
  bool get isFinished => _staircase.isFinished;
  int get correctCount => _staircase.correctCount;

  bool answer({required bool choseA}) {
    final trial = _trial;
    if (trial == null) throw StateError('セッションは終了している');
    final correct = choseA == trial.aIsWider;
    _staircase.record(presented: trial.diffDegrees, correct: correct);
    _next();
    return correct;
  }

  void _next() {
    _trial = isFinished
        ? null
        : generateAngleTrial(diffDegrees: _staircase.value, random: _random);
  }

  double get threshold => _staircase.threshold();
}

/// 閾値の評価コメント。
String angleRating(double degrees) {
  if (degrees < 1.0) return '超人級。分度器いらずの精度です';
  if (degrees < 2.5) return 'かなり鋭い。図面を目で読めるレベルです';
  if (degrees < 5.0) return '良好。標準的な識別力です';
  if (degrees < 10.0) return 'のびしろあり。また挑戦してみよう';
  return 'まずは大きな差から楽しもう';
}

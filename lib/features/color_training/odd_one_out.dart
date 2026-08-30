import 'dart:math';
import 'dart:ui';

import '../../core/color/ciede2000.dart';
import '../../core/color/lab.dart';
import '../../core/training/staircase.dart';

/// 「1つだけ違う色」の1問。
class OddOneOutTrial {
  const OddOneOutTrial({
    required this.baseColor,
    required this.oddColor,
    required this.oddIndex,
    required this.targetDeltaE,
    required this.actualDeltaE,
  });

  final Color baseColor;
  final Color oddColor;
  final int oddIndex;
  final double targetDeltaE;
  final double actualDeltaE;
}

/// 指定した色差 (CIEDE2000) を持つ問題を生成する。
OddOneOutTrial generateTrial({
  required double deltaE,
  required int tileCount,
  Random? random,
}) {
  final rng = random ?? Random();
  for (var attempt = 0; attempt < 100; attempt++) {
    // 端に寄りすぎない基準色 (色域内で動かす余地を残す)
    final base = Color.fromARGB(
      255,
      40 + rng.nextInt(176),
      40 + rng.nextInt(176),
      40 + rng.nextInt(176),
    );
    final baseLab = srgbToLab(
      (base.r * 255).round(),
      (base.g * 255).round(),
      (base.b * 255).round(),
    );

    // Lab 空間のランダムな方向に、ΔE00 が目標値になる距離を二分探索
    final theta = rng.nextDouble() * 2 * pi;
    final lSign = rng.nextBool() ? 1.0 : -1.0;
    Lab at(double t) => Lab(
          baseLab.l + lSign * t * 0.4,
          baseLab.a + cos(theta) * t,
          baseLab.b + sin(theta) * t,
        );

    var lo = 0.0, hi = 60.0;
    if (ciede2000(baseLab, at(hi)) < deltaE) continue;
    for (var i = 0; i < 40; i++) {
      final mid = (lo + hi) / 2;
      if (ciede2000(baseLab, at(mid)) < deltaE) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    final odd = labToSrgb(at(hi));
    if (odd == null) continue;

    final actual = ciede2000(
      baseLab,
      srgbToLab(
        (odd.r * 255).round(),
        (odd.g * 255).round(),
        (odd.b * 255).round(),
      ),
    );
    // 8bit 量子化で目標からずれすぎた問題は捨てる
    if ((actual - deltaE).abs() > deltaE * 0.25 + 0.15) continue;

    return OddOneOutTrial(
      baseColor: base,
      oddColor: odd,
      oddIndex: rng.nextInt(tileCount),
      targetDeltaE: deltaE,
      actualDeltaE: actual,
    );
  }
  throw StateError('問題を生成できなかった (deltaE=$deltaE)');
}

/// 1 セッション。正解で色差を狭め、不正解で広げる (階段法)。
class OddOneOutSession {
  OddOneOutSession({
    int trialCount = 12,
    this.tileCount = 16,
    double startDeltaE = 16,
    Random? random,
  })  : _staircase = Staircase(
          start: startDeltaE,
          min: 0.2,
          max: 40,
          trialCount: trialCount,
        ),
        _random = random ?? Random() {
    _next();
  }

  final int tileCount;
  final Random _random;
  final Staircase _staircase;

  OddOneOutTrial? _trial;

  OddOneOutTrial? get trial => _trial;
  int get trialCount => _staircase.trialCount;
  int get answered => _staircase.answered;
  bool get isFinished => _staircase.isFinished;
  int get correctCount => _staircase.correctCount;

  void _next() {
    _trial = isFinished
        ? null
        : generateTrial(
            deltaE: _staircase.value, tileCount: tileCount, random: _random);
  }

  /// タイル [index] を選んだ。正解なら true。
  bool answer(int index) {
    final trial = _trial;
    if (trial == null) throw StateError('セッションは終了している');
    final correct = index == trial.oddIndex;
    _staircase.record(presented: trial.actualDeltaE, correct: correct);
    _next();
    return correct;
  }

  /// 識別閾値の推定値。終盤の試行の幾何平均。
  double get threshold => _staircase.threshold();
}

/// 閾値の評価コメント。
String thresholdRating(double deltaE) {
  if (deltaE < 0.8) return '超人級。一般に ΔE 1.0 が識別限界と言われる領域を下回っています';
  if (deltaE < 1.5) return 'かなり鋭い。プロの現場でも通用する識別力です';
  if (deltaE < 3.0) return '良好。日常で困らない標準的な識別力です';
  if (deltaE < 6.0) return 'のびしろあり。訓練で狭くなっていきます';
  return 'まずは大きな差から慣れていきましょう';
}

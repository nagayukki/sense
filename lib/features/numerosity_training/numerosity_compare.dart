import 'dart:math';

import '../../core/training/staircase.dart';

/// 点1つ。座標と半径はカードの短辺を 1 とした相対値。
class Dot {
  const Dot(this.x, this.y, this.r);

  final double x;
  final double y;
  final double r;
}

/// 「どちらが多い」の1問。
class NumerosityTrial {
  const NumerosityTrial({
    required this.dotsA,
    required this.dotsB,
    required this.diffPercent,
    required this.areaEqualized,
  });

  final List<Dot> dotsA;
  final List<Dot> dotsB;
  final double diffPercent;

  /// true なら両側の点の合計面積を揃えてある (面積で数を推測できない)。
  final bool areaEqualized;

  int get countA => dotsA.length;
  int get countB => dotsB.length;
  bool get aHasMore => countA > countB;
}

List<Dot> _layoutDots(int count, Random rng) {
  final dots = <Dot>[];
  for (var i = 0; i < count; i++) {
    final r = 0.018 + rng.nextDouble() * 0.022;
    var placed = false;
    for (var attempt = 0; attempt < 300; attempt++) {
      final x = r + 0.02 + rng.nextDouble() * (1 - 2 * (r + 0.02));
      final y = r + 0.02 + rng.nextDouble() * (1 - 2 * (r + 0.02));
      final ok = dots.every((d) {
        final dx = d.x - x, dy = d.y - y;
        return sqrt(dx * dx + dy * dy) > (d.r + r) * 1.25;
      });
      if (ok) {
        dots.add(Dot(x, y, r));
        placed = true;
        break;
      }
    }
    if (!placed) {
      // 置けなければ少し小さくして無理やり置く
      dots.add(Dot(
        0.05 + rng.nextDouble() * 0.9,
        0.05 + rng.nextDouble() * 0.9,
        0.015,
      ));
    }
  }
  return dots;
}

List<Dot> _scaleArea(List<Dot> dots, double targetArea) {
  var area = 0.0;
  for (final d in dots) {
    area += d.r * d.r;
  }
  final k = sqrt(targetArea / area);
  return [for (final d in dots) Dot(d.x, d.y, d.r * k)];
}

/// 指定した数の差 (%) の問題を生成する。
NumerosityTrial generateNumerosityTrial({
  required double diffPercent,
  Random? random,
}) {
  final rng = random ?? Random();
  // 基準 12-28 個
  final base = 12 + rng.nextInt(17);
  var larger = (base * (1 + diffPercent / 100)).round();
  if (larger == base) larger = base + 1;
  final aMore = rng.nextBool();
  final countA = aMore ? larger : base;
  final countB = aMore ? base : larger;

  var dotsA = _layoutDots(countA, rng);
  var dotsB = _layoutDots(countB, rng);

  // 半分の問題で合計面積を揃える (面積の手がかりを排除)。
  // 残り半分はそのまま (自然な相関を残す) — ANS 課題の定石
  final equalize = rng.nextBool();
  if (equalize) {
    var areaB = 0.0;
    for (final d in dotsB) {
      areaB += d.r * d.r;
    }
    dotsA = _scaleArea(dotsA, areaB);
  }

  return NumerosityTrial(
    dotsA: dotsA,
    dotsB: dotsB,
    diffPercent: diffPercent,
    areaEqualized: equalize,
  );
}

/// 1 セッション。数の差 (%) の階段法。
class NumerositySession {
  NumerositySession({int trialCount = 12, Random? random})
      : _staircase = Staircase(
          start: 50,
          min: 4,
          max: 100,
          trialCount: trialCount,
        ),
        _random = random ?? Random() {
    _next();
  }

  final Staircase _staircase;
  final Random _random;

  NumerosityTrial? _trial;
  NumerosityTrial? get trial => _trial;
  int get trialCount => _staircase.trialCount;
  int get answered => _staircase.answered;
  bool get isFinished => _staircase.isFinished;
  int get correctCount => _staircase.correctCount;

  bool answer({required bool choseA}) {
    final trial = _trial;
    if (trial == null) throw StateError('セッションは終了している');
    final correct = choseA == trial.aHasMore;
    // 丸めで実際の差が変わるので、提示した実差を記録する
    final actual = (max(trial.countA, trial.countB) /
                min(trial.countA, trial.countB) -
            1) *
        100;
    _staircase.record(presented: actual, correct: correct);
    _next();
    return correct;
  }

  void _next() {
    _trial = isFinished
        ? null
        : generateNumerosityTrial(
            diffPercent: _staircase.value, random: _random);
  }

  double get threshold => _staircase.threshold();
}

/// 閾値の評価コメント。大人の数量感覚 (ANS) は 15-25% 程度と言われる。
String numerosityRating(double percent) {
  if (percent < 10) return '超人級。数えずに数が見えています';
  if (percent < 15) return 'かなり鋭い。一般的な弁別限界を下回っています';
  if (percent < 25) return '良好。標準的な数量感覚です';
  if (percent < 45) return 'のびしろあり。また挑戦してみよう';
  return 'まずは大きな差から楽しもう';
}

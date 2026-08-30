import 'dart:math';

import '../../core/training/staircase.dart';

/// 図形の種類。面積比較は「形が違っても比べられるか」が肝。
enum AreaShape { circle, square, rect }

/// 「どちらが広い」の1問。
class AreaTrial {
  const AreaTrial({
    required this.shapeA,
    required this.shapeB,
    required this.areaA,
    required this.areaB,
    required this.aspectA,
    required this.aspectB,
    required this.diffPercent,
  });

  final AreaShape shapeA;
  final AreaShape shapeB;

  /// 相対面積。カードの短辺を 1 とした正方形換算。
  final double areaA;
  final double areaB;

  /// rect の縦横比 (それ以外は 1)。
  final double aspectA;
  final double aspectB;

  final double diffPercent;

  bool get aIsLarger => areaA > areaB;
}

/// 指定した面積差 (%) の問題を生成する。
AreaTrial generateAreaTrial({
  required double diffPercent,
  Random? random,
}) {
  final rng = random ?? Random();
  AreaShape shape() => AreaShape.values[rng.nextInt(AreaShape.values.length)];
  final sa = shape(), sb = shape();
  double aspect(AreaShape s) =>
      s == AreaShape.rect ? 1.4 + rng.nextDouble() * 0.9 : 1.0;
  final aa = aspect(sa), ab = aspect(sb);

  // 最長辺が 0.9 を超えない面積の上限 (円は直径、rect は長辺で決まる)
  double allowed(AreaShape s, double aspect) =>
      s == AreaShape.circle ? 0.81 * pi / 4 : 0.81 / aspect;
  final factor = 1 + diffPercent / 100;
  final maxBase = min(allowed(sa, aa), allowed(sb, ab)) / factor;

  // 基準面積 0.08-0.28 (短辺 1 の正方形換算)。大きい方も収まる範囲に丸める
  final base = 0.08 + rng.nextDouble() * (min(0.28, maxBase) - 0.08);
  final larger = base * factor;
  final aLarger = rng.nextBool();
  return AreaTrial(
    shapeA: sa,
    shapeB: sb,
    areaA: aLarger ? larger : base,
    areaB: aLarger ? base : larger,
    aspectA: aa,
    aspectB: ab,
    diffPercent: diffPercent,
  );
}

/// 1 セッション。面積差 (%) の階段法。
class AreaSession {
  AreaSession({int trialCount = 12, Random? random})
      : _staircase = Staircase(
          start: 30,
          min: 0.5,
          max: 80,
          trialCount: trialCount,
        ),
        _random = random ?? Random() {
    _next();
  }

  final Staircase _staircase;
  final Random _random;

  AreaTrial? _trial;
  AreaTrial? get trial => _trial;
  int get trialCount => _staircase.trialCount;
  int get answered => _staircase.answered;
  bool get isFinished => _staircase.isFinished;
  int get correctCount => _staircase.correctCount;

  bool answer({required bool choseA}) {
    final trial = _trial;
    if (trial == null) throw StateError('セッションは終了している');
    final correct = choseA == trial.aIsLarger;
    _staircase.record(presented: trial.diffPercent, correct: correct);
    _next();
    return correct;
  }

  void _next() {
    _trial = isFinished
        ? null
        : generateAreaTrial(diffPercent: _staircase.value, random: _random);
  }

  double get threshold => _staircase.threshold();
}

/// 閾値の評価コメント。面積の弁別閾は長さより広く、一般に 6-10% 程度と言われる。
String areaRating(double percent) {
  if (percent < 4.0) return '超人級。面積を数字のように読めています';
  if (percent < 8.0) return 'かなり鋭い。一般的な弁別限界を下回っています';
  if (percent < 15.0) return '良好。標準的な識別力です';
  if (percent < 30.0) return 'のびしろあり。また挑戦してみよう';
  return 'まずは大きな差から楽しもう';
}

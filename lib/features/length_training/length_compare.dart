import 'dart:math';

import '../../core/training/staircase.dart';

/// 「どちらが長い」の1問。2本の線分を提示する。
class LengthTrial {
  const LengthTrial({
    required this.lengthA,
    required this.lengthB,
    required this.diffPercent,
    required this.angleA,
    required this.angleB,
  });

  /// 0-1 の相対長 (画面幅に対する比率で描く)。
  final double lengthA;
  final double lengthB;

  /// 長い方が短い方より何 % 長いか。
  final double diffPercent;

  /// 描画角度 (ラジアン)。端点の位置合わせで判断させないための揺らぎ。
  final double angleA;
  final double angleB;

  bool get aIsLonger => lengthA > lengthB;
}

/// 指定した差 (%) の問題を生成する。
LengthTrial generateLengthTrial({
  required double diffPercent,
  Random? random,
}) {
  final rng = random ?? Random();
  // 基準の長さ 0.45-0.75。長い方がはみ出さない範囲に収める
  final base = 0.45 + rng.nextDouble() * 0.3;
  final longer = base * (1 + diffPercent / 100);
  final aLonger = rng.nextBool();
  // 傾き ±12°。回転で長さの見えを壊しすぎない範囲
  double angle() => (rng.nextDouble() - 0.5) * (24 * pi / 180);
  return LengthTrial(
    lengthA: aLonger ? longer : base,
    lengthB: aLonger ? base : longer,
    diffPercent: diffPercent,
    angleA: angle(),
    angleB: angle(),
  );
}

/// 1 セッション。差 (%) の階段法。
class LengthSession {
  LengthSession({int trialCount = 12, Random? random})
      : _staircase = Staircase(
          start: 20,
          min: 0.3,
          max: 60,
          trialCount: trialCount,
        ),
        _random = random ?? Random() {
    _next();
  }

  final Staircase _staircase;
  final Random _random;

  LengthTrial? _trial;
  LengthTrial? get trial => _trial;
  int get trialCount => _staircase.trialCount;
  int get answered => _staircase.answered;
  bool get isFinished => _staircase.isFinished;
  int get correctCount => _staircase.correctCount;

  void _next() {
    _trial = isFinished
        ? null
        : generateLengthTrial(diffPercent: _staircase.value, random: _random);
  }

  /// A (true) / B (false) を選んだ。正解なら true。
  bool answer({required bool choseA}) {
    final trial = _trial;
    if (trial == null) throw StateError('セッションは終了している');
    final correct = choseA == trial.aIsLonger;
    _staircase.record(presented: trial.diffPercent, correct: correct);
    _next();
    return correct;
  }

  /// 識別閾値 (%) の推定値。
  double get threshold => _staircase.threshold();
}

/// 閾値の評価コメント。長さの弁別閾は一般に 2-5% と言われる。
String lengthRating(double percent) {
  if (percent < 1.5) return '超人級。定規いらずの精度です';
  if (percent < 3.0) return 'かなり鋭い。一般的な弁別限界を下回っています';
  if (percent < 6.0) return '良好。標準的な識別力です';
  if (percent < 12.0) return 'のびしろあり。また挑戦してみよう';
  return 'まずは大きな差から楽しもう';
}

import 'dart:math';

import '../../core/training/staircase.dart';

/// 「どちらが速い」の1問。2つのクリック列を提示する。
class TempoTrial {
  const TempoTrial({
    required this.intervalA,
    required this.intervalB,
    required this.clickCount,
    required this.diffPercent,
  });

  final Duration intervalA;
  final Duration intervalB;
  final int clickCount;
  final double diffPercent;

  /// 速い = 間隔が短い。
  bool get aIsFaster => intervalA < intervalB;
}

/// 指定した間隔差 (%) の問題を生成する。
TempoTrial generateTempoTrial({
  required double diffPercent,
  Random? random,
}) {
  final rng = random ?? Random();
  // 基準間隔 300-600ms。毎回変えてアンカーを防ぐ
  final baseUs = (300 + rng.nextInt(301)) * 1000;
  final slowerUs = (baseUs * (1 + diffPercent / 100)).round();
  final aFaster = rng.nextBool();
  return TempoTrial(
    intervalA: Duration(microseconds: aFaster ? baseUs : slowerUs),
    intervalB: Duration(microseconds: aFaster ? slowerUs : baseUs),
    clickCount: 5,
    diffPercent: diffPercent,
  );
}

/// 1 セッション。間隔差 (%) の階段法。
class TempoSession {
  TempoSession({int trialCount = 10, Random? random})
      : _staircase = Staircase(
          start: 25,
          min: 0.5,
          max: 60,
          trialCount: trialCount,
        ),
        _random = random ?? Random() {
    _next();
  }

  final Staircase _staircase;
  final Random _random;

  TempoTrial? _trial;
  TempoTrial? get trial => _trial;
  int get trialCount => _staircase.trialCount;
  int get answered => _staircase.answered;
  bool get isFinished => _staircase.isFinished;
  int get correctCount => _staircase.correctCount;

  bool answer({required bool choseA}) {
    final trial = _trial;
    if (trial == null) throw StateError('セッションは終了している');
    final correct = choseA == trial.aIsFaster;
    _staircase.record(presented: trial.diffPercent, correct: correct);
    _next();
    return correct;
  }

  void _next() {
    _trial = isFinished
        ? null
        : generateTempoTrial(diffPercent: _staircase.value, random: _random);
  }

  double get threshold => _staircase.threshold();
}

/// 結果の評価コメント。テンポの弁別閾は一般に 2-5% 程度と言われる。
String tempoRating(double percent) {
  if (percent < 2) return '超人級。メトロノームの耳です';
  if (percent < 4) return 'かなり鋭い。一般的な弁別限界を下回っています';
  if (percent < 8) return '良好。標準的なテンポ感です';
  if (percent < 20) return 'のびしろあり。また挑戦してみよう';
  return 'まずは大きな差から楽しもう';
}

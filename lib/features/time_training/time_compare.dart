import 'dart:math';

import '../../core/training/staircase.dart';

/// 「どちらが長かった」の1問。2つの時間間隔を提示する。
class TimeTrial {
  const TimeTrial({
    required this.durationA,
    required this.durationB,
    required this.diffPercent,
  });

  final Duration durationA;
  final Duration durationB;
  final double diffPercent;

  bool get aIsLonger => durationA > durationB;
}

/// 指定した差 (%) の問題を生成する。
TimeTrial generateTimeTrial({
  required double diffPercent,
  Random? random,
}) {
  final rng = random ?? Random();
  // 基準 0.8-2.0 秒。毎回変えてアンカーを防ぐ
  final baseMs = 800 + rng.nextInt(1201);
  final longerMs = (baseMs * (1 + diffPercent / 100)).round();
  final aLonger = rng.nextBool();
  return TimeTrial(
    durationA: Duration(milliseconds: aLonger ? longerMs : baseMs),
    durationB: Duration(milliseconds: aLonger ? baseMs : longerMs),
    diffPercent: diffPercent,
  );
}

/// 1 セッション。差 (%) の階段法。
class TimeSession {
  TimeSession({int trialCount = 10, Random? random})
      : _staircase = Staircase(
          start: 35,
          min: 2,
          max: 80,
          trialCount: trialCount,
        ),
        _random = random ?? Random() {
    _next();
  }

  final Staircase _staircase;
  final Random _random;

  TimeTrial? _trial;
  TimeTrial? get trial => _trial;
  int get trialCount => _staircase.trialCount;
  int get answered => _staircase.answered;
  bool get isFinished => _staircase.isFinished;
  int get correctCount => _staircase.correctCount;

  bool answer({required bool choseA}) {
    final trial = _trial;
    if (trial == null) throw StateError('セッションは終了している');
    final correct = choseA == trial.aIsLonger;
    _staircase.record(presented: trial.diffPercent, correct: correct);
    _next();
    return correct;
  }

  void _next() {
    _trial = isFinished
        ? null
        : generateTimeTrial(diffPercent: _staircase.value, random: _random);
  }

  double get threshold => _staircase.threshold();
}

/// 閾値の評価コメント。時間の弁別閾は一般に 5-15% 程度と言われる。
String timeRating(double percent) {
  if (percent < 5) return '超人級。体内時計が正確すぎます';
  if (percent < 10) return 'かなり鋭い。一般的な弁別限界を下回っています';
  if (percent < 20) return '良好。標準的な時間感覚です';
  if (percent < 40) return 'のびしろあり。また挑戦してみよう';
  return 'まずは大きな差から楽しもう';
}

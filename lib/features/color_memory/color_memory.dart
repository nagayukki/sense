import 'dart:math';
import 'dart:ui';

import '../../core/color/color_gen.dart';
import '../../core/training/staircase.dart';

/// 「さっきの色はどれ?」の1問。
class ColorMemoryTrial {
  const ColorMemoryTrial({
    required this.target,
    required this.choices,
    required this.answerIndex,
    required this.deltaE,
  });

  /// 覚えてもらう色。
  final Color target;

  /// 選択肢 (target を含む)。
  final List<Color> choices;

  /// choices の中の正解位置。
  final int answerIndex;

  /// distractor と正解の色差。
  final double deltaE;
}

/// 指定した色差 (CIEDE2000) の distractor を持つ問題を生成する。
ColorMemoryTrial generateColorMemoryTrial({
  required double deltaE,
  int choiceCount = 6,
  Random? random,
}) {
  final rng = random ?? Random();
  for (var attempt = 0; attempt < 100; attempt++) {
    final target = randomBaseColor(rng);
    final distractors = <Color>[];
    var failed = false;
    for (var i = 0; i < choiceCount - 1; i++) {
      Color? d;
      for (var retry = 0; retry < 20; retry++) {
        d = colorAtDeltaE(target, deltaE, rng);
        // 既存の distractor と近すぎる場合は引き直す
        if (d != null && !distractors.contains(d)) break;
        d = null;
      }
      if (d == null) {
        failed = true;
        break;
      }
      distractors.add(d);
    }
    if (failed) continue;

    final answerIndex = rng.nextInt(choiceCount);
    final choices = [...distractors]..insert(answerIndex, target);
    return ColorMemoryTrial(
      target: target,
      choices: choices,
      answerIndex: answerIndex,
      deltaE: deltaE,
    );
  }
  throw StateError('問題を生成できなかった (deltaE=$deltaE)');
}

/// 1 セッション。distractor の色差の階段法。
class ColorMemorySession {
  ColorMemorySession({int trialCount = 10, Random? random})
      : _staircase = Staircase(
          start: 20,
          min: 0.5,
          max: 50,
          trialCount: trialCount,
        ),
        _random = random ?? Random() {
    _next();
  }

  /// 色を見せる時間。
  static const showDuration = Duration(milliseconds: 1500);

  /// 見せ終わってから選択肢を出すまでの待ち。
  static const delayDuration = Duration(milliseconds: 2000);

  final Staircase _staircase;
  final Random _random;

  ColorMemoryTrial? _trial;
  ColorMemoryTrial? get trial => _trial;
  int get trialCount => _staircase.trialCount;
  int get answered => _staircase.answered;
  bool get isFinished => _staircase.isFinished;
  int get correctCount => _staircase.correctCount;

  bool answer(int index) {
    final trial = _trial;
    if (trial == null) throw StateError('セッションは終了している');
    final correct = index == trial.answerIndex;
    _staircase.record(presented: trial.deltaE, correct: correct);
    _next();
    return correct;
  }

  void _next() {
    _trial = isFinished
        ? null
        : generateColorMemoryTrial(
            deltaE: _staircase.value, random: _random);
  }

  double get threshold => _staircase.threshold();
}

/// 結果の評価コメント。記憶を挟むと閾値はくらべより広くなるのが普通。
String colorMemoryRating(double deltaE) {
  if (deltaE < 3) return '超人級。色が写真のように残っています';
  if (deltaE < 6) return 'かなり鋭い。頭の中のパレットが正確です';
  if (deltaE < 12) return '良好。標準的な色の記憶です';
  if (deltaE < 25) return 'のびしろあり。また挑戦してみよう';
  return 'まずは大きな差から楽しもう';
}

import 'dart:math';

/// 階段法 (adaptive staircase)。
///
/// 正解で刺激差を狭め、不正解で広げて識別閾値に収束させる。
/// 色差 (ΔE) や長さの差 (%) など、どの感覚にも共通で使う。
class Staircase {
  Staircase({
    required double start,
    required this.min,
    required this.max,
    this.downFactor = 0.7,
    this.upFactor = 1.6,
    this.trialCount = 12,
  }) : _value = start;

  final double min;
  final double max;
  final double downFactor;
  final double upFactor;
  final int trialCount;

  double _value;
  final List<({double value, bool correct})> results = [];

  /// 現在の刺激差。
  double get value => _value;

  int get answered => results.length;
  bool get isFinished => results.length >= trialCount;
  int get correctCount => results.where((r) => r.correct).length;

  /// 実際に提示した刺激差 [presented] に対する回答を記録する。
  void record({required double presented, required bool correct}) {
    if (isFinished) throw StateError('セッションは終了している');
    results.add((value: presented, correct: correct));
    _value = (correct ? _value * downFactor : _value * upFactor)
        .clamp(min, max);
  }

  /// 識別閾値の推定値。終盤 [tailLength] 試行の幾何平均。
  double threshold({int tailLength = 5}) {
    final tail = results.length <= tailLength
        ? results
        : results.sublist(results.length - tailLength);
    if (tail.isEmpty) return double.nan;
    var logSum = 0.0;
    for (final r in tail) {
      logSum += log(r.value);
    }
    return exp(logSum / tail.length);
  }
}

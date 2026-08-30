import 'dart:math';

/// リズムキープの採点。タップ時刻の列から「刻みの正確さ」を出す。
///
/// 表現ポリシー: 出すのは測定事実 (ズレ%・ばらつき%) のみ。
class RhythmKeepResult {
  const RhythmKeepResult({
    required this.meanAbsDeviationPercent,
    required this.variabilityPercent,
    required this.intervalCount,
  });

  /// 目標間隔に対する平均ズレ (%)。
  final double meanAbsDeviationPercent;

  /// タップ間隔のばらつき (標準偏差 / 目標間隔, %)。
  final double variabilityPercent;

  final int intervalCount;
}

/// タップ時刻 (ミリ秒) と目標間隔から結果を計算する。
///
/// タップの絶対タイミングではなく間隔で評価するため、
/// 端末の入出力レイテンシ (一定のオフセット) の影響を受けない。
RhythmKeepResult scoreRhythmKeep({
  required List<int> tapTimesMs,
  required Duration targetInterval,
}) {
  if (tapTimesMs.length < 2) {
    return const RhythmKeepResult(
      meanAbsDeviationPercent: double.nan,
      variabilityPercent: double.nan,
      intervalCount: 0,
    );
  }
  final target = targetInterval.inMilliseconds.toDouble();
  final intervals = <double>[
    for (var i = 1; i < tapTimesMs.length; i++)
      (tapTimesMs[i] - tapTimesMs[i - 1]).toDouble(),
  ];

  var absDev = 0.0;
  var mean = 0.0;
  for (final iv in intervals) {
    absDev += (iv - target).abs();
    mean += iv;
  }
  absDev /= intervals.length;
  mean /= intervals.length;

  var varSum = 0.0;
  for (final iv in intervals) {
    varSum += (iv - mean) * (iv - mean);
  }
  final sd = sqrt(varSum / intervals.length);

  return RhythmKeepResult(
    meanAbsDeviationPercent: absDev / target * 100,
    variabilityPercent: sd / target * 100,
    intervalCount: intervals.length,
  );
}

/// 結果の評価コメント。
String rhythmKeepRating(double meanAbsDevPercent) {
  if (meanAbsDevPercent < 3) return 'メトロノーム級。正確すぎます';
  if (meanAbsDevPercent < 6) return 'かなり正確。バンドで頼られるやつです';
  if (meanAbsDevPercent < 12) return '良好。安定した刻みです';
  if (meanAbsDevPercent < 20) return 'のびしろあり。また挑戦してみよう';
  return '自由なリズム。それもまた音楽です';
}

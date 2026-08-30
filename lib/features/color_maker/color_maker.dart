import 'dart:math';
import 'dart:ui';

import '../../core/color/ciede2000.dart';
import '../../core/color/color_gen.dart';
import '../../core/color/lab.dart';

/// 作った色と見本の色差 (CIEDE2000)。
double scoreColorMatch(Color target, Color made) => ciede2000(
      srgbToLab(
        (target.r * 255).round(),
        (target.g * 255).round(),
        (target.b * 255).round(),
      ),
      srgbToLab(
        (made.r * 255).round(),
        (made.g * 255).round(),
        (made.b * 255).round(),
      ),
    );

/// 1 セッション。見本を再現して ΔE の平均を出す (階段法ではない)。
class ColorMakerSession {
  ColorMakerSession({this.roundCount = 5, Random? random})
      : _random = random ?? Random() {
    _next();
  }

  final int roundCount;
  final Random _random;

  Color? _target;
  final List<double> results = [];

  Color? get target => _target;
  int get answered => results.length;
  bool get isFinished => results.length >= roundCount;

  void _next() {
    _target = isFinished ? null : randomBaseColor(_random);
  }

  /// 作った色を提出し、その回の ΔE を返す。
  double submit(Color made) {
    final target = _target;
    if (target == null) throw StateError('セッションは終了している');
    final deltaE = scoreColorMatch(target, made);
    results.add(deltaE);
    _next();
    return deltaE;
  }

  /// 全ラウンドの平均 ΔE。
  double get averageDeltaE {
    if (results.isEmpty) return double.nan;
    return results.reduce((a, b) => a + b) / results.length;
  }

  /// ベスト (最小) の ΔE。
  double get bestDeltaE =>
      results.isEmpty ? double.nan : results.reduce(min);
}

/// 結果の評価コメント。
String colorMakerRating(double deltaE) {
  if (deltaE < 2) return '調色師級。ほぼ見分けがつきません';
  if (deltaE < 5) return 'かなり正確。並べてやっと分かる差です';
  if (deltaE < 10) return '良好。雰囲気はばっちり掴んでいます';
  if (deltaE < 20) return 'のびしろあり。また挑戦してみよう';
  return '大胆な色づかい。それも味です';
}

import 'dart:ui';

/// ズーム型色見本の状態。
///
/// RGB 立方体を素直に切る (案A)。各段階で各軸を [divisions] 分割し、
/// divisions^3 個の小立方体をタイルとして表示する。
/// 基本形は 4 分割 = 64 タイル × 4 段階 (64^4 = 2^24)。
class ColorZoomState {
  ColorZoomState({this.divisions = 4})
      : assert(
          divisions == 2 || divisions == 4 || divisions == 16,
          '256 を割り切れる分割数のみ (2=8段, 4=4段, 16=2段)',
        );

  final int divisions;

  /// 選択してきた各段階のタイル番号 (r, g, b の分割インデックス)。
  final List<(int, int, int)> path = [];

  /// 現在の小立方体の原点。
  (int, int, int) get origin {
    var r = 0, g = 0, b = 0;
    var size = 256;
    for (final (ri, gi, bi) in path) {
      final step = size ~/ divisions;
      r += ri * step;
      g += gi * step;
      b += bi * step;
      size = step;
    }
    return (r, g, b);
  }

  /// 現在の小立方体の一辺 (256 → 64 → 16 → 4 → 1)。
  int get size {
    var s = 256;
    for (var i = 0; i < path.length; i++) {
      s ~/= divisions;
    }
    return s;
  }

  int get depth => path.length;

  int get maxDepth {
    var s = 256;
    var d = 0;
    while (s > 1) {
      s ~/= divisions;
      d++;
    }
    return d;
  }

  /// 1 タイルが含む色数。
  int get colorsPerTile {
    final step = size ~/ divisions;
    return step * step * step;
  }

  /// 到達した最終色 (size == 1 のときのみ)。
  Color? get finalColor {
    if (size != 1) return null;
    final (r, g, b) = origin;
    return Color.fromARGB(255, r, g, b);
  }

  /// タイル (ri, gi, bi) の代表色 (小立方体の中心)。
  Color tileColor(int ri, int gi, int bi) {
    final (r, g, b) = origin;
    final step = size ~/ divisions;
    return Color.fromARGB(
      255,
      r + ri * step + step ~/ 2,
      g + gi * step + step ~/ 2,
      b + bi * step + step ~/ 2,
    );
  }

  /// 途中経過 (パンくず) の代表色。
  Color crumbColor(int index) {
    var r = 0, g = 0, b = 0;
    var size = 256;
    for (var i = 0; i <= index; i++) {
      final step = size ~/ divisions;
      final (ri, gi, bi) = path[i];
      r += ri * step;
      g += gi * step;
      b += bi * step;
      size = step;
    }
    final half = size ~/ 2;
    return Color.fromARGB(255, r + half, g + half, b + half);
  }

  void select(int ri, int gi, int bi) {
    if (size == 1) return;
    path.add((ri, gi, bi));
  }

  void back() {
    if (path.isNotEmpty) path.removeLast();
  }

  void reset() => path.clear();
}

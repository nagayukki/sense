import 'dart:ui';

import 'ciede2000.dart';
import 'lab.dart';
import 'named_colors.dart';

class NearestName {
  const NearestName(this.color, this.deltaE);

  final NamedColor color;

  /// 対象色との CIEDE2000 色差。
  final double deltaE;
}

List<Lab>? _labs;

/// [color] に近い色名を色差の昇順で [count] 件返す。
List<NearestName> nearestNames(Color color, {int count = 3}) {
  final labs = _labs ??= [
    for (final n in namedColors) srgbToLab(n.r, n.g, n.b),
  ];
  final target = srgbToLab(
    (color.r * 255).round(),
    (color.g * 255).round(),
    (color.b * 255).round(),
  );
  final results = [
    for (var i = 0; i < namedColors.length; i++)
      NearestName(namedColors[i], ciede2000(target, labs[i])),
  ]..sort((a, b) => a.deltaE.compareTo(b.deltaE));
  return results.take(count).toList();
}

/// RGB の小立方体 (origin から一辺 size) に含まれる色名。
List<NamedColor> namedColorsInCube({
  required int r,
  required int g,
  required int b,
  required int size,
}) =>
    [
      for (final n in namedColors)
        if (n.r >= r &&
            n.r < r + size &&
            n.g >= g &&
            n.g < g + size &&
            n.b >= b &&
            n.b < b + size)
          n,
    ];

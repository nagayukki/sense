import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sense/core/color/named_colors.dart';
import 'package:sense/core/color/nearest_name.dart';

void main() {
  test('辞書は JIS + CSS を含む', () {
    expect(namedColors.where((n) => n.source == NamedColorSource.jis).length,
        267);
    expect(namedColors.where((n) => n.source == NamedColorSource.css).length,
        148);
  });

  test('完全一致は色差 0 で先頭に来る', () {
    final sumi = namedColors.firstWhere((n) => n.name == '墨');
    final result =
        nearestNames(Color.fromARGB(255, sumi.r, sumi.g, sumi.b)).first;
    expect(result.color.name, '墨');
    expect(result.deltaE, closeTo(0, 1e-9));
  });

  test('昇順で返る', () {
    final results = nearestNames(const Color(0xFF3A7BD5), count: 5);
    for (var i = 1; i < results.length; i++) {
      expect(results[i].deltaE, greaterThanOrEqualTo(results[i - 1].deltaE));
    }
  });
}

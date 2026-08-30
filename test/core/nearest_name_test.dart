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

  test('namedColorsInCube は範囲内の色名だけ返す', () {
    final all = namedColorsInCube(r: 0, g: 0, b: 0, size: 256);
    expect(all.length, namedColors.length);
    final sumi = namedColors.firstWhere((n) => n.name == '墨'); // 0x313131
    final hit = namedColorsInCube(r: 48, g: 48, b: 48, size: 1);
    expect(hit, isNot(contains(sumi))); // 0x31 = 49 は範囲外
    final hit2 = namedColorsInCube(r: 48, g: 48, b: 48, size: 2);
    expect(hit2, contains(sumi)); // 48-49 に含まれる
    expect(namedColorsInCube(r: 200, g: 0, b: 200, size: 1), isEmpty);
  });

  test('昇順で返る', () {
    final results = nearestNames(const Color(0xFF3A7BD5), count: 5);
    for (var i = 1; i < results.length; i++) {
      expect(results[i].deltaE, greaterThanOrEqualTo(results[i - 1].deltaE));
    }
  });
}

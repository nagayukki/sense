import 'package:flutter_test/flutter_test.dart';
import 'package:sense/core/color/ciede2000.dart';
import 'package:sense/core/color/lab.dart';

void main() {
  group('ciede2000', () {
    // Sharma et al. (2005) のテストベクタ
    test('標準テストベクタに一致する', () {
      const ref = Lab(50.0, 0.0, -82.7485);
      expect(ciede2000(const Lab(50.0, 2.6772, -79.7751), ref),
          closeTo(2.0425, 0.0001));
      expect(ciede2000(const Lab(50.0, 3.1571, -77.2803), ref),
          closeTo(2.8615, 0.0001));
      expect(ciede2000(const Lab(50.0, 2.8361, -74.0200), ref),
          closeTo(3.4412, 0.0001));
    });

    test('同一色は 0、引数の順序に依存しない', () {
      const a = Lab(50.0, 2.5, 0.0);
      const b = Lab(61.0, -5.0, 29.0);
      expect(ciede2000(a, a), 0);
      expect(ciede2000(a, b), closeTo(ciede2000(b, a), 1e-9));
    });
  });

  group('srgbToLab / labToSrgb', () {
    test('白と黒', () {
      final white = srgbToLab(255, 255, 255);
      expect(white.l, closeTo(100, 0.01));
      expect(white.a, closeTo(0, 0.01));
      expect(white.b, closeTo(0, 0.01));
      expect(srgbToLab(0, 0, 0).l, closeTo(0, 0.01));
    });

    test('往復で元の色に戻る', () {
      for (final rgb in [(12, 34, 56), (200, 100, 50), (128, 128, 128)]) {
        final lab = srgbToLab(rgb.$1, rgb.$2, rgb.$3);
        final back = labToSrgb(lab)!;
        expect((back.r * 255).round(), rgb.$1);
        expect((back.g * 255).round(), rgb.$2);
        expect((back.b * 255).round(), rgb.$3);
      }
    });

    test('色域外は null', () {
      expect(labToSrgb(const Lab(50, 120, -120)), isNull);
    });
  });
}

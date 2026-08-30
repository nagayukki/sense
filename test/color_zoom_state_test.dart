import 'package:flutter_test/flutter_test.dart';
import 'package:sense/features/color_zoom/color_zoom_state.dart';

void main() {
  group('ColorZoomState', () {
    test('4 段階で 1 色に到達する', () {
      final state = ColorZoomState();
      expect(state.maxDepth, 4);
      for (var i = 0; i < 4; i++) {
        expect(state.finalColor, isNull);
        state.select(0, 0, 0);
      }
      expect(state.size, 1);
      expect(state.finalColor, isNotNull);
    });

    test('最終色は選択したタイルの原点に一致する', () {
      final state = ColorZoomState();
      state.select(3, 3, 3); // origin 192
      state.select(3, 3, 3); // +48 = 240
      state.select(3, 3, 3); // +12 = 252
      state.select(3, 3, 3); // +3  = 255
      final c = state.finalColor!;
      expect((c.r * 255).round(), 255);
      expect((c.g * 255).round(), 255);
      expect((c.b * 255).round(), 255);
    });

    test('戻ると 1 段階上がる', () {
      final state = ColorZoomState();
      state.select(1, 2, 3);
      state.select(0, 0, 0);
      state.back();
      expect(state.depth, 1);
      expect(state.size, 64);
    });

    test('分割数 2 は 8 段階、16 は 2 段階', () {
      expect(ColorZoomState(divisions: 2).maxDepth, 8);
      expect(ColorZoomState(divisions: 16).maxDepth, 2);
    });
  });
}

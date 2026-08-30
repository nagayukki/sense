import 'package:flutter_test/flutter_test.dart';
import 'package:sense/features/color_zoom/color_zoom_state.dart';
import 'package:sense/main.dart';

void main() {
  testWidgets('ホームに機能一覧が表示される', (tester) async {
    await tester.pumpWidget(const SenseApp());
    expect(find.text('色見本'), findsOneWidget);
    expect(find.text('色のトレーニング'), findsOneWidget);
    expect(find.text('角度のトレーニング'), findsOneWidget);
  });

  testWidgets('色見本をタップするとズーム画面が開く', (tester) async {
    await tester.pumpWidget(const SenseApp());
    await tester.tap(find.text('色見本'));
    await tester.pumpAndSettle();
    expect(find.text('深さ 0 / 4'), findsOneWidget);
  });

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
  });
}

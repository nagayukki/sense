import 'package:flutter_test/flutter_test.dart';
import 'package:sense/core/training/staircase.dart';

void main() {
  group('Staircase', () {
    Staircase make() =>
        Staircase(start: 16, min: 0.2, max: 40, trialCount: 4);

    test('正解で狭まり不正解で広がる', () {
      final s = make();
      s.record(presented: 16, correct: true);
      expect(s.value, closeTo(16 * 0.7, 1e-9));
      s.record(presented: s.value, correct: false);
      expect(s.value, closeTo(16 * 0.7 * 1.6, 1e-9));
    });

    test('クランプされる', () {
      final s = Staircase(start: 0.25, min: 0.2, max: 40, trialCount: 10);
      s.record(presented: 0.25, correct: true);
      expect(s.value, 0.2);
    });

    test('終了後は記録できず閾値が出る', () {
      final s = make();
      for (var i = 0; i < 4; i++) {
        s.record(presented: s.value, correct: true);
      }
      expect(s.isFinished, isTrue);
      expect(() => s.record(presented: 1, correct: true), throwsStateError);
      expect(s.threshold(), isNot(isNaN));
    });

    test('閾値は終盤の幾何平均', () {
      final s = Staircase(start: 4, min: 0.1, max: 40, trialCount: 3);
      s.record(presented: 4, correct: true);
      s.record(presented: 2, correct: true);
      s.record(presented: 8, correct: true);
      // 幾何平均(4,2,8) = 4
      expect(s.threshold(), closeTo(4, 1e-9));
    });
  });
}

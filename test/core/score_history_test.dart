import 'package:flutter_test/flutter_test.dart';
import 'package:sense/core/history/score_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('encode/decode の往復', () {
    final records = [
      ScoreRecord(at: DateTime.fromMillisecondsSinceEpoch(1000), value: 2.5),
      ScoreRecord(at: DateTime.fromMillisecondsSinceEpoch(2000), value: 1.75),
    ];
    final decoded = decodeRecords(encodeRecords(records));
    expect(decoded.length, 2);
    expect(decoded[0].at.millisecondsSinceEpoch, 1000);
    expect(decoded[1].value, 1.75);
  });

  test('bestOf は方向に従う', () {
    final records = [
      ScoreRecord(at: DateTime.fromMillisecondsSinceEpoch(0), value: 5),
      ScoreRecord(at: DateTime.fromMillisecondsSinceEpoch(1), value: 2),
      ScoreRecord(at: DateTime.fromMillisecondsSinceEpoch(2), value: 8),
    ];
    expect(bestOf(records, higherIsBetter: false), 2);
    expect(bestOf(records, higherIsBetter: true), 8);
    expect(bestOf([], higherIsBetter: true), isNull);
  });

  test('add と list (mock storage)', () async {
    SharedPreferences.setMockInitialValues({});
    await ScoreHistory.instance.add(GameId.colorOdd, 3.2);
    await ScoreHistory.instance.add(GameId.colorOdd, 2.1);
    await ScoreHistory.instance.add(GameId.colorOdd, double.nan); // 無視
    final list = await ScoreHistory.instance.list(GameId.colorOdd);
    expect(list.length, 2);
    expect(list.last.value, 2.1);
    expect(await ScoreHistory.instance.list(GameId.pitch), isEmpty);
  });

  test('全あそびにメタ定義がある', () {
    final ids = gameMetas.map((m) => m.id).toSet();
    expect(ids.length, gameMetas.length); // 重複なし
    expect(ids, containsAll([GameId.colorOdd, GameId.rhythmKeep]));
  });
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// あそびの識別子。
abstract final class GameId {
  static const colorOdd = 'color_odd';
  static const colorMemory = 'color_memory';
  static const colorMaker = 'color_maker';
  static const length = 'length';
  static const area = 'area';
  static const angle = 'angle';
  static const pitch = 'pitch';
  static const noteQuiz = 'note_quiz';
  static const tempo = 'tempo';
  static const rhythmKeep = 'rhythm_keep';
  static const time = 'time';
  static const numerosity = 'numerosity';
}

/// あそびごとのスコア表示定義。
class GameMeta {
  const GameMeta(this.id, this.label, this.unit,
      {required this.higherIsBetter});

  final String id;
  final String label;
  final String unit;

  /// true なら大きいほど良い記録 (正解数など)。false は閾値・ズレ系。
  final bool higherIsBetter;

  String format(double v) =>
      higherIsBetter ? '${v.round()} $unit' : '${v.toStringAsFixed(1)} $unit';
}

const gameMetas = [
  GameMeta(GameId.colorOdd, '色くらべ', 'ΔE', higherIsBetter: false),
  GameMeta(GameId.colorMemory, '色おぼえ', 'ΔE', higherIsBetter: false),
  GameMeta(GameId.colorMaker, '色をつくる', 'ΔE', higherIsBetter: false),
  GameMeta(GameId.length, '長さくらべ', '%', higherIsBetter: false),
  GameMeta(GameId.area, '面積くらべ', '%', higherIsBetter: false),
  GameMeta(GameId.angle, '角度くらべ', '°', higherIsBetter: false),
  GameMeta(GameId.pitch, '音の高さくらべ', 'セント', higherIsBetter: false),
  GameMeta(GameId.noteQuiz, '音名当て', '問正解', higherIsBetter: true),
  GameMeta(GameId.tempo, 'テンポくらべ', '%', higherIsBetter: false),
  GameMeta(GameId.rhythmKeep, 'リズムキープ', '%', higherIsBetter: false),
  GameMeta(GameId.time, '時間くらべ', '%', higherIsBetter: false),
  GameMeta(GameId.numerosity, 'かずくらべ', '%', higherIsBetter: false),
];

/// 1件の記録。
class ScoreRecord {
  const ScoreRecord({required this.at, required this.value});

  final DateTime at;
  final double value;
}

/// 記録の JSON 変換 (純粋関数、テスト対象)。
String encodeRecords(List<ScoreRecord> records) => jsonEncode([
      for (final r in records)
        {'t': r.at.millisecondsSinceEpoch, 'v': r.value},
    ]);

List<ScoreRecord> decodeRecords(String json) {
  final list = jsonDecode(json) as List<dynamic>;
  return [
    for (final e in list.cast<Map<String, dynamic>>())
      ScoreRecord(
        at: DateTime.fromMillisecondsSinceEpoch(e['t'] as int),
        value: (e['v'] as num).toDouble(),
      ),
  ];
}

/// ベスト値 (higherIsBetter に従う)。
double? bestOf(List<ScoreRecord> records, {required bool higherIsBetter}) {
  if (records.isEmpty) return null;
  var best = records.first.value;
  for (final r in records) {
    if (higherIsBetter ? r.value > best : r.value < best) best = r.value;
  }
  return best;
}

/// スコア履歴の保存・読み出し。
class ScoreHistory {
  ScoreHistory._();

  static final instance = ScoreHistory._();

  /// 1あそびあたりの保持件数。
  static const maxRecords = 200;

  static String _key(String gameId) => 'history.$gameId';

  Future<void> add(String gameId, double value) async {
    if (value.isNaN) return;
    final prefs = await SharedPreferences.getInstance();
    final records = _load(prefs, gameId)
      ..add(ScoreRecord(at: DateTime.now(), value: value));
    final trimmed = records.length > maxRecords
        ? records.sublist(records.length - maxRecords)
        : records;
    await prefs.setString(_key(gameId), encodeRecords(trimmed));
  }

  Future<List<ScoreRecord>> list(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    return _load(prefs, gameId);
  }

  List<ScoreRecord> _load(SharedPreferences prefs, String gameId) {
    final json = prefs.getString(_key(gameId));
    if (json == null) return [];
    try {
      return decodeRecords(json);
    } on FormatException {
      return [];
    }
  }
}

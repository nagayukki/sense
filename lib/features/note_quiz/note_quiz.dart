import 'dart:math';

import '../../core/audio/tone_synth.dart';

/// ピッチクラス (オクターブを無視した音名) 0=ド 〜 11=シ。
const noteNames = [
  'ド', 'ド♯', 'レ', 'レ♯', 'ミ', 'ファ',
  'ファ♯', 'ソ', 'ソ♯', 'ラ', 'ラ♯', 'シ',
];

/// MIDI ノート番号 → 周波数 (A4 = 440Hz, 平均律)。
double midiToFreq(int midi) => 440 * pow(2, (midi - 69) / 12).toDouble();

/// 基準音: A4 = 440Hz (ラ)。
const referenceMidi = 69;

/// 音名当ての1問。
class NoteQuizQuestion {
  const NoteQuizQuestion({required this.midi, required this.timbre});

  final int midi;
  final Timbre timbre;

  /// 正解のピッチクラス (0-11)。
  int get pitchClass => midi % 12;

  String get answerName => noteNames[pitchClass];

  double get frequency => midiToFreq(midi);
}

/// 1 セッション。階段法ではなく正解数のスコア形式。
class NoteQuizSession {
  NoteQuizSession({this.questionCount = 12, Random? random})
      : _random = random ?? Random() {
    _next();
  }

  final int questionCount;
  final Random _random;

  NoteQuizQuestion? _question;
  int? _lastMidi;
  final List<({int midi, int chosen, bool correct})> results = [];

  NoteQuizQuestion? get question => _question;
  int get answered => results.length;
  bool get isFinished => results.length >= questionCount;
  int get correctCount => results.where((r) => r.correct).length;

  void _next() {
    if (isFinished) {
      _question = null;
      return;
    }
    // C3 (48) - B5 (83)。直前と同じ音は避ける
    int midi;
    do {
      midi = 48 + _random.nextInt(36);
    } while (midi == _lastMidi);
    _lastMidi = midi;
    // 音名当てはピアノ風を基本に、たまに他の音色
    final timbre = _random.nextInt(4) == 0
        ? Timbre.values[_random.nextInt(Timbre.values.length)]
        : Timbre.piano;
    _question = NoteQuizQuestion(midi: midi, timbre: timbre);
  }

  /// ピッチクラス (0-11) で回答。正解なら true。
  bool answer(int pitchClass) {
    final q = _question;
    if (q == null) throw StateError('セッションは終了している');
    final correct = pitchClass == q.pitchClass;
    results.add((midi: q.midi, chosen: pitchClass, correct: correct));
    _next();
    return correct;
  }
}

/// スコアの評価コメント。
String noteQuizRating(int correct, int total) {
  final rate = correct / total;
  if (rate >= 0.95) return '絶対音感の持ち主かもしれません';
  if (rate >= 0.7) return 'かなり正確。基準音の記憶が効いています';
  if (rate >= 0.4) return '育ってきています。基準のラ (440Hz) と聞き比べてみよう';
  if (rate > 1 / 12) return 'まずは基準のラを何度も聞いてみよう';
  return '当てずっぽうと同じくらい。伸びしろしかありません';
}

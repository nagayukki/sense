import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sense/core/audio/tone_synth.dart';
import 'package:sense/features/note_quiz/note_quiz.dart';

void main() {
  test('MIDI → 周波数 (平均律)', () {
    expect(midiToFreq(69), closeTo(440, 1e-9)); // A4
    expect(midiToFreq(60), closeTo(261.626, 0.01)); // C4
    expect(midiToFreq(81), closeTo(880, 1e-6)); // A5
  });

  test('ピッチクラスと音名', () {
    const q = NoteQuizQuestion(midi: 61, timbre: Timbre.piano);
    expect(q.pitchClass, 1);
    expect(q.answerName, 'ド♯');
  });

  test('セッション: 同じ音が連続しない・完走できる', () {
    final s = NoteQuizSession(questionCount: 20, random: Random(51));
    int? prev;
    while (!s.isFinished) {
      final midi = s.question!.midi;
      expect(midi, isNot(prev));
      expect(midi, inInclusiveRange(48, 83));
      prev = midi;
      s.answer(s.question!.pitchClass);
    }
    expect(s.correctCount, 20);
    expect(s.question, isNull);
  });
}

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/audio/tone_synth.dart';
import '../../core/history/score_history.dart';
import '../common/training_widgets.dart';
import 'note_quiz.dart';

/// 音名当て (Issue #7)。絶対音感的クイズ + 基準音 (ラ 440Hz)。
class NoteQuizScreen extends StatefulWidget {
  const NoteQuizScreen({super.key});

  @override
  State<NoteQuizScreen> createState() => _NoteQuizScreenState();
}

class _NoteQuizScreenState extends State<NoteQuizScreen> {
  late NoteQuizSession session;
  final player = AudioPlayer();
  final refPlayer = AudioPlayer();
  bool? lastCorrect;
  String? lastAnswerName;
  int referenceUses = 0;

  @override
  void initState() {
    super.initState();
    session = NoteQuizSession();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playQuestion());
  }

  @override
  void dispose() {
    player.dispose();
    refPlayer.dispose();
    super.dispose();
  }

  void _restart() {
    setState(() {
      session = NoteQuizSession();
      lastCorrect = null;
      lastAnswerName = null;
      referenceUses = 0;
    });
    _playQuestion();
  }

  Future<void> _playQuestion() async {
    final q = session.question;
    if (q == null) return;
    await player.stop();
    await player.play(BytesSource(toneWav(q.frequency, q.timbre)));
  }

  Future<void> _playReference() async {
    setState(() => referenceUses++);
    await refPlayer.stop();
    await refPlayer
        .play(BytesSource(toneWav(midiToFreq(referenceMidi), Timbre.piano)));
  }

  void _answer(int pitchClass) {
    final q = session.question;
    if (q == null) return;
    setState(() {
      lastAnswerName = q.answerName;
      lastCorrect = session.answer(pitchClass);
    });
    if (session.isFinished) {
      ScoreHistory.instance
          .add(GameId.noteQuiz, session.correctCount.toDouble());
    }
    _playQuestion();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = session.question;
    return Scaffold(
      appBar: AppBar(title: const Text('音名当て')),
      body: SafeArea(
        child: q == null
            ? TrainingResultView(
                title: '正解数',
                valueText: '${session.correctCount} / ${session.questionCount}',
                rating:
                    '${noteQuizRating(session.correctCount, session.questionCount)}'
                    '${referenceUses > 0 ? '\n(基準音を $referenceUses 回使用)' : ''}',
                correctCount: session.correctCount,
                trialCount: session.questionCount,
                onRestart: _restart,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TrainingProgressHeader(
                    answered: session.answered,
                    trialCount: session.questionCount,
                    lastCorrect: lastCorrect,
                  ),
                  if (lastCorrect != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        lastCorrect!
                            ? '正解! ($lastAnswerName)'
                            : '正解は $lastAnswerName でした',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.music_note,
                              size: 56, color: theme.colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(q.timbre.label,
                              style: theme.textTheme.titleSmall),
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            onPressed: _playQuestion,
                            icon: const Icon(Icons.replay, size: 18),
                            label: const Text('もう一度聞く'),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _playReference,
                            icon: const Icon(Icons.tune, size: 18),
                            label: const Text('基準音 ラ (440Hz) を聞く'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.6,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (var pc = 0; pc < 12; pc++)
                          FilledButton.tonal(
                            onPressed: () => _answer(pc),
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(noteNames[pc]),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

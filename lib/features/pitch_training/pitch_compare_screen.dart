import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/audio/tone_synth.dart';
import '../common/training_widgets.dart';
import 'pitch_compare.dart';

/// 音の高さのトレーニング: どちらが高いか (Issue #6)。
class PitchCompareScreen extends StatefulWidget {
  const PitchCompareScreen({super.key});

  @override
  State<PitchCompareScreen> createState() => _PitchCompareScreenState();
}

class _PitchCompareScreenState extends State<PitchCompareScreen> {
  late PitchSession session;
  final player = AudioPlayer();
  bool? lastCorrect;
  String? playing; // 'A' | 'B' | null
  int _playToken = 0;

  @override
  void initState() {
    super.initState();
    session = PitchSession();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playBoth());
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _restart() {
    setState(() {
      session = PitchSession();
      lastCorrect = null;
    });
    _playBoth();
  }

  Future<void> _play(String which) async {
    final trial = session.trial;
    if (trial == null) return;
    final token = ++_playToken;
    final freq = which == 'A' ? trial.freqA : trial.freqB;
    final timbre = which == 'A' ? trial.timbreA : trial.timbreB;
    setState(() => playing = which);
    await player.stop();
    await player.play(BytesSource(toneWav(freq, timbre)));
    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (mounted && _playToken == token) setState(() => playing = null);
  }

  Future<void> _playBoth() async {
    await _play('A');
    if (!mounted || session.trial == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await _play('B');
  }

  void _answer(bool choseA) {
    setState(() {
      lastCorrect = session.answer(choseA: choseA);
    });
    _playBoth();
  }

  @override
  Widget build(BuildContext context) {
    final trial = session.trial;
    return Scaffold(
      appBar: AppBar(title: const Text('音の高さのトレーニング')),
      body: SafeArea(
        child: trial == null
            ? TrainingResultView(
                title: '見分けられた最小の差',
                valueText: '${session.threshold.toStringAsFixed(1)} セント',
                rating: pitchRating(session.threshold),
                correctCount: session.correctCount,
                trialCount: session.trialCount,
                onRestart: _restart,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TrainingProgressHeader(
                    answered: session.answered,
                    trialCount: session.trialCount,
                    lastCorrect: lastCorrect,
                  ),
                  Expanded(
                    child: _ToneCard(
                      label: 'A',
                      timbre: trial.timbreA,
                      isPlaying: playing == 'A',
                      onTap: () => _answer(true),
                      onReplay: () => _play('A'),
                    ),
                  ),
                  Expanded(
                    child: _ToneCard(
                      label: 'B',
                      timbre: trial.timbreB,
                      isPlaying: playing == 'B',
                      onTap: () => _answer(false),
                      onReplay: () => _play('B'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '高い方をタップ (音色が違っても高さで)',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ToneCard extends StatelessWidget {
  const _ToneCard({
    required this.label,
    required this.timbre,
    required this.isPlaying,
    required this.onTap,
    required this.onReplay,
  });

  final String label;
  final Timbre timbre;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceCard(
      label: label,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPlaying ? Icons.graphic_eq : Icons.music_note_outlined,
              size: 40,
              color: isPlaying
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(timbre.label, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: onReplay,
              icon: const Icon(Icons.replay, size: 18),
              label: const Text('もう一度聞く'),
            ),
          ],
        ),
      ),
    );
  }
}

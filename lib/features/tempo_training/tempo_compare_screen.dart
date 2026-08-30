import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/audio/click_sequence.dart';
import '../common/training_widgets.dart';
import 'tempo_compare.dart';

/// テンポくらべ: どちらが速いか (Issue #11)。
class TempoCompareScreen extends StatefulWidget {
  const TempoCompareScreen({super.key});

  @override
  State<TempoCompareScreen> createState() => _TempoCompareScreenState();
}

class _TempoCompareScreenState extends State<TempoCompareScreen> {
  late TempoSession session;
  final player = AudioPlayer();
  bool? lastCorrect;
  String? playing;
  int _token = 0;

  @override
  void initState() {
    super.initState();
    session = TempoSession();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playBoth());
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _restart() {
    setState(() {
      session = TempoSession();
      lastCorrect = null;
    });
    _playBoth();
  }

  Future<void> _play(String which) async {
    final trial = session.trial;
    if (trial == null) return;
    final token = ++_token;
    final interval = which == 'A' ? trial.intervalA : trial.intervalB;
    setState(() => playing = which);
    await player.stop();
    await player.play(BytesSource(
        clickSequenceWav(interval: interval, count: trial.clickCount)));
    final total = interval * (trial.clickCount - 1) +
        const Duration(milliseconds: 200);
    await Future<void>.delayed(total);
    if (mounted && _token == token) setState(() => playing = null);
  }

  Future<void> _playBoth() async {
    await _play('A');
    if (!mounted || session.trial == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 300));
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
      appBar: AppBar(title: const Text('テンポくらべ')),
      body: SafeArea(
        child: trial == null
            ? TrainingResultView(
                title: '見分けられた最小の差',
                valueText: '${session.threshold.toStringAsFixed(1)} %',
                rating: tempoRating(session.threshold),
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
                    child: _ClicksCard(
                      label: 'A',
                      isPlaying: playing == 'A',
                      onTap: () => _answer(true),
                      onReplay: () => _play('A'),
                    ),
                  ),
                  Expanded(
                    child: _ClicksCard(
                      label: 'B',
                      isPlaying: playing == 'B',
                      onTap: () => _answer(false),
                      onReplay: () => _play('B'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '速い方をタップ',
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

class _ClicksCard extends StatelessWidget {
  const _ClicksCard({
    required this.label,
    required this.isPlaying,
    required this.onTap,
    required this.onReplay,
  });

  final String label;
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
              isPlaying ? Icons.graphic_eq : Icons.speed_outlined,
              size: 40,
              color: isPlaying
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
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

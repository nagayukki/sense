import 'package:flutter/material.dart';

import '../../core/history/score_history.dart';
import '../common/training_widgets.dart';
import 'time_compare.dart';

/// 時間くらべ: どちらが長かったか (Issue #8)。
class TimeCompareScreen extends StatefulWidget {
  const TimeCompareScreen({super.key});

  @override
  State<TimeCompareScreen> createState() => _TimeCompareScreenState();
}

class _TimeCompareScreenState extends State<TimeCompareScreen> {
  late TimeSession session;
  bool? lastCorrect;
  String? showing; // 'A' | 'B' | null
  bool played = false;
  int _token = 0;

  @override
  void initState() {
    super.initState();
    session = TimeSession();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playBoth());
  }

  void _restart() {
    setState(() {
      session = TimeSession();
      lastCorrect = null;
      played = false;
    });
    _playBoth();
  }

  Future<void> _playBoth() async {
    final trial = session.trial;
    if (trial == null) return;
    final token = ++_token;

    Future<void> show(String which, Duration d) async {
      if (!mounted || _token != token) return;
      setState(() => showing = which);
      await Future<void>.delayed(d);
      if (!mounted || _token != token) return;
      setState(() => showing = null);
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));
    await show('A', trial.durationA);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await show('B', trial.durationB);
    if (mounted && _token == token) setState(() => played = true);
  }

  void _answer(bool choseA) {
    if (!played) return; // 提示が終わるまで回答させない
    setState(() {
      lastCorrect = session.answer(choseA: choseA);
      played = false;
    });
    if (session.isFinished) {
      ScoreHistory.instance.add(GameId.time, session.threshold);
    }
    _playBoth();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trial = session.trial;
    return Scaffold(
      appBar: AppBar(title: const Text('時間くらべ')),
      body: SafeArea(
        child: trial == null
            ? TrainingResultView(
                title: '見分けられた最小の差',
                valueText: '${session.threshold.toStringAsFixed(1)} %',
                rating: timeRating(session.threshold),
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
                    child: _IntervalCard(
                      label: 'A',
                      active: showing == 'A',
                      enabled: played,
                      onTap: () => _answer(true),
                    ),
                  ),
                  Expanded(
                    child: _IntervalCard(
                      label: 'B',
                      active: showing == 'B',
                      enabled: played,
                      onTap: () => _answer(false),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      played ? '長く点灯していた方をタップ' : '点灯する時間をよく見て…',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextButton.icon(
                      onPressed: played ? _playBoth : null,
                      icon: const Icon(Icons.replay, size: 18),
                      label: const Text('もう一度見る'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _IntervalCard extends StatelessWidget {
  const _IntervalCard({
    required this.label,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceCard(
      label: label,
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}

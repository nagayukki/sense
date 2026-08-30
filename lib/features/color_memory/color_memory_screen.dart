import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/history/score_history.dart';
import '../common/training_widgets.dart';
import 'color_memory.dart';

enum _Phase { showing, waiting, choosing }

/// 色おぼえ: さっきの色はどれ? (Issue #13)。
class ColorMemoryScreen extends StatefulWidget {
  const ColorMemoryScreen({super.key});

  @override
  State<ColorMemoryScreen> createState() => _ColorMemoryScreenState();
}

class _ColorMemoryScreenState extends State<ColorMemoryScreen> {
  late ColorMemorySession session;
  bool? lastCorrect;
  _Phase phase = _Phase.showing;
  int _token = 0;

  @override
  void initState() {
    super.initState();
    session = ColorMemorySession();
    _startTrial();
  }

  void _restart() {
    setState(() {
      session = ColorMemorySession();
      lastCorrect = null;
    });
    _startTrial();
  }

  Future<void> _startTrial() async {
    if (session.trial == null) return;
    final token = ++_token;
    setState(() => phase = _Phase.showing);
    await Future<void>.delayed(ColorMemorySession.showDuration);
    if (!mounted || _token != token) return;
    setState(() => phase = _Phase.waiting);
    await Future<void>.delayed(ColorMemorySession.delayDuration);
    if (!mounted || _token != token) return;
    setState(() => phase = _Phase.choosing);
  }

  void _answer(int index) {
    if (phase != _Phase.choosing) return;
    setState(() {
      lastCorrect = session.answer(index);
    });
    if (session.isFinished) {
      ScoreHistory.instance.add(GameId.colorMemory, session.threshold);
    }
    _startTrial();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trial = session.trial;
    return Scaffold(
      appBar: AppBar(title: const Text('色おぼえ')),
      body: SafeArea(
        child: trial == null
            ? TrainingResultView(
                title: '覚えられた最小の差',
                valueText: 'ΔE ${session.threshold.toStringAsFixed(1)}',
                rating: colorMemoryRating(session.threshold),
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: switch (phase) {
                        _Phase.showing => Container(
                            decoration: BoxDecoration(
                              color: trial.target,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        _Phase.waiting => Center(
                            child: Icon(Icons.hourglass_empty,
                                size: 48,
                                color: theme.colorScheme.outlineVariant),
                          ),
                        _Phase.choosing => GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.4,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              for (var i = 0; i < trial.choices.length; i++)
                                GestureDetector(
                                  onTap: () => _answer(i),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: trial.choices[i],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      switch (phase) {
                        _Phase.showing => 'この色をおぼえて…',
                        _Phase.waiting => 'ちょっと待って…',
                        _Phase.choosing => 'さっきの色はどれ?',
                      },
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

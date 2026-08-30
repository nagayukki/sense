import 'package:flutter/material.dart';

import '../common/training_widgets.dart';
import 'odd_one_out.dart';

/// 色のトレーニング: 1つだけ違う色を探す (Issue #1)。
class OddOneOutScreen extends StatefulWidget {
  const OddOneOutScreen({super.key});

  @override
  State<OddOneOutScreen> createState() => _OddOneOutScreenState();
}

class _OddOneOutScreenState extends State<OddOneOutScreen> {
  late OddOneOutSession session;
  bool? lastCorrect;

  @override
  void initState() {
    super.initState();
    session = OddOneOutSession();
  }

  void _restart() {
    setState(() {
      session = OddOneOutSession();
      lastCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trial = session.trial;
    return Scaffold(
      appBar: AppBar(title: const Text('色のトレーニング')),
      body: SafeArea(
        child: trial == null
            ? TrainingResultView(
                title: 'あなたの識別閾値',
                valueText: 'ΔE ${session.threshold.toStringAsFixed(1)}',
                rating: thresholdRating(session.threshold),
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
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GridView.count(
                            crossAxisCount: 4,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              for (var i = 0; i < session.tileCount; i++)
                                GestureDetector(
                                  onTap: () => setState(() {
                                    lastCorrect = session.answer(i);
                                  }),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: i == trial.oddIndex
                                          ? trial.oddColor
                                          : trial.baseColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      '1つだけ違う色をタップ',
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


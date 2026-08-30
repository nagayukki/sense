import 'package:flutter/material.dart';

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
            ? _ResultView(session: session, onRestart: _restart)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        Text('${session.answered + 1} / ${session.trialCount}',
                            style: theme.textTheme.titleSmall),
                        const Spacer(),
                        if (lastCorrect != null)
                          Icon(
                            lastCorrect! ? Icons.check_circle : Icons.cancel,
                            size: 20,
                            color: lastCorrect!
                                ? Colors.green
                                : theme.colorScheme.error,
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LinearProgressIndicator(
                      value: session.answered / session.trialCount,
                    ),
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

class _ResultView extends StatelessWidget {
  const _ResultView({required this.session, required this.onRestart});

  final OddOneOutSession session;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final threshold = session.threshold;
    final correctCount = session.correctCount;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('あなたの識別閾値',
              textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'ΔE ${threshold.toStringAsFixed(1)}',
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            thresholdRating(threshold),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '正解 $correctCount / ${session.trialCount}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh),
            label: const Text('もう一度'),
          ),
        ],
      ),
    );
  }
}

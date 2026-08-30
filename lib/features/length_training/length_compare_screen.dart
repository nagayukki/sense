import 'dart:math';

import 'package:flutter/material.dart';

import 'length_compare.dart';

/// 長さのトレーニング: どちらが長いか (Issue #2)。
class LengthCompareScreen extends StatefulWidget {
  const LengthCompareScreen({super.key});

  @override
  State<LengthCompareScreen> createState() => _LengthCompareScreenState();
}

class _LengthCompareScreenState extends State<LengthCompareScreen> {
  late LengthSession session;
  bool? lastCorrect;

  @override
  void initState() {
    super.initState();
    session = LengthSession();
  }

  void _restart() {
    setState(() {
      session = LengthSession();
      lastCorrect = null;
    });
  }

  void _answer(bool choseA) {
    setState(() {
      lastCorrect = session.answer(choseA: choseA);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trial = session.trial;
    return Scaffold(
      appBar: AppBar(title: const Text('長さのトレーニング')),
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
                    child: _LineCard(
                      label: 'A',
                      length: trial.lengthA,
                      angle: trial.angleA,
                      onTap: () => _answer(true),
                    ),
                  ),
                  Expanded(
                    child: _LineCard(
                      label: 'B',
                      length: trial.lengthB,
                      angle: trial.angleB,
                      onTap: () => _answer(false),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '長い方をタップ',
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

class _LineCard extends StatelessWidget {
  const _LineCard({
    required this.label,
    required this.length,
    required this.angle,
    required this.onTap,
  });

  final String label;
  final double length;
  final double angle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                left: 12,
                top: 8,
                child: Text(label, style: theme.textTheme.labelLarge),
              ),
              Center(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _LinePainter(
                    length: length,
                    angle: angle,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter({
    required this.length,
    required this.angle,
    required this.color,
  });

  final double length;
  final double angle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final center = size.center(Offset.zero);
    // 傾けても収まるよう、カードの幅を基準に長さを決める
    final half = length * size.width * 0.45;
    final delta = Offset(cos(angle), sin(angle)) * half;
    canvas.drawLine(center - delta, center + delta, paint);
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.length != length || old.angle != angle || old.color != color;
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.session, required this.onRestart});

  final LengthSession session;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final threshold = session.threshold;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('見分けられた最小の差',
              textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '${threshold.toStringAsFixed(1)} %',
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            lengthRating(threshold),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '正解 ${session.correctCount} / ${session.trialCount}',
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

import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/history/score_history.dart';
import '../common/training_widgets.dart';
import 'length_compare.dart';

/// 長さくらべ: どちらが長いか (Issue #2)。
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
    if (session.isFinished) {
      ScoreHistory.instance.add(GameId.length, session.threshold);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trial = session.trial;
    return Scaffold(
      appBar: AppBar(title: const Text('長さくらべ')),
      body: SafeArea(
        child: trial == null
            ? TrainingResultView(
                title: '見分けられた最小の差',
                valueText: '${session.threshold.toStringAsFixed(1)} %',
                rating: lengthRating(session.threshold),
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
                    child: ChoiceCard(
                      label: 'A',
                      onTap: () => _answer(true),
                      child: CustomPaint(
                        painter: _LinePainter(
                          length: trial.lengthA,
                          angle: trial.angleA,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ChoiceCard(
                      label: 'B',
                      onTap: () => _answer(false),
                      child: CustomPaint(
                        painter: _LinePainter(
                          length: trial.lengthB,
                          angle: trial.angleB,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
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


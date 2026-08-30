import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/history/score_history.dart';
import '../common/training_widgets.dart';
import 'angle_compare.dart';

/// 角度くらべ: どちらが開いているか (Issue #4)。
class AngleCompareScreen extends StatefulWidget {
  const AngleCompareScreen({super.key});

  @override
  State<AngleCompareScreen> createState() => _AngleCompareScreenState();
}

class _AngleCompareScreenState extends State<AngleCompareScreen> {
  late AngleSession session;
  bool? lastCorrect;

  @override
  void initState() {
    super.initState();
    session = AngleSession();
  }

  void _restart() {
    setState(() {
      session = AngleSession();
      lastCorrect = null;
    });
  }

  void _answer(bool choseA) {
    setState(() {
      lastCorrect = session.answer(choseA: choseA);
    });
    if (session.isFinished) {
      ScoreHistory.instance.add(GameId.angle, session.threshold);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trial = session.trial;
    return Scaffold(
      appBar: AppBar(title: const Text('角度くらべ')),
      body: SafeArea(
        child: trial == null
            ? TrainingResultView(
                title: '見分けられた最小の差',
                valueText: '${session.threshold.toStringAsFixed(1)}°',
                rating: angleRating(session.threshold),
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
                        painter: _AnglePainter(
                          degrees: trial.angleA,
                          rotation: trial.rotationA,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ChoiceCard(
                      label: 'B',
                      onTap: () => _answer(false),
                      child: CustomPaint(
                        painter: _AnglePainter(
                          degrees: trial.angleB,
                          rotation: trial.rotationB,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '開きが大きい方をタップ',
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

class _AnglePainter extends CustomPainter {
  const _AnglePainter({
    required this.degrees,
    required this.rotation,
    required this.color,
  });

  final double degrees;
  final double rotation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final center = size.center(Offset.zero);
    final len = size.shortestSide * 0.38;
    final half = degrees * pi / 180 / 2;
    final d1 = Offset(cos(rotation - half), sin(rotation - half));
    final d2 = Offset(cos(rotation + half), sin(rotation + half));
    canvas.drawLine(center, center + d1 * len, paint);
    canvas.drawLine(center, center + d2 * len, paint);
    // 開きを示す小さな弧
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: len * 0.3),
      rotation - half,
      degrees * pi / 180,
      false,
      paint..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_AnglePainter old) =>
      old.degrees != degrees || old.rotation != rotation || old.color != color;
}

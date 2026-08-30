import 'dart:math';

import 'package:flutter/material.dart';

import '../common/training_widgets.dart';
import 'area_compare.dart';

/// 面積くらべ: どちらが広いか (Issue #3)。
class AreaCompareScreen extends StatefulWidget {
  const AreaCompareScreen({super.key});

  @override
  State<AreaCompareScreen> createState() => _AreaCompareScreenState();
}

class _AreaCompareScreenState extends State<AreaCompareScreen> {
  late AreaSession session;
  bool? lastCorrect;

  @override
  void initState() {
    super.initState();
    session = AreaSession();
  }

  void _restart() {
    setState(() {
      session = AreaSession();
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
      appBar: AppBar(title: const Text('面積くらべ')),
      body: SafeArea(
        child: trial == null
            ? TrainingResultView(
                title: '見分けられた最小の差',
                valueText: '${session.threshold.toStringAsFixed(1)} %',
                rating: areaRating(session.threshold),
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
                        painter: _ShapePainter(
                          shape: trial.shapeA,
                          area: trial.areaA,
                          aspect: trial.aspectA,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ChoiceCard(
                      label: 'B',
                      onTap: () => _answer(false),
                      child: CustomPaint(
                        painter: _ShapePainter(
                          shape: trial.shapeB,
                          area: trial.areaB,
                          aspect: trial.aspectB,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '広い方をタップ (形が違っても面積で)',
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

class _ShapePainter extends CustomPainter {
  const _ShapePainter({
    required this.shape,
    required this.area,
    required this.aspect,
    required this.color,
  });

  final AreaShape shape;

  /// カードの短辺を 1 とした相対面積。
  final double area;
  final double aspect;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final unit = size.shortestSide;
    final center = size.center(Offset.zero);
    switch (shape) {
      case AreaShape.circle:
        canvas.drawCircle(center, sqrt(area / pi) * unit, paint);
      case AreaShape.square:
        final side = sqrt(area) * unit;
        canvas.drawRect(
            Rect.fromCenter(center: center, width: side, height: side), paint);
      case AreaShape.rect:
        final w = sqrt(area * aspect) * unit;
        final h = sqrt(area / aspect) * unit;
        canvas.drawRect(
            Rect.fromCenter(center: center, width: w, height: h), paint);
    }
  }

  @override
  bool shouldRepaint(_ShapePainter old) =>
      old.shape != shape ||
      old.area != area ||
      old.aspect != aspect ||
      old.color != color;
}

import 'package:flutter/material.dart';

import '../common/training_widgets.dart';
import 'numerosity_compare.dart';

/// かずくらべ: どちらが多いか (Issue #9)。
class NumerosityCompareScreen extends StatefulWidget {
  const NumerosityCompareScreen({super.key});

  @override
  State<NumerosityCompareScreen> createState() =>
      _NumerosityCompareScreenState();
}

class _NumerosityCompareScreenState extends State<NumerosityCompareScreen> {
  late NumerositySession session;
  bool? lastCorrect;
  bool visible = false;
  int _token = 0;

  static const showDuration = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    session = NumerositySession();
    WidgetsBinding.instance.addPostFrameCallback((_) => _flash());
  }

  void _restart() {
    setState(() {
      session = NumerositySession();
      lastCorrect = null;
    });
    _flash();
  }

  Future<void> _flash() async {
    if (session.trial == null) return;
    final token = ++_token;
    setState(() => visible = true);
    await Future<void>.delayed(showDuration);
    if (mounted && _token == token) setState(() => visible = false);
  }

  void _answer(bool choseA) {
    setState(() {
      lastCorrect = session.answer(choseA: choseA);
    });
    _flash();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trial = session.trial;
    return Scaffold(
      appBar: AppBar(title: const Text('かずくらべ')),
      body: SafeArea(
        child: trial == null
            ? TrainingResultView(
                title: '見分けられた最小の差',
                valueText: '${session.threshold.toStringAsFixed(1)} %',
                rating: numerosityRating(session.threshold),
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
                    child: _DotsCard(
                      label: 'A',
                      dots: trial.dotsA,
                      visible: visible,
                      color: theme.colorScheme.primary,
                      onTap: () => _answer(true),
                    ),
                  ),
                  Expanded(
                    child: _DotsCard(
                      label: 'B',
                      dots: trial.dotsB,
                      visible: visible,
                      color: theme.colorScheme.primary,
                      onTap: () => _answer(false),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      visible ? '数えずに、感覚で!' : '多かった方をタップ',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextButton.icon(
                      onPressed: visible ? null : _flash,
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('もう一度見る'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DotsCard extends StatelessWidget {
  const _DotsCard({
    required this.label,
    required this.dots,
    required this.visible,
    required this.color,
    required this.onTap,
  });

  final String label;
  final List<Dot> dots;
  final bool visible;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceCard(
      label: label,
      onTap: onTap,
      child: visible
          ? CustomPaint(painter: _DotsPainter(dots: dots, color: color))
          : Center(
              child: Icon(Icons.help_outline,
                  size: 40, color: theme.colorScheme.outlineVariant),
            ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  const _DotsPainter({required this.dots, required this.color});

  final List<Dot> dots;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // 正方形領域をカード中央に置く
    final unit = size.shortestSide;
    final offset = Offset(
      (size.width - unit) / 2,
      (size.height - unit) / 2,
    );
    for (final d in dots) {
      canvas.drawCircle(
        offset + Offset(d.x * unit, d.y * unit),
        d.r * unit,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.dots != dots || old.color != color;
}

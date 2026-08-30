import 'package:flutter/material.dart';

import '../../core/history/score_history.dart';
import '../common/training_widgets.dart';
import 'color_maker.dart';

/// 色をつくる: 見本を HSV スライダーで再現 (Issue #14)。
class ColorMakerScreen extends StatefulWidget {
  const ColorMakerScreen({super.key});

  @override
  State<ColorMakerScreen> createState() => _ColorMakerScreenState();
}

class _ColorMakerScreenState extends State<ColorMakerScreen> {
  late ColorMakerSession session;
  double hue = 180;
  double saturation = 0.5;
  double value = 0.7;
  double? lastDeltaE;

  Color get made =>
      HSVColor.fromAHSV(1, hue, saturation, value).toColor();

  @override
  void initState() {
    super.initState();
    session = ColorMakerSession();
  }

  void _restart() {
    setState(() {
      session = ColorMakerSession();
      lastDeltaE = null;
      hue = 180;
      saturation = 0.5;
      value = 0.7;
    });
  }

  void _submit() {
    setState(() {
      lastDeltaE = session.submit(made);
      // 次のラウンドはスライダーを中立に戻す
      hue = 180;
      saturation = 0.5;
      value = 0.7;
    });
    if (session.isFinished) {
      ScoreHistory.instance.add(GameId.colorMaker, session.averageDeltaE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = session.target;
    return Scaffold(
      appBar: AppBar(title: const Text('色をつくる')),
      body: SafeArea(
        child: target == null
            ? TrainingResultView(
                title: '平均のずれ',
                valueText:
                    'ΔE ${session.averageDeltaE.toStringAsFixed(1)}',
                rating: '${colorMakerRating(session.averageDeltaE)}\n'
                    '(ベスト ΔE ${session.bestDeltaE.toStringAsFixed(1)})',
                correctCount: session.answered,
                trialCount: session.roundCount,
                onRestart: _restart,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        Text(
                          '${session.answered + 1} / ${session.roundCount}',
                          style: theme.textTheme.titleSmall,
                        ),
                        const Spacer(),
                        if (lastDeltaE != null)
                          Text(
                            '前回 ΔE ${lastDeltaE!.toStringAsFixed(1)}',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _Swatch(label: '見本', color: target),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _Swatch(label: 'あなたの色', color: made),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _LabeledSlider(
                    label: '色相',
                    value: hue,
                    max: 360,
                    onChanged: (v) => setState(() => hue = v),
                  ),
                  _LabeledSlider(
                    label: '鮮やかさ',
                    value: saturation,
                    max: 1,
                    onChanged: (v) => setState(() => saturation = v),
                  ),
                  _LabeledSlider(
                    label: '明るさ',
                    value: value,
                    max: 1,
                    onChanged: (v) => setState(() => value = v),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('これで決定'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: Slider(value: value, max: max, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

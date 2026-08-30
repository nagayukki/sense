import 'package:flutter/material.dart';

/// トレーニング共通: 進捗ヘッダ (n/N、直前の正誤、プログレスバー)。
class TrainingProgressHeader extends StatelessWidget {
  const TrainingProgressHeader({
    super.key,
    required this.answered,
    required this.trialCount,
    required this.lastCorrect,
  });

  final int answered;
  final int trialCount;
  final bool? lastCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text('${answered + 1} / $trialCount',
                  style: theme.textTheme.titleSmall),
              const Spacer(),
              if (lastCorrect != null)
                Icon(
                  lastCorrect! ? Icons.check_circle : Icons.cancel,
                  size: 20,
                  color:
                      lastCorrect! ? Colors.green : theme.colorScheme.error,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LinearProgressIndicator(value: answered / trialCount),
        ),
      ],
    );
  }
}

/// トレーニング共通: 結果画面 (閾値、評価、正解数、リスタート)。
class TrainingResultView extends StatelessWidget {
  const TrainingResultView({
    super.key,
    required this.title,
    required this.valueText,
    required this.rating,
    required this.correctCount,
    required this.trialCount,
    required this.onRestart,
  });

  final String title;
  final String valueText;
  final String rating;
  final int correctCount;
  final int trialCount;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            valueText,
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(rating,
              textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            '正解 $correctCount / $trialCount',
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

/// トレーニング共通: A/B 選択カード。中身は [child] で描く。
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback onTap;
  final Widget child;

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
              Positioned.fill(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

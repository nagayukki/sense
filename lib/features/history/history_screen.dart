import 'package:flutter/material.dart';

import '../../core/history/score_history.dart';

/// きろく: あそびごとのスコア履歴と推移 (Issue #12)。
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<Map<String, List<ScoreRecord>>> _loadAll() async {
    final result = <String, List<ScoreRecord>>{};
    for (final meta in gameMetas) {
      result[meta.id] = await ScoreHistory.instance.list(meta.id);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('きろく')),
      body: FutureBuilder(
        future: _loadAll(),
        builder: (context, snapshot) {
          final all = snapshot.data;
          if (all == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final played =
              gameMetas.where((m) => all[m.id]!.isNotEmpty).toList();
          if (played.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insights_outlined,
                      size: 56, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('まだ記録がありません', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('あそび終わると自動で記録されます',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: played.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
            itemBuilder: (context, index) {
              final meta = played[index];
              final records = all[meta.id]!;
              final best =
                  bestOf(records, higherIsBetter: meta.higherIsBetter)!;
              final latest = records.last.value;
              return ListTile(
                title: Text(meta.label),
                subtitle: Text(
                  '${records.length}回 · ベスト ${meta.format(best)}'
                  ' · 直近 ${meta.format(latest)}',
                ),
                trailing: SizedBox(
                  width: 88,
                  height: 36,
                  child: CustomPaint(
                    painter: _SparklinePainter(
                      values: [
                        for (final r in records.length > 20
                            ? records.sublist(records.length - 20)
                            : records)
                          r.value,
                      ],
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      final paint = Paint()..color = color;
      canvas.drawCircle(size.center(Offset.zero), 3, paint);
      return;
    }
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final norm = range == 0 ? 0.5 : (values[i] - min) / range;
      final y = size.height - norm * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.values != values || old.color != color;
}

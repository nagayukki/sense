import 'package:flutter/material.dart';

import '../../core/color/lab.dart';
import 'lab_common.dart';

/// 案D: 知覚均等空間 (CIELAB)。明度スライダー + a×b 平面。
/// タイル間の「見た目の差」が均等になる切り方。色域外は空セル。
class LabPlaneScreen extends StatefulWidget {
  const LabPlaneScreen({super.key});

  @override
  State<LabPlaneScreen> createState() => _LabPlaneScreenState();
}

class _LabPlaneScreenState extends State<LabPlaneScreen> {
  static const gridN = 12;

  double lightness = 65;
  double a0 = -90, a1 = 90, b0 = -90, b1 = 90;
  int depth = 0;

  Color get centerColor =>
      labToSrgb(Lab(lightness, (a0 + a1) / 2, (b0 + b1) / 2)) ??
      const Color(0xFF808080);

  void _reset() {
    setState(() {
      a0 = -90;
      a1 = 90;
      b0 = -90;
      b1 = 90;
      depth = 0;
    });
  }

  void _pick(int col, int row) {
    if (depth >= 2) return;
    final aw = (a1 - a0) / gridN;
    final bw = (b1 - b0) / gridN;
    setState(() {
      a1 = a0 + (col + 1) * aw;
      a0 = a0 + col * aw;
      // 上の行ほど b が大きい (黄方向)
      final bTop = b1 - row * bw;
      b0 = bTop - bw;
      b1 = bTop;
      depth++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('案D 知覚均等 (Lab)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: depth == 0 ? null : _reset,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LabNote(text: '隣どうしの見た目の差が均等になる切り方。画面に出せない色は空白'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text('明度 ${lightness.round()} / 深さ $depth',
                      style: theme.textTheme.titleSmall),
                  const Spacer(),
                  if (depth > 0)
                    TextButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('最初から'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.count(
                      crossAxisCount: gridN,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (var row = 0; row < gridN; row++)
                          for (var col = 0; col < gridN; col++)
                            _cell(col, row),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text('暗', style: theme.textTheme.bodySmall),
                  Expanded(
                    child: Slider(
                      value: lightness,
                      max: 100,
                      onChanged: (v) => setState(() => lightness = v),
                    ),
                  ),
                  Text('明', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            LabInfoBar(color: centerColor),
          ],
        ),
      ),
    );
  }

  Widget _cell(int col, int row) {
    final aw = (a1 - a0) / gridN;
    final bw = (b1 - b0) / gridN;
    final color = labToSrgb(Lab(
      lightness,
      a0 + (col + 0.5) * aw,
      b1 - (row + 0.5) * bw,
    ));
    if (color == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _pick(col, row),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

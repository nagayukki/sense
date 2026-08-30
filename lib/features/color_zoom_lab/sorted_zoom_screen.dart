import 'package:flutter/material.dart';

import '../color_zoom/color_zoom_state.dart';
import 'lab_common.dart';

/// 案B: 分割は立方体のまま、表示だけ色相→明るさで整列した 8×8。
class SortedZoomScreen extends StatefulWidget {
  const SortedZoomScreen({super.key});

  @override
  State<SortedZoomScreen> createState() => _SortedZoomScreenState();
}

class _SortedZoomScreenState extends State<SortedZoomScreen> {
  final state = ColorZoomState();

  List<((int, int, int), Color)> _sortedTiles() {
    final d = state.divisions;
    final tiles = <((int, int, int), Color)>[
      for (var bi = 0; bi < d; bi++)
        for (var gi = 0; gi < d; gi++)
          for (var ri = 0; ri < d; ri++)
            ((ri, gi, bi), state.tileColor(ri, gi, bi)),
    ];
    double hue(Color c) => HSVColor.fromColor(c).hue;
    double luma(Color c) => 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
    tiles.sort((a, b) {
      final ha = hue(a.$2), hb = hue(b.$2);
      if ((ha - hb).abs() > 1e-6) return ha.compareTo(hb);
      return luma(a.$2).compareTo(luma(b.$2));
    });
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finalColor = state.finalColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('案B 切って整列'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.depth == 0 ? null : () => setState(state.reset),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LabNote(text: '分割は案Aと同じ64分割。表示だけ色相→明るさ順に並べ替え'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text('深さ ${state.depth} / ${state.maxDepth}',
                      style: theme.textTheme.titleSmall),
                  const Spacer(),
                  if (state.depth > 0)
                    TextButton.icon(
                      onPressed: () => setState(state.back),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('戻る'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: finalColor != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: finalColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: GridView.count(
                            crossAxisCount: 8,
                            mainAxisSpacing: 3,
                            crossAxisSpacing: 3,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              for (final (index, color) in _sortedTiles())
                                GestureDetector(
                                  onTap: () => setState(() => state.select(
                                      index.$1, index.$2, index.$3)),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            LabInfoBar(color: state.centerColor),
          ],
        ),
      ),
    );
  }
}

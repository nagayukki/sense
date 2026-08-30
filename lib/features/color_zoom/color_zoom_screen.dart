import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/color/nearest_name.dart';
import 'color_zoom_state.dart';

/// ズーム型色見本 (Issue #5)。
///
/// B 軸で divisions 枚にスライスし、各スライスを R×G のグリッドで表示する。
/// 各面がグラデーション状に見えるのが狙い (案A)。
class ColorZoomScreen extends StatefulWidget {
  const ColorZoomScreen({super.key});

  @override
  State<ColorZoomScreen> createState() => _ColorZoomScreenState();
}

class _ColorZoomScreenState extends State<ColorZoomScreen> {
  final state = ColorZoomState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = state.divisions;
    final finalColor = state.finalColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('色見本'),
        actions: [
          IconButton(
            tooltip: '最初から',
            icon: const Icon(Icons.refresh),
            onPressed:
                state.depth == 0 ? null : () => setState(state.reset),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusBar(state: state),
            _Breadcrumb(state: state, onBack: () => setState(state.back)),
            Expanded(
              child: finalColor != null
                  ? _FinalColorView(color: finalColor)
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          for (var bi = 0; bi < d; bi++)
                            _Slice(
                              state: state,
                              blueIndex: bi,
                              onTap: (ri, gi) =>
                                  setState(() => state.select(ri, gi, bi)),
                            ),
                        ],
                      ),
                    ),
            ),
            if (finalColor == null) ...[
              _CenterInfo(state: state),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: Text(
                  'タップして潜っていく',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.state});

  final ColorZoomState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = state.finalColor != null
        ? '1,677 万分の 1 に到達'
        : '1 タイル = ${_comma(state.colorsPerTile)} 色';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Text('深さ ${state.depth} / ${state.maxDepth}',
              style: theme.textTheme.titleSmall),
          const Spacer(),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.state, required this.onBack});

  final ColorZoomState state;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: 16),
          for (var i = 0; i < state.depth; i++) ...[
            if (i > 0)
              Icon(Icons.chevron_right,
                  size: 16, color: theme.colorScheme.outline),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: state.crumbColor(i),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
            ),
          ],
          const Spacer(),
          if (state.depth > 0)
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('戻る'),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// B 値ごとの 1 スライス。R (横) × G (縦) のグリッド。
class _Slice extends StatelessWidget {
  const _Slice({
    required this.state,
    required this.blueIndex,
    required this.onTap,
  });

  final ColorZoomState state;
  final int blueIndex;
  final void Function(int ri, int gi) onTap;

  /// タイルの小立方体に含まれる色名 (ランドマーク)。深さ1以降で表示。
  String? _labelFor(int ri, int gi) {
    if (state.depth < 1) return null;
    final (r, g, b) = state.origin;
    final step = state.size ~/ state.divisions;
    final names = namedColorsInCube(
      r: r + ri * step,
      g: g + gi * step,
      b: b + blueIndex * step,
      size: step,
    );
    if (names.isEmpty) return null;
    return names.first.name;
  }

  @override
  Widget build(BuildContext context) {
    final d = state.divisions;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var gi = 0; gi < d; gi++)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var ri = 0; ri < d; ri++)
                    Expanded(
                      child: _Tile(
                        color: state.tileColor(ri, gi, blueIndex),
                        label: _labelFor(ri, gi),
                        onTap: () => onTap(ri, gi),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.color,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    final luma = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
    return GestureDetector(
      onTap: onTap,
      child: ColoredBox(
        color: color,
        child: label == null
            ? null
            : Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      color: luma > 0.5 ? Colors.black87 : Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// 現在の領域の代表色 (中心) の情報。RGB と近い色名を常時見せる。
class _CenterInfo extends StatelessWidget {
  const _CenterInfo({required this.state});

  final ColorZoomState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final center = state.centerColor;
    final r = (center.r * 255).round();
    final g = (center.g * 255).round();
    final b = (center.b * 255).round();
    final hex = '#'
            '${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
    final names = nearestNames(center, count: 2);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: center,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('このあたり $hex',
                  style: theme.textTheme.titleSmall),
              Text('R $r · G $g · B $b',
                  style: theme.textTheme.bodySmall),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final n in names)
                Text(
                  '${n.color.name}  ΔE ${n.deltaE.toStringAsFixed(1)}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinalColorView extends StatelessWidget {
  const _FinalColorView({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    final hex = '#${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SelectableText(hex, style: theme.textTheme.headlineSmall),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'コピー',
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () => Clipboard.setData(ClipboardData(text: hex)),
              ),
            ],
          ),
          Text(
            'R $r · G $g · B $b',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _NearestNames(color: color),
        ],
      ),
    );
  }
}

/// 最寄りの色名 (ランドマーク) を色差つきで表示する。
class _NearestNames extends StatelessWidget {
  const _NearestNames({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final names = nearestNames(color);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('近い色の名前', style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        for (final n in names)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(0xFF000000 | n.color.rgb),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    n.color.reading == n.color.name
                        ? n.color.name
                        : '${n.color.name} (${n.color.reading})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'ΔE ${n.deltaE.toStringAsFixed(1)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _comma(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

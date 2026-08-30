import 'dart:math';

import 'package:flutter/material.dart';

import 'lab_common.dart';

/// 案C: HSV。色相環 (24色相 × 3彩度帯) で入口を選び、
/// その先は 彩度×明度 の 8×8 グリッドを潜る。
class HueWheelScreen extends StatefulWidget {
  const HueWheelScreen({super.key});

  @override
  State<HueWheelScreen> createState() => _HueWheelScreenState();
}

class _HueWheelScreenState extends State<HueWheelScreen> {
  double? hue; // null = 色相環表示
  // 選択中の彩度・明度の範囲 (0-1)
  double s0 = 0, s1 = 1, v0 = 0, v1 = 1;
  int depth = 0;

  Color get centerColor => hue == null
      ? const Color(0xFF808080)
      : HSVColor.fromAHSV(1, hue!, (s0 + s1) / 2, (v0 + v1) / 2).toColor();

  void _reset() {
    setState(() {
      hue = null;
      s0 = 0;
      s1 = 1;
      v0 = 0;
      v1 = 1;
      depth = 0;
    });
  }

  void _pickWheel(Offset local, Size size) {
    final center = size.center(Offset.zero);
    final d = local - center;
    final r = d.distance;
    final outer = size.shortestSide / 2;
    if (r < outer * 0.25 || r > outer) return;
    final angle = (atan2(d.dy, d.dx) * 180 / pi + 360) % 360;
    final ring = ((r - outer * 0.25) / (outer * 0.75) * 3).floor().clamp(0, 2);
    setState(() {
      hue = (angle / 15).floor() * 15 + 7.5;
      s0 = ring / 3;
      s1 = (ring + 1) / 3;
      v0 = 0;
      v1 = 1;
      depth = 1;
    });
  }

  void _pickGrid(int col, int row) {
    const n = 8;
    final sw = (s1 - s0) / n;
    final vw = (v1 - v0) / n;
    setState(() {
      s1 = s0 + (col + 1) * sw;
      s0 = s0 + col * sw;
      // 上の行ほど明るい
      final vTop = v1 - row * vw;
      v0 = vTop - vw;
      v1 = vTop;
      depth++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('案C 色相環 (HSV)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: hue == null ? null : _reset,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LabNote(text: 'まず色相環で色味と鮮やかさの帯を選び、その先を潜る'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(
                    hue == null ? '色相環から選ぶ' : '色相 ${hue!.round()}° / 深さ $depth',
                    style: theme.textTheme.titleSmall,
                  ),
                  const Spacer(),
                  if (hue != null)
                    TextButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('色相環へ'),
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
                    child: hue == null
                        ? LayoutBuilder(
                            builder: (context, constraints) => GestureDetector(
                              onTapUp: (d) => _pickWheel(
                                  d.localPosition, constraints.biggest),
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _WheelPainter(),
                              ),
                            ),
                          )
                        : GridView.count(
                            crossAxisCount: 8,
                            mainAxisSpacing: 3,
                            crossAxisSpacing: 3,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              for (var row = 0; row < 8; row++)
                                for (var col = 0; col < 8; col++)
                                  GestureDetector(
                                    onTap: () => _pickGrid(col, row),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: HSVColor.fromAHSV(
                                          1,
                                          hue!,
                                          s0 + (col + 0.5) * (s1 - s0) / 8,
                                          v1 - (row + 0.5) * (v1 - v0) / 8,
                                        ).toColor(),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            LabInfoBar(color: centerColor),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outer = size.shortestSide / 2;
    for (var ring = 0; ring < 3; ring++) {
      final r0 = outer * (0.25 + ring * 0.25);
      final r1 = outer * (0.25 + (ring + 1) * 0.25) - 2;
      final s = (ring + 0.5) / 3;
      for (var i = 0; i < 24; i++) {
        final a0 = (i * 15 + 0.6) * pi / 180;
        final a1 = ((i + 1) * 15 - 0.6) * pi / 180;
        final paint = Paint()
          ..color =
              HSVColor.fromAHSV(1, i * 15 + 7.5, s, 0.9).toColor();
        final path = Path()
          ..arcTo(Rect.fromCircle(center: center, radius: r1), a0, a1 - a0,
              true)
          ..arcTo(Rect.fromCircle(center: center, radius: r0), a1, a0 - a1,
              false)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

import 'hue_wheel_screen.dart';
import 'lab_plane_screen.dart';
import 'sorted_zoom_screen.dart';

/// 色見本ラボ: 見せ方の案 B/C/D を比較する (Issue #5)。
/// 本採用の案A は「色見本」として別にある。
class ColorZoomLabScreen extends StatelessWidget {
  const ColorZoomLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = [
      (
        '案B 切って整列',
        '案Aと同じ64分割を、色相→明るさ順の8×8で',
        Icons.sort,
        (BuildContext c) => const SortedZoomScreen(),
      ),
      (
        '案C 色相環 (HSV)',
        '色味 → 鮮やかさ → 明るさの順で選ぶ',
        Icons.donut_large_outlined,
        (BuildContext c) => const HueWheelScreen(),
      ),
      (
        '案D 知覚均等 (Lab)',
        '見た目の差が均等なマス目。明度スライダーつき',
        Icons.grid_4x4,
        (BuildContext c) => const LabPlaneScreen(),
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('色見本ラボ')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '見せ方の比較用。本採用は「色見本」(案A)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final (title, subtitle, icon, builder) in entries)
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: builder),
              ),
            ),
        ],
      ),
    );
  }
}

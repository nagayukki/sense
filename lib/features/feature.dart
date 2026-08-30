import 'package:flutter/material.dart';

import 'angle_training/angle_compare_screen.dart';
import 'area_training/area_compare_screen.dart';
import 'color_training/odd_one_out_screen.dart';
import 'color_zoom/color_zoom_screen.dart';
import 'length_training/length_compare_screen.dart';
import 'placeholder/placeholder_screen.dart';

/// ホームに並ぶ機能の定義。追加する機能はここに足す。
class Feature {
  const Feature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.issueNumber,
    this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int issueNumber;

  /// null の場合は未実装 (プレースホルダ画面を開く)。
  final WidgetBuilder? builder;

  bool get isImplemented => builder != null;

  Widget buildScreen(BuildContext context) {
    final builder = this.builder;
    if (builder != null) return builder(context);
    return PlaceholderScreen(feature: this);
  }
}

const features = [
  Feature(
    title: '色見本',
    subtitle: 'タップで広がる 1,677万色',
    icon: Icons.palette_outlined,
    issueNumber: 5,
    builder: _colorZoom,
  ),
  Feature(
    title: '色のトレーニング',
    subtitle: '微妙な色の違いを見分ける',
    icon: Icons.colorize_outlined,
    issueNumber: 1,
    builder: _oddOneOut,
  ),
  Feature(
    title: '長さのトレーニング',
    subtitle: 'どちらが長いかを見抜く',
    icon: Icons.straighten_outlined,
    issueNumber: 2,
    builder: _lengthCompare,
  ),
  Feature(
    title: '面積のトレーニング',
    subtitle: '形が違っても広さで比べる',
    icon: Icons.crop_square_outlined,
    issueNumber: 3,
    builder: _areaCompare,
  ),
  Feature(
    title: '角度のトレーニング',
    subtitle: 'どちらが開いているかを見抜く',
    icon: Icons.architecture_outlined,
    issueNumber: 4,
    builder: _angleCompare,
  ),
];

Widget _colorZoom(BuildContext context) => const ColorZoomScreen();

Widget _oddOneOut(BuildContext context) => const OddOneOutScreen();

Widget _lengthCompare(BuildContext context) => const LengthCompareScreen();

Widget _areaCompare(BuildContext context) => const AreaCompareScreen();

Widget _angleCompare(BuildContext context) => const AngleCompareScreen();

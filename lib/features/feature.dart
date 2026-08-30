import 'package:flutter/material.dart';

import 'angle_training/angle_compare_screen.dart';
import 'area_training/area_compare_screen.dart';
import 'color_training/odd_one_out_screen.dart';
import 'color_zoom/color_zoom_screen.dart';
import 'length_training/length_compare_screen.dart';
import 'pitch_training/pitch_compare_screen.dart';
import 'note_quiz/note_quiz_screen.dart';
import 'numerosity_training/numerosity_compare_screen.dart';
import 'placeholder/placeholder_screen.dart';
import 'rhythm_keep/rhythm_keep_screen.dart';
import 'tempo_training/tempo_compare_screen.dart';
import 'time_training/time_compare_screen.dart';

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
    title: '色くらべ',
    subtitle: 'ひとつだけ違う色をさがす',
    icon: Icons.colorize_outlined,
    issueNumber: 1,
    builder: _oddOneOut,
  ),
  Feature(
    title: '長さくらべ',
    subtitle: 'どっちが長い?',
    icon: Icons.straighten_outlined,
    issueNumber: 2,
    builder: _lengthCompare,
  ),
  Feature(
    title: '面積くらべ',
    subtitle: '形がちがっても広さでくらべる',
    icon: Icons.crop_square_outlined,
    issueNumber: 3,
    builder: _areaCompare,
  ),
  Feature(
    title: '角度くらべ',
    subtitle: 'どっちが開いてる?',
    icon: Icons.architecture_outlined,
    issueNumber: 4,
    builder: _angleCompare,
  ),
  Feature(
    title: '音の高さくらべ',
    subtitle: '楽器がちがっても高さでくらべる',
    icon: Icons.music_note_outlined,
    issueNumber: 6,
    builder: _pitchCompare,
  ),
  Feature(
    title: '音名当て',
    subtitle: 'この音はドレミのどれ?',
    icon: Icons.piano_outlined,
    issueNumber: 7,
    builder: _noteQuiz,
  ),
  Feature(
    title: 'テンポくらべ',
    subtitle: 'どっちが速い?',
    icon: Icons.speed_outlined,
    issueNumber: 11,
    builder: _tempoCompare,
  ),
  Feature(
    title: 'リズムキープ',
    subtitle: '音が消えてもテンポを保てる?',
    icon: Icons.touch_app_outlined,
    issueNumber: 11,
    builder: _rhythmKeep,
  ),
  Feature(
    title: '時間くらべ',
    subtitle: 'どっちが長かった?',
    icon: Icons.timer_outlined,
    issueNumber: 8,
    builder: _timeCompare,
  ),
  Feature(
    title: 'かずくらべ',
    subtitle: 'どっちが多い?',
    icon: Icons.grain_outlined,
    issueNumber: 9,
    builder: _numerosityCompare,
  ),
];

Widget _colorZoom(BuildContext context) => const ColorZoomScreen();

Widget _oddOneOut(BuildContext context) => const OddOneOutScreen();

Widget _lengthCompare(BuildContext context) => const LengthCompareScreen();

Widget _areaCompare(BuildContext context) => const AreaCompareScreen();

Widget _angleCompare(BuildContext context) => const AngleCompareScreen();

Widget _pitchCompare(BuildContext context) => const PitchCompareScreen();

Widget _timeCompare(BuildContext context) => const TimeCompareScreen();

Widget _numerosityCompare(BuildContext context) =>
    const NumerosityCompareScreen();

Widget _noteQuiz(BuildContext context) => const NoteQuizScreen();

Widget _tempoCompare(BuildContext context) => const TempoCompareScreen();

Widget _rhythmKeep(BuildContext context) => const RhythmKeepScreen();

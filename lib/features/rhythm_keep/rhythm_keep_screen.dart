import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/audio/click_sequence.dart';
import 'rhythm_keep.dart';

enum _Phase { ready, guide, tapping, result }

/// リズムキープ: ガイドが消えてもテンポを保ってタップ (Issue #11)。
class RhythmKeepScreen extends StatefulWidget {
  const RhythmKeepScreen({super.key});

  @override
  State<RhythmKeepScreen> createState() => _RhythmKeepScreenState();
}

class _RhythmKeepScreenState extends State<RhythmKeepScreen> {
  static const guideCount = 8;
  static const tapGoal = 8;

  final player = AudioPlayer();
  final random = Random();
  final stopwatch = Stopwatch();

  _Phase phase = _Phase.ready;
  late Duration interval;
  int guideBeat = 0;
  Timer? guideTimer;
  final tapTimes = <int>[];
  RhythmKeepResult? result;
  bool tapFlash = false;

  @override
  void initState() {
    super.initState();
    interval = _newInterval();
  }

  @override
  void dispose() {
    guideTimer?.cancel();
    player.dispose();
    super.dispose();
  }

  Duration _newInterval() =>
      Duration(milliseconds: 400 + random.nextInt(201));

  Future<void> _start() async {
    interval = _newInterval();
    tapTimes.clear();
    result = null;
    setState(() {
      phase = _Phase.guide;
      guideBeat = 0;
    });
    await player.stop();
    await player.play(BytesSource(
        clickSequenceWav(interval: interval, count: guideCount)));
    // 視覚パルス (音とは近似同期)
    guideTimer?.cancel();
    guideTimer = Timer.periodic(interval, (t) {
      if (!mounted) return;
      setState(() => guideBeat = t.tick);
      if (t.tick >= guideCount - 1) {
        t.cancel();
        setState(() => phase = _Phase.tapping);
        stopwatch
          ..reset()
          ..start();
      }
    });
    setState(() => guideBeat = 0);
  }

  void _tap() {
    if (phase != _Phase.tapping) return;
    tapTimes.add(stopwatch.elapsedMilliseconds);
    setState(() => tapFlash = !tapFlash);
    if (tapTimes.length >= tapGoal) {
      setState(() {
        result = scoreRhythmKeep(
          tapTimesMs: tapTimes,
          targetInterval: interval,
        );
        phase = _Phase.result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('リズムキープ')),
      body: SafeArea(
        child: switch (phase) {
          _Phase.ready => _centered([
              Icon(Icons.touch_app_outlined,
                  size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('$guideCount 回のクリックを聞いたら、\n同じテンポで $tapGoal 回タップ',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow),
                label: const Text('スタート'),
              ),
            ]),
          _Phase.guide => _centered([
              _Pulse(active: true, beat: guideBeat),
              const SizedBox(height: 24),
              Text('テンポを覚えて… (${guideBeat + 1} / $guideCount)',
                  style: theme.textTheme.titleMedium),
            ]),
          _Phase.tapping => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _tap(),
              child: _centered([
                _Pulse(active: tapFlash, beat: tapTimes.length),
                const SizedBox(height: 24),
                Text('そのまま刻んで! (${tapTimes.length} / $tapGoal)',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('画面のどこをタップしてもOK',
                    style: theme.textTheme.bodySmall),
              ]),
            ),
          _Phase.result => _centered([
              Text('刻みの正確さ', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                '平均ズレ ${result!.meanAbsDeviationPercent.toStringAsFixed(1)} %',
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'ばらつき ${result!.variabilityPercent.toStringAsFixed(1)} % / '
                'テンポ ${(60000 / interval.inMilliseconds).round()} BPM',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                rhythmKeepRating(result!.meanAbsDeviationPercent),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.refresh),
                label: const Text('もう一度'),
              ),
            ]),
        },
      ),
    );
  }

  Widget _centered(List<Widget> children) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      );
}

class _Pulse extends StatelessWidget {
  const _Pulse({required this.active, required this.beat});

  final bool active;
  final int beat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      width: beat.isEven ? 88 : 72,
      height: beat.isEven ? 88 : 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

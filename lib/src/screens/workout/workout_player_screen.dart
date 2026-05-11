import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../state/app_session.dart';
import '../../theme/vein_theme.dart';
import '../../widgets/pressable.dart';
import '../../workouts/workout_catalog.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  const WorkoutPlayerScreen({super.key, required this.session, required this.plan});

  final AppSession session;
  final WorkoutPlan plan;

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  final _page = PageController();
  FlutterTts? _tts;

  Timer? _ticker;
  DateTime? _startedAt;

  int _index = 0;
  int _remaining = 0;
  bool _running = false;
  bool _inRest = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _tts = FlutterTts();
    _primeCurrent();
    WidgetsBinding.instance.addPostFrameCallback((_) => _announce());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _page.dispose();
    _tts?.stop();
    super.dispose();
  }

  void _primeCurrent() {
    final block = widget.plan.blocks[_index];
    _inRest = false;
    _running = false;
    _remaining = block.work ?? 0;
  }

  Future<void> _announce() async {
    if (!widget.session.ttsEnabled) return;
    final block = widget.plan.blocks[_index];
    final tts = _tts;
    if (tts == null) return;

    final msg = switch (block.kind) {
      WorkoutBlockKind.rest => 'Rest for ${block.rest} seconds.',
      WorkoutBlockKind.exercise => block.work != null
          ? '${block.title}. Work for ${block.work} seconds.'
          : '${block.title}. ${block.reps} reps.',
    };
    await tts.stop();
    await tts.setSpeechRate(0.45);
    await tts.setVolume(1.0);
    await tts.speak(msg);
  }

  void _start() {
    final block = widget.plan.blocks[_index];
    if (block.kind == WorkoutBlockKind.rest) {
      _startRest(block.rest);
      return;
    }

    if (block.work == null) {
      setState(() => _running = false);
      return;
    }

    setState(() => _running = true);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= 1) {
        _ticker?.cancel();
        _startRest(block.rest);
      } else {
        setState(() => _remaining -= 1);
        if (widget.session.ttsEnabled && _remaining == 10) {
          _tts?.speak('Ten seconds.');
        }
      }
    });
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _running = false);
  }

  void _startRest(int seconds) {
    setState(() {
      _inRest = true;
      _running = true;
      _remaining = seconds;
    });
    if (widget.session.ttsEnabled) {
      _tts?.speak('Rest.');
    }
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= 1) {
        _ticker?.cancel();
        _next();
      } else {
        setState(() => _remaining -= 1);
      }
    });
  }

  Future<void> _next() async {
    if (_index >= widget.plan.blocks.length - 1) {
      await _finish();
      return;
    }
    setState(() {
      _index += 1;
      _primeCurrent();
    });
    await _page.animateToPage(
      _index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    await _announce();
  }

  Future<void> _prev() async {
    if (_index == 0) return;
    setState(() {
      _index -= 1;
      _primeCurrent();
    });
    await _page.animateToPage(
      _index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    await _announce();
  }

  Future<void> _finish() async {
    setState(() {
      _finished = true;
      _running = false;
    });
    _ticker?.cancel();
    _tts?.stop();

    final total = DateTime.now().difference(_startedAt ?? DateTime.now());
    final effort = await showDialog<int>(
      context: context,
      builder: (_) => _EffortDialog(total: total),
    );
    if (!mounted) return;
    if (effort != null) {
      await widget.session.logCompletedWorkout(
        plan: widget.plan,
        perceivedEffort: effort,
        totalTime: total,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final blocks = widget.plan.blocks;
    final block = blocks[_index];

    final progress = (blocks.isEmpty) ? 0.0 : (_index + 1) / blocks.length;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: VeinTheme.maroonDeep,
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
              foregroundColor: VeinTheme.cream,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: VeinTheme.cream,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                  ),
            ),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: VeinTheme.cream,
              displayColor: VeinTheme.cream,
            ),
        iconTheme: IconThemeData(color: VeinTheme.cream.withValues(alpha: 0.92)),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.plan.title, style: const TextStyle(letterSpacing: 0.6)),
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_index + 1} / ${blocks.length}',
                      style: t.bodyMedium?.copyWith(
                        color: VeinTheme.cream.withValues(alpha: 0.78),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, child) => LinearProgressIndicator(
                        value: v,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(99),
                        backgroundColor: VeinTheme.cream.withValues(alpha: 0.16),
                        valueColor: AlwaysStoppedAnimation(VeinTheme.cream.withValues(alpha: 0.92)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: blocks.length,
                itemBuilder: (context, i) {
                  final b = blocks[i];
                  final isActive = i == _index;
                  return _BlockCard(
                    active: isActive,
                    title: _inRest && isActive ? 'Rest' : b.title,
                    descriptor: b.kind == WorkoutBlockKind.exercise
                        ? (b.work != null ? '${b.work}s work' : '${b.reps} reps')
                        : '${b.rest}s rest',
                    tips: b.tips,
                    remaining: isActive ? _remaining : 0,
                    showTimer: isActive && ((_inRest) || (b.work != null && b.kind == WorkoutBlockKind.exercise)),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _finished ? null : _prev,
                          child: const Text('Back', style: TextStyle(letterSpacing: 0.4)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Pressable(
                          enabled: !_finished,
                          onTap: _finished
                              ? null
                              : () {
                                  if (_inRest) {
                                    _pause();
                                    _next();
                                    return;
                                  }
                                  if (block.kind == WorkoutBlockKind.exercise && block.work == null) {
                                    _startRest(block.rest);
                                    return;
                                  }
                                  if (_running) {
                                    _pause();
                                  } else {
                                    _start();
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: VeinTheme.cream,
                            ),
                            child: Center(
                              child: Text(
                                _inRest
                                    ? 'Skip rest'
                                    : (block.kind == WorkoutBlockKind.exercise && block.work == null)
                                        ? 'Done'
                                        : _running
                                            ? 'Pause'
                                            : 'Start',
                                style: const TextStyle(
                                  letterSpacing: 0.7,
                                  fontWeight: FontWeight.w600,
                                  color: VeinTheme.maroonDeep,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _finished ? null : _finish,
                    child: const Text('Finish workout', style: TextStyle(letterSpacing: 0.4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// GIF lookup map
String? _gifForTitle(String title) {
  const map = {
    'Incline Push-ups': 'assets/images/inclinepush.gif',
    'Chair Dips': 'assets/images/tricepsdipspush.gif',
    'Pike Push-ups': 'assets/images/pikeupss.gif',
    'Shoulder Taps': 'assets/images/shouldertap.gif',
    'Bench Push-ups': 'assets/images/benchpush.gif',
    'Dead Hang': 'assets/images/deadhang.png',
    'Negative Pull-ups': 'assets/images/negativepulls.gif',
    'Inverted Rows': 'assets/images/invertedpulls.gif',
    'Scapular Pulls': 'assets/images/scapularpulls.gif',
    'Towel Curls': 'assets/images/towelcurls.gif',
    'Air Squats': 'assets/images/airsquats.gif',
    'Reverse Lunges': 'assets/images/reverselunges.gif',
    'Glute Bridge': 'assets/images/glutebridge.gif',
    'Wall Sit': 'assets/images/wallsit.gif',
    'Calf Raises': 'assets/images/calfraise.gif',
  };
  return map[title];
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.active,
    required this.title,
    required this.descriptor,
    required this.tips,
    required this.remaining,
    required this.showTimer,
  });

  final bool active;
  final String title;
  final String descriptor;
  final List<String> tips;
  final int remaining;
  final bool showTimer;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gifPath = _gifForTitle(title);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: VeinTheme.cream.withValues(alpha: 0.16)),
          color: VeinTheme.maroon.withValues(alpha: 0.22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (gifPath != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Image.asset(
                    gifPath,
                    height: 160,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: t.titleLarge?.copyWith(letterSpacing: 0.6, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: VeinTheme.cream.withValues(alpha: 0.16)),
                    color: VeinTheme.cream.withValues(alpha: 0.08),
                  ),
                  child: Text(descriptor, style: t.labelLarge?.copyWith(letterSpacing: 0.4)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (showTimer)
              Center(
                child: Text(
                  remaining.toString().padLeft(2, '0'),
                  style: t.displayMedium?.copyWith(
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Text('Instructions', style: t.titleMedium?.copyWith(letterSpacing: 0.5)),
            const SizedBox(height: 16),
            if (tips.isNotEmpty) ...[
              Text('Tips', style: t.titleMedium?.copyWith(letterSpacing: 0.5)),
              const SizedBox(height: 8),
              ...tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $tip',
                        style: t.bodyMedium?.copyWith(
                          color: VeinTheme.cream.withValues(alpha: 0.78),
                          height: 1.2,
                        )),
                  )),
            ] else
              Text(
                'Move with control, breathe steady, stop if pain.',
                style: t.bodyMedium?.copyWith(
                  color: VeinTheme.cream.withValues(alpha: 0.78),
                  height: 1.25,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 160.ms);
  }
}

class _EffortDialog extends StatefulWidget {
  const _EffortDialog({required this.total});
  final Duration total;

  @override
  State<_EffortDialog> createState() => _EffortDialogState();
}

class _EffortDialogState extends State<_EffortDialog> {
  double _effort = 6;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final minutes = widget.total.inMinutes;
    final seconds = (widget.total.inSeconds % 60).toString().padLeft(2, '0');
    return AlertDialog(
      backgroundColor: VeinTheme.maroonDeep,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text('Nice work.', style: t.titleLarge?.copyWith(letterSpacing: 0.6)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total time: $minutes:$seconds',
              style: t.bodyMedium?.copyWith(color: VeinTheme.cream.withValues(alpha: 0.82))),
          const SizedBox(height: 16),
          Text('How hard was it?', style: t.titleMedium?.copyWith(letterSpacing: 0.4)),
          Slider(
            value: _effort,
            min: 1,
            max: 10,
            divisions: 9,
            label: _effort.round().toString(),
            activeColor: VeinTheme.cream,
            inactiveColor: VeinTheme.cream.withValues(alpha: 0.18),
            onChanged: (v) => setState(() => _effort = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Skip', style: TextStyle(color: VeinTheme.cream.withValues(alpha: 0.9))),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_effort.round()),
          child: const Text('Save', style: TextStyle(letterSpacing: 0.5)),
        ),
      ],
    ).animate().fadeIn(duration: 160.ms);
  }
}
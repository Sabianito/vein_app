import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../routing/vein_router.dart';
import '../../../providers/app_session.dart';
import '../../../core/theme/vein_theme.dart';
import '../../../models/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.session, this.onSwitchTab});

  final AppSession session;
  final void Function(int index)? onSwitchTab;

  @override
  Widget build(BuildContext context) {
    final history = session.history;
    final streak = _computeStreak(history.map((e) => e.completedAt).toList());
    final last = history.isEmpty ? null : history.last.completedAt;
    final displayName = session.user?.displayName;
    final userName = (displayName != null && displayName.trim().isNotEmpty)
        ? displayName
        : 'demo';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome Back!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 4),
              _DayGreetingBanner().animate().fadeIn(delay: 30.ms, duration: 300.ms),
              const SizedBox(height: 4),
              _GoalBanner(session: session).animate().fadeIn(delay: 50.ms, duration: 300.ms),
              const SizedBox(height: 4),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: VeinTheme.maroonDeep.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(VeinRoutes.workoutsHub);
                          },
                          child: Text(
                            'START WORKOUT',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: VeinTheme.maroonDeep,
                                  letterSpacing: 1.4,
                                ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 80.ms, duration: 220.ms),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: _StreakStat(
                              streak: streak,
                              last: last,
                              history: history.map((e) => e.completedAt).toList(),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _SessionsStat(count: history.length),
                          ),
                        ],
                      ).animate().fadeIn(delay: 140.ms, duration: 220.ms),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Divider(color: VeinTheme.cream.withValues(alpha: 0.18), thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('\u2726', style: TextStyle(color: VeinTheme.cream.withValues(alpha: 0.35), fontSize: 11)),
                        ),
                        Expanded(child: Divider(color: VeinTheme.cream.withValues(alpha: 0.18), thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"I can do all things through Christ which strengtheneth me."',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: VeinTheme.cream.withValues(alpha: 0.82),
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.2,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Philippians 4:13',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: VeinTheme.cream.withValues(alpha: 0.45),
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _computeStreak(List<DateTime> history) {
    if (history.isEmpty) return 0;

    final days = history
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final yesterdayKey = todayKey.subtract(const Duration(days: 1));

    if (!days.contains(todayKey) && !days.contains(yesterdayKey)) return 0;

    int streak = 0;
    DateTime check = days.contains(todayKey) ? todayKey : yesterdayKey;

    while (days.contains(check)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }

    return streak;
  }
}

class _StreakStat extends StatelessWidget {
  const _StreakStat({required this.streak, required this.last, required this.history});

  final int streak;
  final DateTime? last;
  final List<DateTime> history;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final activeDays = history.map((d) => DateTime(d.year, d.month, d.day)).toSet();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workout Streak', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: VeinTheme.cream.withValues(alpha: 0.65), letterSpacing: 0.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text('$streak DAYS', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = today.subtract(Duration(days: 6 - i));
              final key = DateTime(day.year, day.month, day.day);
              final active = activeDays.contains(key);
              return Column(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? VeinTheme.cream.withValues(alpha: 0.90)
                          : VeinTheme.cream.withValues(alpha: 0.15),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_dayInitial(day.weekday),
                      style: TextStyle(fontSize: 9, color: VeinTheme.cream.withValues(alpha: 0.40), fontWeight: FontWeight.w600)),
                ],
              );
            }),
          ),
          const SizedBox(height: 10),
          Text('Last: ${last == null ? '\u2014' : DateFormat('MMM d').format(last!)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: VeinTheme.cream.withValues(alpha: 0.55))),
        ],
      ),
    );
  }

  String _dayInitial(int weekday) {
    const initials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return initials[weekday - 1];
  }
}

class _SessionsStat extends StatelessWidget {
  const _SessionsStat({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final milestone = ((count ~/ 10) + 1) * 10;
    final progress = (count % 10) / 10.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Sessions', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: VeinTheme.cream.withValues(alpha: 0.65), letterSpacing: 0.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text('$count', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: VeinTheme.cream.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(VeinTheme.cream.withValues(alpha: 0.80)),
            ),
          ),
          const SizedBox(height: 8),
          Text('${(progress * 100).round()}% to $milestone',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: VeinTheme.cream.withValues(alpha: 0.55))),
          const SizedBox(height: 2),
          Text('Keep going', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: VeinTheme.cream.withValues(alpha: 0.40), fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _DayGreetingBanner extends StatelessWidget {
  const _DayGreetingBanner();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final String greeting;
    final String icon;
    if (hour < 12) {
      greeting = 'Good morning \u2014 time to rise & grind.';
      icon = '\uD83C\uDF05';
    } else if (hour < 17) {
      greeting = 'Good afternoon \u2014 push through.';
      icon = '\u2600\uFE0F';
    } else {
      greeting = 'Good evening \u2014 finish strong.';
      icon = '\uD83C\uDF19';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text(greeting, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: VeinTheme.cream.withValues(alpha: 0.60),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              fontStyle: FontStyle.italic)),
      ],
    );
  }
}


class _GoalBanner extends StatelessWidget {
  const _GoalBanner({required this.session});
  final AppSession session;

  @override
  Widget build(BuildContext context) {
    final goal = session.userPreferences.dailyGoal;
    final message = switch (goal) {
      DailyGoal.strength => '\uD83D\uDCAA Goal: Build Strength',
      DailyGoal.fatLoss => '\uD83D\uDD25 Goal: Fat Loss',
      DailyGoal.consistency => '\uD83C\uDFAF Goal: Stay Consistent',
    };
    return Text(
      message,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: VeinTheme.cream.withValues(alpha: 0.55),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: VeinTheme.cardWhite.withValues(alpha: 0.10),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: VeinTheme.cream.withValues(alpha: 0.14)),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../providers/app_session.dart';
import '../../../core/theme/vein_theme.dart';
import '../../workout/data/workout_catalog.dart';

String _categoryLabel(WorkoutCategory c) {
  switch (c) {
    case WorkoutCategory.push: return 'Push';
    case WorkoutCategory.pull: return 'Pull';
    case WorkoutCategory.legs: return 'Legs';
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.session});

  final AppSession session;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final history = session.history;
    final totalSessions = history.length;
    final totalSeconds = history.fold<int>(0, (sum, e) => sum + e.totalSeconds);
    final totalMinutes = (totalSeconds / 60).floor();

    final streak = _computeStreak(history.map((e) => e.completedAt).toList());
    final last = history.isEmpty ? null : history.last.completedAt;

    final byCategory = <WorkoutCategory, int>{
      WorkoutCategory.push: 0,
      WorkoutCategory.pull: 0,
      WorkoutCategory.legs: 0,
    };
    for (final e in history) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + 1;
    }

    final recent = history.length <= 5
        ? history.reversed.toList()
        : history.reversed.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Progress', style: t.titleLarge?.copyWith(letterSpacing: 0.7)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
        children: [
          Text(
            'Your warm-up journey',
            style: t.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
              letterSpacing: 0.15,
              fontStyle: FontStyle.italic,
            ),
          ).animate().fadeIn(duration: 200.ms),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_month_rounded,
                  label: 'Total Sessions',
                  value: '$totalSessions',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.schedule_rounded,
                  label: 'Total Time',
                  value: '${totalMinutes}m',
                ),
              ),
            ],
          ).animate().fadeIn(delay: 60.ms, duration: 220.ms),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Day Streak',
                  value: '$streak',
                  accent: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up_rounded,
                  label: 'Last Workout',
                  value: last == null ? '\u2014' : DateFormat('MMM d').format(last),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 120.ms, duration: 220.ms),

          const SizedBox(height: 18),

          _ChartCard(byCategory: byCategory)
              .animate()
              .fadeIn(delay: 170.ms, duration: 240.ms),

          const SizedBox(height: 18),

          if (recent.isNotEmpty)
            _RecentSessionsCard(sessions: recent)
                .animate()
                .fadeIn(delay: 220.ms, duration: 240.ms),
        ],
      ),
    );
  }

  int _computeStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    final days = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    int streak = 1;
    for (int i = days.length - 1; i > 0; i--) {
      final diff = days[i].difference(days[i - 1]).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff > 1) {
        break;
      }
    }
    return streak;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: VeinTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent
              ? VeinTheme.maroonDeep.withValues(alpha: 0.30)
              : VeinTheme.maroonDeep.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: VeinTheme.maroonDeep.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: VeinTheme.maroonDeep.withValues(alpha: accent ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: VeinTheme.maroonDeep.withValues(alpha: accent ? 1.0 : 0.75),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: t.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: VeinTheme.maroonDeep,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: t.bodySmall?.copyWith(
                    color: VeinTheme.maroonDeep.withValues(alpha: 0.55),
                    letterSpacing: 0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.byCategory});

  final Map<WorkoutCategory, int> byCategory;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final entries = [
      (label: 'Push', value: byCategory[WorkoutCategory.push] ?? 0),
      (label: 'Pull', value: byCategory[WorkoutCategory.pull] ?? 0),
      (label: 'Legs', value: byCategory[WorkoutCategory.legs] ?? 0),
    ];
    final maxV = entries.fold<int>(1, (m, e) => e.value > m ? e.value : m);
    final total = entries.fold<int>(0, (s, e) => s + e.value);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: VeinTheme.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: VeinTheme.maroonDeep.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: VeinTheme.maroonDeep.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'By Muscle Group',
                style: t.titleSmall?.copyWith(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                  color: VeinTheme.maroonDeep,
                ),
              ),
              Text(
                '$total total',
                style: t.bodySmall?.copyWith(
                  color: VeinTheme.maroonDeep.withValues(alpha: 0.45),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...entries.map((e) => _HorizontalBar(
                label: e.label,
                value: e.value,
                maxV: maxV,
              )),
        ],
      ),
    );
  }
}

class _HorizontalBar extends StatelessWidget {
  const _HorizontalBar({
    required this.label,
    required this.value,
    required this.maxV,
  });

  final String label;
  final int value;
  final int maxV;

  @override
  Widget build(BuildContext context) {
    final ratio = maxV == 0 ? 0.0 : (value / maxV).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: VeinTheme.maroonDeep.withValues(alpha: 0.65),
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: VeinTheme.maroonDeep.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio == 0 ? 0.02 : ratio,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: VeinTheme.maroonDeep.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 24,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: VeinTheme.maroonDeep.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentSessionsCard extends StatelessWidget {
  const _RecentSessionsCard({required this.sessions});

  final List<dynamic> sessions;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
      decoration: BoxDecoration(
        color: VeinTheme.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: VeinTheme.maroonDeep.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: VeinTheme.maroonDeep.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Sessions',
            style: t.titleSmall?.copyWith(
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
              color: VeinTheme.maroonDeep,
            ),
          ),
          const SizedBox(height: 14),
          ...sessions.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final mins = (e.totalSeconds / 60).floor();
            final isLast = i == sessions.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 0
                            ? VeinTheme.maroonDeep
                            : VeinTheme.maroonDeep.withValues(alpha: 0.25),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 1.5,
                        height: 42,
                        color: VeinTheme.maroonDeep.withValues(alpha: 0.10),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 12 : 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _categoryLabel(e.category),
                              style: t.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: VeinTheme.maroonDeep,
                              ),
                            ),
                            Text(
                              DateFormat('EEE, MMM d').format(e.completedAt),
                              style: t.bodySmall?.copyWith(
                                color: VeinTheme.maroonDeep.withValues(alpha: 0.50),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: VeinTheme.maroonDeep.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${mins}m',
                            style: t.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: VeinTheme.maroonDeep.withValues(alpha: 0.70),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../routing/vein_router.dart';
import '../../../providers/app_session.dart';
import '../../../core/theme/vein_theme.dart';
import '../../../core/widgets/pressable.dart';
import '../data/workout_catalog.dart';

class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({
    super.key,
    required this.session,
    required this.category,
  });

  final AppSession session;
  final WorkoutCategory category;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final plans = WorkoutCatalog.plansFor(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (category) {
            WorkoutCategory.push => 'Push',
            WorkoutCategory.pull => 'Pull',
            WorkoutCategory.legs => 'Legs',
          },
          style: const TextStyle(letterSpacing: 0.8),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: [
          Text(
            'Are you ready?',
            style: t.bodyMedium?.copyWith(
              color: VeinTheme.cream.withValues(alpha: 0.76),
              letterSpacing: 0.3,
            ),
          ).animate().fadeIn(duration: 200.ms),
          const SizedBox(height: 14),
          ...plans.indexed.map((e) {
            final i = e.$1;
            final plan = session.adaptPlan(e.$2);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PlanCard(
                plan: plan,
                onTap: () => Navigator.of(context).pushNamed(
                  VeinRoutes.workoutPlayer,
                  arguments: plan,
                ),
              ).animate().fadeIn(delay: (60 + i * 60).ms, duration: 200.ms),
            );
          }),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.onTap});

  final WorkoutPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final blockCount = plan.blocks.where((b) => b.kind == WorkoutBlockKind.exercise).length;
    final equip = plan.requiredEquipment
        .where((e) => e != Equipment.bodyweight)
        .map((e) => switch (e) {
              Equipment.dumbbells => 'Dumbbells',
              Equipment.pullUpBar => 'Pull-up bar',
              Equipment.resistanceBand => 'Band',
              Equipment.benchOrChair => 'Bench/Chair',
              Equipment.yogaMat => 'Mat',
              Equipment.bodyweight => 'Bodyweight',
            })
        .toList();

    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: VeinTheme.cream.withValues(alpha: 0.14)),
          gradient: LinearGradient(
            colors: [
              VeinTheme.maroonDeep.withValues(alpha: 0.6),
              VeinTheme.maroonDeep.withValues(alpha: 0.25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: t.titleMedium?.copyWith(letterSpacing: 0.6, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$blockCount exercises'
                    '${equip.isEmpty ? '' : ' \u2022 ${equip.join(' \u2022 ')}'}',
                    style: t.bodyMedium?.copyWith(
                      color: VeinTheme.cream.withValues(alpha: 0.76),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_arrow_rounded, color: VeinTheme.cream.withValues(alpha: 0.9)),
          ],
        ),
      ),
    );
  }
}

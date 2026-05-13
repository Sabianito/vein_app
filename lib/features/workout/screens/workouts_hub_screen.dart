import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../routing/vein_router.dart';
import '../../../providers/app_session.dart';
import '../../../core/theme/vein_theme.dart';
import '../../../core/widgets/pressable.dart';
import '../data/workout_catalog.dart';

class WorkoutsHubScreen extends StatelessWidget {
  const WorkoutsHubScreen({super.key, required this.session});

  final AppSession session;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a workout', style: t.titleLarge?.copyWith(letterSpacing: 0.7)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 26),
        children: [
          _tile(context, title: 'Push', subtitle: 'Chest \u2022 Shoulders \u2022 Triceps',
            icon: Icons.sports_martial_arts_rounded, category: WorkoutCategory.push,
            gifPath: 'assets/images/pikeupss.gif', delayMs: 70),
          const SizedBox(height: 12),
          _tile(context, title: 'Pull', subtitle: 'Back \u2022 Biceps',
            icon: Icons.fitness_center_rounded, category: WorkoutCategory.pull,
            gifPath: 'assets/images/invertedpulls.gif', delayMs: 120),
          const SizedBox(height: 12),
          _tile(context, title: 'Legs', subtitle: 'Lower body',
            icon: Icons.directions_run_rounded, category: WorkoutCategory.legs,
            gifPath: 'assets/images/airsquats.gif', delayMs: 170),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required WorkoutCategory category,
    required String gifPath,
    required int delayMs,
  }) {
    final t = Theme.of(context).textTheme;
    return Pressable(
      onTap: () => Navigator.of(context).pushNamed(VeinRoutes.workoutList, arguments: category),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: VeinTheme.cardWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: VeinTheme.maroonDeep.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: VeinTheme.maroonDeep.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(gifPath, fit: BoxFit.contain, gaplessPlayback: true),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.titleMedium?.copyWith(
                    letterSpacing: 0.5, fontWeight: FontWeight.w700, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: t.bodyMedium?.copyWith(
                    color: Colors.black87, letterSpacing: 0.1)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: VeinTheme.maroonDeep.withValues(alpha: 0.5)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delayMs.ms, duration: 220.ms);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../routing/vein_router.dart';
import '../../../providers/app_session.dart';
import '../../../core/theme/vein_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.session});

  final AppSession session;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;

    final next = widget.session.isAuthed ? VeinRoutes.home : VeinRoutes.auth;
    Navigator.of(context).pushReplacementNamed(next);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: VeinTheme.cream.withValues(alpha: 0.22)),
                  gradient: LinearGradient(
                    colors: [
                      VeinTheme.maroonDeep.withValues(alpha: 0.7),
                      VeinTheme.maroonDeep.withValues(alpha: 0.28),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: VeinTheme.cream.withValues(alpha: 0.92),
                  size: 34,
                ),
              )
                  .animate()
                  .fadeIn(duration: 260.ms, curve: Curves.easeOutCubic)
                  .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),
              const SizedBox(height: 14),
              Text(
                'vein',
                style: t.headlineSmall?.copyWith(
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 90.ms, duration: 240.ms),
              const SizedBox(height: 6),
              Text(
                'home workouts, made elegant',
                style: t.bodyMedium?.copyWith(
                  color: VeinTheme.cream.withValues(alpha: 0.76),
                  letterSpacing: 0.6,
                ),
              ).animate().fadeIn(delay: 140.ms, duration: 240.ms),
            ],
          ),
        ),
      ),
    );
  }
}

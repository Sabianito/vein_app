import 'package:flutter/material.dart';

import '../features/auth/screens/auth_screen.dart';
import '../features/shell/screens/shell_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/workout/screens/workout_list_screen.dart';
import '../features/workout/screens/workout_player_screen.dart';
import '../features/workout/screens/workouts_hub_screen.dart';
import '../providers/app_session.dart';
import '../features/workout/data/workout_catalog.dart';

sealed class VeinRoutes {
  static const splash = '/';
  static const auth = '/auth';
  static const home = '/home';
  static const workoutsHub = '/workouts-hub';
  static const workoutList = '/workouts';
  static const workoutPlayer = '/workout';
  static const progress = '/progress';
  static const profile = '/profile';
}

class VeinRouter {
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    required AppSession session,
  }) {
    switch (settings.name) {
      case VeinRoutes.splash:
        return _fade(settings, SplashScreen(session: session));

      case VeinRoutes.auth:
        return _fade(settings, AuthScreen(session: session));

      case VeinRoutes.home:
        return _fade(settings, ShellScreen(session: session));

      case VeinRoutes.workoutsHub:
        return _fade(settings, WorkoutsHubScreen(session: session));

      case VeinRoutes.workoutList:
        final category = settings.arguments as WorkoutCategory?;
        return _fade(
          settings,
          WorkoutListScreen(
            session: session,
            category: category ?? WorkoutCategory.push,
          ),
        );

      case VeinRoutes.workoutPlayer:
        final plan = settings.arguments as WorkoutPlan?;
        if (plan == null) {
          return _fade(settings, ShellScreen(session: session));
        }
        return _slide(settings, WorkoutPlayerScreen(session: session, plan: plan));

      case VeinRoutes.progress:
        return _fade(settings, ShellScreen(session: session));

      case VeinRoutes.profile:
        return _fade(settings, ShellScreen(session: session));

      default:
        return _fade(settings, SplashScreen(session: session));
    }
  }

  static PageRouteBuilder<void> _fade(RouteSettings settings, Widget child) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(opacity: curved, child: child);
      },
    );
  }

  static PageRouteBuilder<void> _slide(RouteSettings settings, Widget child) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 240),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.07, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }
}

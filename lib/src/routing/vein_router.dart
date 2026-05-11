import 'package:flutter/material.dart';



import '../screens/auth/auth_screen.dart';

import '../screens/shell/shell_screen.dart';

import '../screens/splash/splash_screen.dart';

import '../screens/workout/workout_list_screen.dart';

import '../screens/workout/workout_player_screen.dart';

import '../screens/workouts/workouts_hub_screen.dart';

import '../state/app_session.dart';

import '../workouts/workout_catalog.dart';



sealed class VeinRoutes {

  static const splash = '/';

  static const auth = '/auth';

  static const home = '/home';

  static const workoutsHub = '/workouts-hub';

  static const workoutList = '/workouts';

  static const workoutPlayer = '/workout';

  static const progress = '/progress';   // ✅ Added

  static const profile = '/profile';     // ✅ Added

}



class VeinRouter {

  static Route<dynamic> onGenerateRoute(

    RouteSettings settings, {

    required AppSession session,

  }) {

    switch (settings.name) {

      case VeinRoutes.splash:

        return _fade(

          settings,

          SplashScreen(session: session),

        );

      case VeinRoutes.auth:

        return _fade(

          settings,

          AuthScreen(session: session),

        );

      case VeinRoutes.home:

        return _fade(

          settings,

          ShellScreen(session: session),

        );

      case VeinRoutes.workoutsHub:

        return _fade(

          settings,

          WorkoutsHubScreen(session: session),

        );

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

      case VeinRoutes.progress:   // ✅ Added

        return _fade(settings, ShellScreen(session: session)); // replace with ProgressScreen when ready

      case VeinRoutes.profile:    // ✅ Added

        return _fade(settings, ShellScreen(session: session)); // replace with ProfileScreen when ready

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

        return FadeTransition(

          opacity: curved,

          child: child,

        );

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
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'routing/vein_router.dart';
import 'state/app_session.dart';

class VeinApp extends StatefulWidget {
  const VeinApp({super.key, required this.theme});

  final ThemeData theme;

  @override
  State<VeinApp> createState() => _VeinAppState();
}

class _VeinAppState extends State<VeinApp> {
  final _session = AppSession();

  @override
  void initState() {
    super.initState();
    Animate.restartOnHotReload = true;
    _session.init();
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _session,
      builder: (context, _) {
        return MaterialApp(
          title: 'vein',
          debugShowCheckedModeBanner: false,
          theme: widget.theme,
          onGenerateRoute: (settings) =>
              VeinRouter.onGenerateRoute(settings, session: _session),
          initialRoute: VeinRoutes.splash,
        );
      },
    );
  }
}


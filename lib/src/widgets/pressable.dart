import 'package:flutter/material.dart';

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.enabled = true,
    this.scaleDownTo = 0.98,
    this.duration = const Duration(milliseconds: 110),
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final double scaleDownTo;
  final Duration duration;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scale = _down ? widget.scaleDownTo : 1.0;
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      onTapDown: widget.enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _down = false) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: scale,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}


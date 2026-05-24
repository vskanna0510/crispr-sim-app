// Tap scale + hover lift — desktop / web / trackpad polish.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InteractiveSurface extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final double hoverScale;
  final Duration hoverDuration;
  final bool haptic;

  const InteractiveSurface({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.hoverScale = 1.028,
    this.hoverDuration = const Duration(milliseconds: 220),
    this.haptic = true,
  });

  @override
  State<InteractiveSurface> createState() => _InteractiveSurfaceState();
}

class _InteractiveSurfaceState extends State<InteractiveSurface>
    with TickerProviderStateMixin {
  late AnimationController _press;
  late AnimationController _hover;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _pressAnim = Tween<double>(begin: 1, end: widget.pressedScale).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
    _hover = AnimationController(vsync: this, duration: widget.hoverDuration);
  }

  @override
  void dispose() {
    _press.dispose();
    _hover.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) => _press.forward();
  void _up(TapUpDetails _) => _press.reverse();
  void _cancel() => _press.reverse();

  void _tap() {
    if (widget.haptic) HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _hover.forward(),
      onExit: (_) => _hover.reverse(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _down,
        onTapUp: _up,
        onTapCancel: _cancel,
        onTap: _tap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_press, _hover]),
          builder: (context, _) {
            final ht = Curves.easeOutCubic.transform(_hover.value);
            final lift = 1 + (widget.hoverScale - 1) * ht;
            return Transform.scale(
              scale: lift * _pressAnim.value,
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

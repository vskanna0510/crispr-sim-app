// Staggered fade + slide-in for column children (results screens, lists).

import 'package:flutter/material.dart';

class StaggerColumn extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;

  const StaggerColumn({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<StaggerColumn> createState() => _StaggerColumnState();
}

class _StaggerColumnState extends State<StaggerColumn>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.children.length;
    if (n == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(n, (i) {
        final stagger = n <= 1 ? 0.0 : i / (n + 2);
        const window = 0.45;
        final anim = CurvedAnimation(
          parent: _c,
          curve: Interval(
            stagger.clamp(0.0, 0.75),
            (stagger + window).clamp(0.25, 1.0),
            curve: Curves.easeOutCubic,
          ),
        );
        return AnimatedBuilder(
          animation: anim,
          builder: (context, child) {
            return Opacity(
              opacity: anim.value,
              child: Transform.translate(
                offset: Offset(0, 16 * (1 - anim.value)),
                child: child,
              ),
            );
          },
          child: widget.children[i],
        );
      }),
    );
  }
}

/// Single row in a list with staggered index (parent drives one shared controller).
class StaggerListTile extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final int total;
  final Widget child;

  const StaggerListTile({
    super.key,
    required this.index,
    required this.controller,
    required this.total,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final stagger = total <= 1 ? 0.0 : index / (total + 2);
    const window = 0.35;
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(
        stagger.clamp(0.0, 0.8),
        (stagger + window).clamp(0.2, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(24 * (1 - anim.value), 0),
            child: child,
          ),
        );
      },
    );
  }
}

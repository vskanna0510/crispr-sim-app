// Frosted-glass surfaces (backdrop blur + translucent tint + rim light).

import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/constants.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blurSigma;

  /// Blended into the glass gradient for chromatic accents.
  final Color accentTint;

  /// Outer soft glow (not clipped).
  final List<BoxShadow>? boxShadow;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = kRadius,
    this.blurSigma = 18,
    this.accentTint = Colors.white,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final rim = dark
        ? Colors.white.withAlpha(48)
        : Colors.white.withAlpha(150);
    final innerTop = dark
        ? Colors.white.withAlpha(32)
        : Colors.white.withAlpha(90);
    final innerBot = accentTint.withAlpha(dark ? 40 : 52);

    final shadow = boxShadow ??
        [
          BoxShadow(
            color: accentTint.withAlpha(dark ? 35 : 55),
            blurRadius: 22,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ];

    final inner = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: rim, width: 1.2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(innerTop, accentTint, 0.14)!,
                Color.lerp(innerBot, accentTint, 0.1)!,
              ],
            ),
          ),
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius + 1),
        boxShadow: shadow,
      ),
      child: inner,
    );
  }
}

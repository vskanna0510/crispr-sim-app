import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Full-screen gradient backdrop matching the home / PAM scanner aesthetic.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            Color.lerp(cs.surface, cs.primaryContainer, 0.45)!,
            Color.lerp(cs.surface, const Color(0xFF004D4D), 0.35)!,
            Color.lerp(cs.surface, cs.tertiaryContainer, 0.25)!,
          ],
          stops: const [0.0, 0.35, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// Dark elevated panel for forms and settings sections.
class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(kPadLg),
    this.accentBorder,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accentBorder;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF1E1E1E) : cs.surface;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(
          color: accentBorder ?? (dark ? kAccentTeal.withAlpha(60) : cs.outline.withAlpha(80)),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(dark ? 80 : 25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

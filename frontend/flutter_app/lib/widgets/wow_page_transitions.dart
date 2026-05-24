// Custom route transitions — cohesive fade + slide + slight scale (“wow” without jarring motion).

import 'package:flutter/material.dart';

/// Use with [ThemeData.pageTransitionsTheme] so all [MaterialPageRoute]s share this motion.
class CrisprPageTransitionsBuilder extends PageTransitionsBuilder {
  const CrisprPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      ),
    );
  }
}

/// Full ThemeData map entry — pass to [ThemeData.pageTransitionsTheme].
PageTransitionsTheme get crisprPageTransitionsTheme {
  const builder = CrisprPageTransitionsBuilder();
  return const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: builder,
      TargetPlatform.iOS: builder,
      TargetPlatform.linux: builder,
      TargetPlatform.macOS: builder,
      TargetPlatform.windows: builder,
      TargetPlatform.fuchsia: builder,
    },
  );
}

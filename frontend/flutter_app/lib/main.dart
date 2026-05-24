// CRISPR-Sim Flutter Application
//
// Entry point. Sets up theme and Provider state management, then launches
// the HomeScreen.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/crispr_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';
import 'widgets/app_bootstrap.dart';
import 'widgets/rag_chat_fab.dart';
import 'widgets/wow_page_transitions.dart';

/// Used by [GlobalRagChatLayer] so Help can open a modal sheet (FAB is not under [Navigator]).
final GlobalKey<NavigatorState> crisprSimNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final provider = CrisprProvider();
        provider.loadCasSystems();
        return provider;
      },
      child: const CrisprSimApp(),
    ),
  );
}

class CrisprSimApp extends StatelessWidget {
  const CrisprSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: crisprSimNavigatorKey,
      title: 'CRISPR-Sim',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      builder: (context, child) {
        return GlobalRagChatLayer(
          navigatorKey: crisprSimNavigatorKey,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppBootstrap(child: HomeScreen()),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final cs = ColorScheme.fromSeed(
      seedColor: kPrimary,
      secondary: const Color(0xFFE040FB),
      tertiary: const Color(0xFFFF6E40),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      pageTransitionsTheme: crisprPageTransitionsTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius),
        ),
      ),
    );
  }
}

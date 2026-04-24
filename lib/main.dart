// CRISPR-Sim Flutter Application
//
// Entry point. Sets up theme and Provider state management, then launches
// the HomeScreen.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/crispr_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CrisprProvider(),
      child: const CrisprSimApp(),
    ),
  );
}

class CrisprSimApp extends StatelessWidget {
  const CrisprSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRISPR-Sim',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final cs = ColorScheme.fromSeed(
      seedColor: kPrimary,
      secondary: kSecondary,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
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

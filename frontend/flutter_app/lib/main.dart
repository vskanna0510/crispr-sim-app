// CRISPR-Sim Flutter Application

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/crispr_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';
import 'widgets/app_bootstrap.dart';
import 'widgets/rag_chat_fab.dart';
import 'widgets/wow_page_transitions.dart';

final GlobalKey<NavigatorState> crisprSimNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthProvider();
  final theme = ThemeProvider();
  await theme.bootstrap();
  runApp(CrisprSimRoot(auth: auth, theme: theme));
  auth.bootstrap();
}

class CrisprSimRoot extends StatelessWidget {
  const CrisprSimRoot({super.key, required this.auth, required this.theme});

  final AuthProvider auth;
  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<ThemeProvider>.value(value: theme),
        ChangeNotifierProvider(
          create: (_) => CrisprProvider(api: auth.api)..loadCasSystems(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(api: auth.api),
        ),
      ],
      child: const CrisprSimApp(),
    );
  }
}

class CrisprSimApp extends StatelessWidget {
  const CrisprSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      navigatorKey: crisprSimNavigatorKey,
      title: 'CRISPR-Sim',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: theme.themeMode,
      builder: (context, child) {
        return GlobalRagChatLayer(
          navigatorKey: crisprSimNavigatorKey,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AuthGate(),
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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isBootstrapped) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }
    return const AppBootstrap(child: HomeScreen());
  }
}

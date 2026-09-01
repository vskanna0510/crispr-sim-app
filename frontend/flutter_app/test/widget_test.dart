// Basic smoke test: verify the app renders without crashing.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:crispr_sim/main.dart';
import 'package:crispr_sim/providers/auth_provider.dart';
import 'package:crispr_sim/providers/crispr_provider.dart';
import 'package:crispr_sim/providers/settings_provider.dart';
import 'package:crispr_sim/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App renders HomeScreen without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final auth = AuthProvider()..skipAuthForTesting();
    final theme = ThemeProvider();
    await theme.bootstrap();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<ThemeProvider>.value(value: theme),
          ChangeNotifierProvider(
            create: (_) => CrisprProvider(api: auth.api),
          ),
          ChangeNotifierProvider(
            create: (_) => SettingsProvider(api: auth.api),
          ),
        ],
        child: const CrisprSimApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 4000));
    expect(find.text('CRISPR-Sim'), findsOneWidget);
  });
}

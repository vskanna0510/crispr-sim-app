// Basic smoke test: verify the app renders without crashing.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:crispr_sim/main.dart';
import 'package:crispr_sim/providers/crispr_provider.dart';

void main() {
  testWidgets('App renders HomeScreen without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CrisprProvider(),
        child: const CrisprSimApp(),
      ),
    );
    // HomeScreen should show the app title
    expect(find.text('CRISPR-Sim'), findsOneWidget);
  });
}

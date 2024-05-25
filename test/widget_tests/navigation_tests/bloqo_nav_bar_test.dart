import 'package:bloqo/components/navigation/bloqo_nav_bar.dart';
import 'package:bloqo/utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int selectedIndex;

  setUp(() {
    selectedIndex = 0;
  });

  Widget buildTestWidget() {
    return MaterialApp(
      localizationsDelegates: getLocalizationDelegates(),
      supportedLocales: getSupportedLocales(),
      home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Container(),
              bottomNavigationBar: BloqoNavBar(
                onDestinationSelected: (int index) {
                  selectedIndex = index;
                },
              ),
            );
          }
      ),
    );
  }

  testWidgets('Nav bar present', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    expect(find.byType(BloqoNavBar), findsOneWidget);
  });

  testWidgets('Nav bar registers change', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.tap(find.text(getAppLocalizations(tester.element(find.byType(BloqoNavBar)))!.search)); // Assuming 'Search' is a valid label in BloqoNavBar
    await tester.pumpAndSettle(); // Wait for animations and state changes
    expect(selectedIndex, 2);
  });
}

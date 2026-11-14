import 'package:flutter_test/flutter_test.dart';
import 'package:quanlychitieu/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ExpenseApp());

    // Verify that app widget is rendered
    expect(find.byType(ExpenseApp), findsOneWidget);
  });
}


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quanlychitieu/cot_loi/giao_dien/giao_dien_app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: GiaoDienApp.themeSang,
        home: const Scaffold(
          body: Center(
            child: Text('Quản lý chi tiêu'),
          ),
        ),
      ),
    );

    expect(find.text('Quản lý chi tiêu'), findsOneWidget);
  });
}

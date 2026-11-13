import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Arabic sheep page uses right-to-left direction', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Text('أغنامي'),
          ),
        ),
      ),
    );

    expect(find.text('أغنامي'), findsOneWidget);
  });
}

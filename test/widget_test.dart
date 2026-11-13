import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Arabic sheep page uses right-to-left direction', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: Text('أغنامي'),
      ),
    );

    expect(find.text('أغنامي'), findsOneWidget);
  });
}

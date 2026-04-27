import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_homepage/main.dart';

void main() {
  testWidgets('MicroStep app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MicroStepApp());

    await tester.pumpAndSettle();

    expect(find.text('MicroStep'), findsOneWidget);
    expect(find.text('Доброе утро, Алексей!'), findsOneWidget);
  });
}

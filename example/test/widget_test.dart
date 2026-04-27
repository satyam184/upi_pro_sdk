import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('renders demo screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('UPI Pro SDK Example'), findsOneWidget);
    expect(find.text('Refresh Installed Apps'), findsOneWidget);
    expect(find.text('Pay With Picker'), findsOneWidget);
  });
}

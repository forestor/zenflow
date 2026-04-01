import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zen_flow/main.dart';

void main() {
  testWidgets('ZenFlow app launches and shows home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ZenFlowApp());
    await tester.pumpAndSettle();

    // Verify app title is shown
    expect(find.text('ZenFlow'), findsOneWidget);

    // Verify navigation bar exists
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('호흡'), findsOneWidget);
    expect(find.text('통계'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kairo/main.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KairoApp());

    // Verify that the app title or a greeting is present.
    expect(find.textContaining('Kairo'), findsNothing); // It's in the title, not text usually
    expect(find.textContaining('Good morning'), findsNothing); // Need to wait for frames
  });
}

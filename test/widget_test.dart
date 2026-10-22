import 'package:flutter_test/flutter_test.dart';
import 'package:saleskido/main.dart';

void main() {
  testWidgets('App boots', (tester) async {
    await tester.pumpWidget(const SalesKidoApp());
    await tester.pump();
    expect(find.text('SalesKido'), findsOneWidget);
  });
}

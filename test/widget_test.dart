
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_space/main.dart';

void main() {
  testWidgets('PrepSpace launches and displays its navigation tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PrepSpaceApp());

    // Verify the dashboard loads.
    expect(find.text('PREPSPACE'), findsOneWidget);
    expect(find.text('Your preparation,'), findsOneWidget);

    // Verify all five navigation tabs exist.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tracker'), findsOneWidget);
    expect(find.text('Spaces'), findsOneWidget);
    expect(find.text('Resources'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify navigation to the Tracker screen works.
    await tester.tap(find.text('Tracker'));
    await tester.pumpAndSettle();

    expect(find.text('Preparation Tracker'), findsOneWidget);
  });
}

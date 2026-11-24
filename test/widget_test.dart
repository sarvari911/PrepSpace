import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prep_space/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'PrepSpace launches, displays navigation tabs and supports interactive flow',
      (WidgetTester tester) async {
    // Set standard mobile device test screen size so all widgets fit without clipping
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: PrepSpaceApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Dashboard header and branding
    expect(find.text('PREPSPACE'), findsOneWidget);
    expect(find.text('Your preparation,'), findsOneWidget);
    expect(find.text('your progress.'), findsOneWidget);

    // 2. Verify all five bottom navigation tabs exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tracker'), findsOneWidget);
    expect(find.text('Spaces'), findsOneWidget);
    expect(find.text('Resources'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // 3. Verify Overview cards exist
    expect(find.text('Subjects'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Day streak'), findsOneWidget);

    // 4. Test "View all" button navigates from Dashboard to Tracker
    final viewAllFinder = find.text('View all');
    expect(viewAllFinder, findsOneWidget);
    await tester.tap(viewAllFinder);
    await tester.pumpAndSettle();

    // Verify Tracker screen is displayed
    expect(find.text('Preparation Tracker'), findsOneWidget);
    expect(find.text('Organize your subjects, concepts and practical skills.'),
        findsOneWidget);

    // 5. Test navigation to placeholder tabs: Spaces, Resources, Profile
    await tester.tap(find.text('Spaces'));
    await tester.pumpAndSettle();
    expect(find.text('Study Spaces'), findsOneWidget);

    await tester.tap(find.text('Resources'));
    await tester.pumpAndSettle();
    expect(find.text('Resources'), findsWidgets);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Your Profile'), findsOneWidget);

    // 6. Return to Home
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('YOUR LEARNING JOURNEY'), findsOneWidget);
  });
}

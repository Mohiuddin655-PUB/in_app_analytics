import 'package:flutter_test/flutter_test.dart';

/// Unit and widget tests for the `your_app` Flutter application.
///
/// This test suite validates:
/// - Widget rendering and layout behavior
/// - State updates and reactive UI changes
/// - App navigation and interaction
///
/// All tests in this file run automatically via:
/// ```bash
/// flutter test
/// ```
void main() {
  /// Group of tests for verifying widget behavior and layout.
  group('Widget Tests', () {
    /// Ensures the main app renders without throwing any exceptions.
    testWidgets('App renders correctly', (WidgetTester tester) async {
      // Arrange: Load the main app widget into the testing environment.
      await tester.pumpWidget(const MyApp());

      // Act: Trigger an initial frame.
      await tester.pump();

      // Assert: Check if the expected text or widget appears in the tree.
      expect(find.text('Welcome'), findsOneWidget);
    });

    /// Validates navigation between screens.
    testWidgets('Navigation works as expected', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Act: Tap a button that should navigate to a new page.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Assert: Verify navigation occurred.
      expect(find.text('Next Page'), findsOneWidget);
    });

    /// Tests that user interaction updates the state as expected.
    testWidgets('Counter increments when button pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      // Verify initial state.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Simulate user tap on the "+" FloatingActionButton.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify state update.
      expect(find.text('1'), findsOneWidget);
    });
  });
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';

void main() {
  group('CNSearchBar', () {
    // Helper to build CNSearchBar with proper MediaQuery constraints
    Widget buildSearchBarTest({
      required Widget child,
      Size screenSize = const Size(350, 600),
    }) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: screenSize),
          child: Scaffold(body: child),
        ),
      );
    }

    testWidgets('renders with default placeholder when expanded', (tester) async {
      await tester.pumpWidget(
        buildSearchBarTest(
          child: const CNSearchBar(
            expandable: false, // Always show expanded state
            showCancelButton: false, // Avoid overflow
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Flutter fallback should show the text field
      expect(find.byType(CupertinoTextField), findsOneWidget);
    });

    testWidgets('renders with custom placeholder when expanded', (tester) async {
      await tester.pumpWidget(
        buildSearchBarTest(
          child: const CNSearchBar(
            placeholder: 'Find items...',
            expandable: false,
            showCancelButton: false,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(CupertinoTextField), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedText;

      await tester.pumpWidget(
        buildSearchBarTest(
          child: CNSearchBar(
            expandable: false, // Always expanded for easier testing
            showCancelButton: false,
            onChanged: (text) => changedText = text,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      await tester.enterText(find.byType(CupertinoTextField), 'test query');
      await tester.pump();

      expect(changedText, 'test query');
    });

    testWidgets('calls onSubmitted when search is submitted', (tester) async {
      String? submittedText;

      await tester.pumpWidget(
        buildSearchBarTest(
          child: CNSearchBar(
            expandable: false,
            showCancelButton: false,
            onSubmitted: (text) => submittedText = text,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      await tester.enterText(find.byType(CupertinoTextField), 'search term');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submittedText, 'search term');
    });

    testWidgets('shows cancel button when expanded', (tester) async {
      await tester.pumpWidget(
        buildSearchBarTest(
          screenSize: const Size(500, 600), // Wider to fit cancel button
          child: const CNSearchBar(
            expandable: false,
            initiallyExpanded: true,
            showCancelButton: true,
            cancelText: 'Cancel',
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('CNSearchBarController', () {
    test('creates controller', () {
      final controller = CNSearchBarController();
      expect(controller, isNotNull);
    });

    test('isExpanded defaults to false', () {
      final controller = CNSearchBarController();
      expect(controller.isExpanded, false);
    });
  });

  group('CNFloatingIsland', () {
    testWidgets('renders collapsed content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CNFloatingIsland(
              collapsed: Text('Collapsed'),
              expanded: Text('Expanded'),
            ),
          ),
        ),
      );

      expect(find.text('Collapsed'), findsOneWidget);
    });

    testWidgets('renders with custom position', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CNFloatingIsland(
              collapsed: Text('Bottom'),
              position: CNFloatingIslandPosition.bottom,
            ),
          ),
        ),
      );

      expect(find.text('Bottom'), findsOneWidget);
    });

    testWidgets('responds to tap callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CNFloatingIsland(
              collapsed: const Text('Tap me'),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('shows expanded content when isExpanded is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CNFloatingIsland(
              collapsed: Text('Collapsed'),
              expanded: Text('Expanded Content'),
              isExpanded: true,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Expanded Content'), findsOneWidget);
    });
  });

  group('CNFloatingIslandController', () {
    test('creates controller', () {
      final controller = CNFloatingIslandController();
      expect(controller, isNotNull);
    });

    test('isExpanded defaults to false', () {
      final controller = CNFloatingIslandController();
      expect(controller.isExpanded, false);
    });

    test('onExpandChanged callback is settable', () {
      final controller = CNFloatingIslandController();
      var callbackCalled = false;

      controller.onExpandChanged = () => callbackCalled = true;
      expect(callbackCalled, false);
    });
  });

  group('CNFloatingIslandPosition', () {
    test('has top and bottom values', () {
      expect(CNFloatingIslandPosition.values.length, 2);
      expect(
        CNFloatingIslandPosition.values,
        contains(CNFloatingIslandPosition.top),
      );
      expect(
        CNFloatingIslandPosition.values,
        contains(CNFloatingIslandPosition.bottom),
      );
    });
  });

  group('CNGlassButtonGroup', () {
    testWidgets('renders with CNButtonData list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CNGlassButtonGroup(
              buttons: [
                CNButtonData(label: 'Button 1'),
                CNButtonData(label: 'Button 2'),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Button 1'), findsOneWidget);
      expect(find.text('Button 2'), findsOneWidget);
    });

    testWidgets('renders icon buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CNGlassButtonGroup(
              buttons: [
                CNButtonData.icon(customIcon: Icons.home),
                CNButtonData.icon(customIcon: Icons.settings),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('triggers onPressed callback', (tester) async {
      var button1Pressed = false;
      var button2Pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CNGlassButtonGroup(
              buttons: [
                CNButtonData(
                  label: 'Button 1',
                  onPressed: () => button1Pressed = true,
                ),
                CNButtonData(
                  label: 'Button 2',
                  onPressed: () => button2Pressed = true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Button 1'));
      await tester.pump();
      expect(button1Pressed, true);
      expect(button2Pressed, false);

      await tester.tap(find.text('Button 2'));
      await tester.pump();
      expect(button2Pressed, true);
    });

    testWidgets('renders in vertical axis', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CNGlassButtonGroup(
              axis: Axis.vertical,
              buttons: [
                CNButtonData(label: 'Top'),
                CNButtonData(label: 'Bottom'),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
    });

    testWidgets('renders with custom spacing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CNGlassButtonGroup(
              spacing: 16.0,
              spacingForGlass: 50.0,
              buttons: [
                CNButtonData(label: 'A'),
                CNButtonData(label: 'B'),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });

  group('LiquidGlassConfig', () {
    test('creates config with defaults', () {
      const config = LiquidGlassConfig();

      expect(config.effect, CNGlassEffect.regular);
      expect(config.shape, CNGlassEffectShape.capsule);
      expect(config.cornerRadius, isNull);
      expect(config.tint, isNull);
      expect(config.interactive, false);
    });

    test('creates config with custom values', () {
      const config = LiquidGlassConfig(
        effect: CNGlassEffect.prominent,
        shape: CNGlassEffectShape.capsule,
        cornerRadius: 16.0,
        tint: Colors.blue,
        interactive: true,
      );

      expect(config.effect, CNGlassEffect.prominent);
      expect(config.shape, CNGlassEffectShape.capsule);
      expect(config.cornerRadius, 16.0);
      expect(config.tint, Colors.blue);
      expect(config.interactive, true);
    });
  });

  group('CNGlassEffect', () {
    test('has all expected values', () {
      expect(CNGlassEffect.values.length, 2);
      expect(CNGlassEffect.values, contains(CNGlassEffect.regular));
      expect(CNGlassEffect.values, contains(CNGlassEffect.prominent));
    });
  });

  group('CNGlassEffectShape', () {
    test('has all expected values', () {
      expect(CNGlassEffectShape.values.length, 3);
      expect(CNGlassEffectShape.values, contains(CNGlassEffectShape.capsule));
      expect(CNGlassEffectShape.values, contains(CNGlassEffectShape.rect));
      expect(CNGlassEffectShape.values, contains(CNGlassEffectShape.circle));
    });
  });
}

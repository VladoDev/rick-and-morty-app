import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rick_and_morty_app/features/characters/presentation/widgets/search_characters_search_bar.dart';

void main() {
  Widget pumpBar({
    required String initialValue,
    required bool isLoading,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onSubmitted,
    required VoidCallback onSearchPressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SearchCharactersSearchBar(
          initialValue: initialValue,
          isLoading: isLoading,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onSearchPressed: onSearchPressed,
        ),
      ),
    );
  }

  group('SearchCharactersSearchBar', () {
    testWidgets('initializes TextField with initialValue', (tester) async {
      await tester.pumpWidget(
        pumpBar(
          initialValue: 'Rick',
          isLoading: false,
          onChanged: (_) {},
          onSubmitted: (_) {},
          onSearchPressed: () {},
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Rick');
    });

    testWidgets('typing triggers onChanged and updates controller text', (
      tester,
    ) async {
      String? changed;

      await tester.pumpWidget(
        pumpBar(
          initialValue: '',
          isLoading: false,
          onChanged: (v) => changed = v,
          onSubmitted: (_) {},
          onSearchPressed: () {},
        ),
      );

      await tester.enterText(find.byType(TextField), 'Morty');
      await tester.pump();

      expect(changed, 'Morty');

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Morty');
    });

    testWidgets('submitting triggers onSubmitted', (tester) async {
      String? submitted;

      await tester.pumpWidget(
        pumpBar(
          initialValue: '',
          isLoading: false,
          onChanged: (_) {},
          onSubmitted: (v) => submitted = v,
          onSearchPressed: () {},
        ),
      );

      await tester.enterText(find.byType(TextField), 'Rick');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(submitted, 'Rick');
    });

    testWidgets('search button triggers onSearchPressed when not loading', (
      tester,
    ) async {
      var pressed = false;

      await tester.pumpWidget(
        pumpBar(
          initialValue: '',
          isLoading: false,
          onChanged: (_) {},
          onSubmitted: (_) {},
          onSearchPressed: () => pressed = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('disables TextField and search button when isLoading=true', (
      tester,
    ) async {
      await tester.pumpWidget(
        pumpBar(
          initialValue: 'Rick',
          isLoading: true,
          onChanged: (_) {},
          onSubmitted: (_) {},
          onSearchPressed: () {},
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets(
      'didUpdateWidget updates controller text when initialValue changes',
      (tester) async {
        await tester.pumpWidget(
          pumpBar(
            initialValue: 'Rick',
            isLoading: false,
            onChanged: (_) {},
            onSubmitted: (_) {},
            onSearchPressed: () {},
          ),
        );

        await tester.pumpWidget(
          pumpBar(
            initialValue: 'Morty',
            isLoading: false,
            onChanged: (_) {},
            onSubmitted: (_) {},
            onSearchPressed: () {},
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, 'Morty');
      },
    );

    testWidgets(
      'didUpdateWidget does NOT override user-typed text if initialValue is same',
      (tester) async {
        await tester.pumpWidget(
          pumpBar(
            initialValue: 'Rick',
            isLoading: false,
            onChanged: (_) {},
            onSubmitted: (_) {},
            onSearchPressed: () {},
          ),
        );

        await tester.enterText(find.byType(TextField), 'Rick Sanchez');
        await tester.pump();

        await tester.pumpWidget(
          pumpBar(
            initialValue: 'Rick',
            isLoading: false,
            onChanged: (_) {},
            onSubmitted: (_) {},
            onSearchPressed: () {},
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, 'Rick Sanchez');
      },
    );
  });
}

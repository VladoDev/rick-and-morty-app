import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_app/app/theme/theme.dart';

void main() {
  group('Theme builders', () {
    test(
      'buildLightTheme() builds a Material 3 light theme with expected colors',
      () {
        final theme = buildLightTheme();

        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.brightness, Brightness.light);

        expect(theme.scaffoldBackgroundColor, theme.colorScheme.surface);

        expect(theme.appBarTheme.backgroundColor, theme.colorScheme.surface);
        expect(theme.appBarTheme.foregroundColor, theme.colorScheme.onSurface);
        expect(theme.appBarTheme.centerTitle, isTrue);
        expect(theme.appBarTheme.elevation, 0);
      },
    );

    test(
      'buildDarkTheme() builds a Material 3 dark theme with expected colors',
      () {
        final theme = buildDarkTheme();

        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.brightness, Brightness.dark);

        expect(theme.scaffoldBackgroundColor, theme.colorScheme.surface);

        expect(theme.appBarTheme.backgroundColor, theme.colorScheme.surface);
        expect(theme.appBarTheme.foregroundColor, theme.colorScheme.onSurface);
        expect(theme.appBarTheme.centerTitle, isTrue);
        expect(theme.appBarTheme.elevation, 0);
      },
    );

    test('light and dark themes have different brightness', () {
      final light = buildLightTheme();
      final dark = buildDarkTheme();

      expect(light.colorScheme.brightness, isNot(dark.colorScheme.brightness));
    });
  });
}

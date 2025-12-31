import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_app/app/theme/theme_controller.dart';

void main() {
  group('ThemeController', () {
    test('initial mode is ThemeMode.system', () {
      final controller = ThemeController();
      expect(controller.mode, ThemeMode.system);
      expect(controller.isDark, isFalse);
    });

    test('toogle() switches system -> dark', () {
      final controller = ThemeController();

      controller.toogle();

      expect(controller.mode, ThemeMode.dark);
      expect(controller.isDark, isTrue);
    });

    test('toogle() switches dark -> light', () {
      final controller = ThemeController();

      controller.toogle(); // system -> dark
      controller.toogle(); // dark -> light

      expect(controller.mode, ThemeMode.light);
      expect(controller.isDark, isFalse);
    });

    test('toogle() notifies listeners exactly once per call', () {
      final controller = ThemeController();
      var notifications = 0;

      controller.addListener(() {
        notifications++;
      });

      controller.toogle();
      expect(notifications, 1);

      controller.toogle();
      expect(notifications, 2);
    });
  });
}

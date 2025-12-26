import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rick_and_morty_app/app/di/service_locator.dart';
import 'package:rick_and_morty_app/app/routing/app_router.dart';
import 'package:rick_and_morty_app/app/theme/theme.dart';
import 'package:rick_and_morty_app/app/theme/theme_controller.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = sl<ThemeController>();
    return AnimatedBuilder(
      animation: themeController,
      builder: (_, _) {
        return MaterialApp.router(
          title: "Rick and Morty",
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: themeController.mode,
          routerConfig: _router,
        );
      },
    );
  }
}

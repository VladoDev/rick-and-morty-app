import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rick_and_morty_app/app/theme/theme_controller.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final ThemeController themeController;
  final String location;
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.themeController,
    required this.location,
  });

  String _title() {
    if (location.startsWith("/search/") && location != "/search") {
      return "Search Characters";
    } else if (location.startsWith("/favorites")) {
      return "Favorite Characters";
    } else {
      return "Rick and Morty";
    }
  }

  IconData _currentIconTheme(BuildContext context) {
    return themeController.isDark ? Icons.dark_mode : Icons.light_mode;
  }

  @override
  Widget build(BuildContext context) {
    final showBack = location.startsWith("/search/") && location != "/search";

    return AnimatedBuilder(
      animation: themeController,
      builder: (_, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_title()),
            leading: showBack ? BackButton(onPressed: () => context.pop) : null,
            actions: [
              IconButton(
                onPressed: themeController.toogle,
                icon: Icon(_currentIconTheme(context)),
              ),
            ],
          ),
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(index),
            destinations: [
              NavigationDestination(icon: Icon(Icons.search), label: "Search"),
              NavigationDestination(
                icon: Icon(Icons.favorite),
                label: "Favorites",
              ),
            ],
          ),
        );
      },
    );
  }
}

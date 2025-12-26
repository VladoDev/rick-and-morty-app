import 'package:go_router/go_router.dart';
import 'package:rick_and_morty_app/app/di/service_locator.dart';
import 'package:rick_and_morty_app/app/shell/app_shell.dart';
import 'package:rick_and_morty_app/app/theme/theme_controller.dart';
import 'package:rick_and_morty_app/features/favorites/presentation/pages/favorite_characters_page.dart';
import 'package:rick_and_morty_app/features/search_characters/presentation/pages/search_characters_page.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: "/search-characters",
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(
            navigationShell: navigationShell,
            themeController: sl<ThemeController>(),
            location: state.uri.path,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/search-characters",
                builder: (context, state) {
                  return SearchCharactersPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/favorite-characters",
                builder: (context, state) {
                  return FavoriteCharactersPage();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

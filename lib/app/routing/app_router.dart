import 'package:go_router/go_router.dart';
import 'package:rick_and_morty_app/app/di/service_locator.dart';
import 'package:rick_and_morty_app/app/shell/app_shell.dart';
import 'package:rick_and_morty_app/app/theme/theme_controller.dart';
import 'package:rick_and_morty_app/features/characters/presentation/pages/favorite_characters_page.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/presentation/controllers/character_details_controller.dart';
import 'package:rick_and_morty_app/features/characters/presentation/pages/character_details_page.dart';
import 'package:rick_and_morty_app/features/characters/presentation/pages/search_characters_page.dart';

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
                routes: [
                  GoRoute(
                    path: ":id",
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;

                      final character = state.extra is Character
                          ? state.extra as Character
                          : null;

                      return CharacterDetailsPage(
                        key: state.pageKey,
                        characterId: id,
                        character: character,
                        characterDetailsController: () =>
                            sl<CharacterDetailsController>(),
                      );
                    },
                  ),
                ],
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

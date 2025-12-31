import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:rick_and_morty_app/app/di/service_locator.dart';
import 'package:rick_and_morty_app/app/routing/app_router.dart';
import 'package:rick_and_morty_app/app/theme/theme_controller.dart';

import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/repositories/character_repository.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/search_characters_usecase.dart';

import 'package:rick_and_morty_app/features/characters/presentation/controllers/favorites_controller.dart';
import 'package:rick_and_morty_app/features/characters/presentation/pages/favorite_characters_page.dart';
import 'package:rick_and_morty_app/features/characters/presentation/pages/search_characters_page.dart';
import 'package:rick_and_morty_app/features/characters/presentation/widgets/search_characters_search_bar.dart';

class MockCharactersRepository extends Mock implements CharacterRepository {}

class TestFavoritesController extends FavoritesController {
  @override
  Future<List<Character>> build() async => const <Character>[];

  @override
  Future<void> toggle(Character character) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await sl.reset();

    sl.registerSingleton<ThemeController>(ThemeController());

    final repo = MockCharactersRepository();
    sl.registerSingleton<SearchCharactersUsecase>(
      SearchCharactersUsecase(repo),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  Future<void> pumpRouter(WidgetTester tester) async {
    final router = createRouter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesControllerProvider.overrideWith(TestFavoritesController.new),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('starts at /search-characters and shows Search UI', (
    tester,
  ) async {
    await mockNetworkImagesFor(() async {
      await pumpRouter(tester);

      expect(find.byType(SearchCharactersPage), findsOneWidget);
      expect(find.byType(SearchCharactersSearchBar), findsOneWidget);
    });
  });

  testWidgets('navigates to favorites branch (/favorite-characters)', (
    tester,
  ) async {
    await mockNetworkImagesFor(() async {
      final router = createRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoritesControllerProvider.overrideWith(
              TestFavoritesController.new,
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/favorite-characters');
      await tester.pumpAndSettle();

      expect(find.byType(FavoriteCharactersPage), findsOneWidget);
    });
  });
}

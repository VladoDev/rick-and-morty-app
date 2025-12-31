import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';

import 'package:rick_and_morty_app/features/characters/domain/usecases/get_favorites_characters_usecase.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/add_favorite_usecase.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/remove_favorite_usecase.dart';

import 'package:rick_and_morty_app/features/characters/presentation/state/favorites_providers.dart';
import 'package:rick_and_morty_app/features/characters/presentation/controllers/favorites_controller.dart';

class MockGetFavoritesUsecase extends Mock
    implements GetFavoriteCharactersUsecase {}

class MockAddFavoriteUsecase extends Mock implements AddFavoriteUsecase {}

class MockRemoveFavoriteUsecase extends Mock implements RemoveFavoriteUsecase {}

void main() {
  Character buildCharacter(int id, String name) {
    return Character(
      id: id,
      name: name,
      status: CharacterStatus.alive,
      species: 'Human',
      type: '',
      gender: CharacterGender.male,
      origin: NamedResource(
        name: 'Earth',
        uri: Uri.parse('https://example.com/locations/1'),
      ),
      location: NamedResource(
        name: 'Earth',
        uri: Uri.parse('https://example.com/locations/1'),
      ),
      image: Uri.parse('https://example.com/images/$id.png'),
      episodesUrls: [Uri.parse('https://example.com/episodes/1')],
    );
  }

  late MockGetFavoritesUsecase getFavorites;
  late MockAddFavoriteUsecase addFavorite;
  late MockRemoveFavoriteUsecase removeFavorite;

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        getFavoritesUseCaseProvider.overrideWithValue(getFavorites),
        addFavoriteUseCaseProvider.overrideWithValue(addFavorite),
        removeFavoriteUseCaseProvider.overrideWithValue(removeFavorite),
      ],
    );
  }

  setUp(() {
    getFavorites = MockGetFavoritesUsecase();
    addFavorite = MockAddFavoriteUsecase();
    removeFavorite = MockRemoveFavoriteUsecase();
  });

  group('FavoritesController', () {
    test('build loads favorites using GetFavoriteCharactersUsecase', () async {
      final initial = <Character>[
        buildCharacter(1, 'Rick'),
        buildCharacter(2, 'Morty'),
      ];

      when(() => getFavorites()).thenAnswer((_) async => initial);

      final container = makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(favoritesControllerProvider.future);

      expect(result.map((c) => c.id).toList(), [1, 2]);
      verify(() => getFavorites()).called(1);
      verifyNoMoreInteractions(getFavorites);
    });

    test('refresh sets loading then updates with latest favorites', () async {
      final initial = <Character>[buildCharacter(1, 'Rick')];
      final updated = <Character>[
        buildCharacter(1, 'Rick'),
        buildCharacter(2, 'Morty'),
      ];

      when(() => getFavorites()).thenAnswer((_) async => initial);

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(favoritesControllerProvider.future);

      when(() => getFavorites()).thenAnswer((_) async => updated);

      final states = <AsyncValue<List<Character>>>[];
      final sub = container.listen(
        favoritesControllerProvider,
        (prev, next) => states.add(next),
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await container.read(favoritesControllerProvider.notifier).refresh();

      final last = container.read(favoritesControllerProvider);
      expect(last, isA<AsyncData<List<Character>>>());
      expect(last.asData!.value.map((c) => c.id).toList(), [1, 2]);

      expect(states.any((s) => s is AsyncLoading<List<Character>>), isTrue);

      verify(() => getFavorites()).called(greaterThanOrEqualTo(2));
    });

    test(
      'toggle removes when favorite, calls removeFavorite, then refreshes list',
      () async {
        final rick = buildCharacter(1, 'Rick');

        when(() => getFavorites()).thenAnswer((_) async => [rick]);
        when(() => removeFavorite(any())).thenAnswer((_) async {});

        final container = makeContainer();
        addTearDown(container.dispose);

        await container.read(favoritesControllerProvider.future);

        when(() => getFavorites()).thenAnswer((_) async => []);

        await container.read(favoritesControllerProvider.notifier).toggle(rick);

        verify(() => removeFavorite(1)).called(1);

        final state = container.read(favoritesControllerProvider);
        expect(state, isA<AsyncData<List<Character>>>());
        expect(state.asData!.value, isEmpty);
      },
    );
  });

  group('Derived providers', () {
    test(
      'favoriteIdsProvider returns set of ids from favoritesControllerProvider data',
      () async {
        final rick = buildCharacter(1, 'Rick');
        final morty = buildCharacter(2, 'Morty');

        when(() => getFavorites()).thenAnswer((_) async => [rick, morty]);

        final container = ProviderContainer(
          overrides: [
            getFavoritesUseCaseProvider.overrideWithValue(getFavorites),
            addFavoriteUseCaseProvider.overrideWithValue(addFavorite),
            removeFavoriteUseCaseProvider.overrideWithValue(removeFavorite),
          ],
        );
        addTearDown(container.dispose);

        await container.read(favoritesControllerProvider.future);

        final ids = container.read(favoriteIdsProvider);
        expect(ids, {1, 2});

        expect(container.read(isFavoriteProvider(1)), isTrue);
        expect(container.read(isFavoriteProvider(999)), isFalse);
      },
    );
  });
}

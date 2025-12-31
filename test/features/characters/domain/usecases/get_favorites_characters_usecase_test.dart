import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/repositories/favorite_characters_repository.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/get_favorites_characters_usecase.dart';

class MockFavoriteCharactersRepository extends Mock
    implements FavoriteCharactersRepository {}

void main() {
  late MockFavoriteCharactersRepository repo;
  late GetFavoriteCharactersUsecase usecase;

  setUp(() {
    repo = MockFavoriteCharactersRepository();
    usecase = GetFavoriteCharactersUsecase(repo);
  });

  group('GetFavoriteCharactersUsecase', () {
    test(
      'delegates to repo.getFavoriteCharacters and returns the same list',
      () async {
        final favorites = <Character>[
          Character(
            id: 1,
            name: 'Rick Sanchez',
            status: CharacterStatus.alive,
            species: 'Human',
            type: '',
            gender: CharacterGender.male,
            origin: NamedResource(
              name: 'Earth',
              uri: Uri.parse('https://example.com/locations/1'),
            ),
            location: NamedResource(
              name: 'Citadel of Ricks',
              uri: Uri.parse('https://example.com/locations/3'),
            ),
            image: Uri.parse('https://example.com/images/rick.png'),
            episodesUrls: [
              Uri.parse('https://example.com/episodes/1'),
              Uri.parse('https://example.com/episodes/2'),
            ],
          ),
          Character(
            id: 2,
            name: 'Morty Smith',
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
            image: Uri.parse('https://example.com/images/morty.png'),
            episodesUrls: [Uri.parse('https://example.com/episodes/1')],
          ),
        ];

        when(
          () => repo.getFavoriteCharacters(),
        ).thenAnswer((_) async => favorites);

        final result = await usecase();

        expect(result, favorites);
        verify(() => repo.getFavoriteCharacters()).called(1);
        verifyNoMoreInteractions(repo);
      },
    );

    test('returns empty list when repo returns empty', () async {
      when(() => repo.getFavoriteCharacters()).thenAnswer((_) async => []);

      final result = await usecase();

      expect(result, isEmpty);
      verify(() => repo.getFavoriteCharacters()).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}

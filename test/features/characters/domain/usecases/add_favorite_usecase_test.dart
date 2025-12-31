import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/repositories/favorite_characters_repository.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/add_favorite_usecase.dart';

class MockFavoriteCharactersRepository extends Mock
    implements FavoriteCharactersRepository {}

void main() {
  late MockFavoriteCharactersRepository repo;
  late AddFavoriteUsecase usecase;

  setUp(() {
    repo = MockFavoriteCharactersRepository();
    usecase = AddFavoriteUsecase(repo);
  });

  group('AddFavoriteUsecase', () {
    test('delegates to repo.addFavorite with the given character', () async {
      final character = Character(
        id: 1,
        name: 'Rick Sanchez',
        status: CharacterStatus.alive,
        species: 'Human',
        type: '',
        gender: CharacterGender.male,
        origin: const NamedResource(name: 'Earth', uri: null),
        location: const NamedResource(name: 'Earth', uri: null),
        image: Uri.parse('https://example.com/rick.png'),
        episodesUrls: const <Uri>[],
      );

      when(() => repo.addFavorite(character)).thenAnswer((_) async {});

      await usecase(character);

      verify(() => repo.addFavorite(character)).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('propagates exceptions from repo.addFavorite', () async {
      final character = Character(
        id: 1,
        name: 'Rick Sanchez',
        status: CharacterStatus.alive,
        species: 'Human',
        type: '',
        gender: CharacterGender.male,
        origin: const NamedResource(name: 'Earth', uri: null),
        location: const NamedResource(name: 'Earth', uri: null),
        image: Uri.parse('https://example.com/rick.png'),
        episodesUrls: const <Uri>[],
      );

      when(() => repo.addFavorite(character)).thenThrow(Exception('db'));

      await expectLater(() => usecase(character), throwsA(isA<Exception>()));

      verify(() => repo.addFavorite(character)).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}

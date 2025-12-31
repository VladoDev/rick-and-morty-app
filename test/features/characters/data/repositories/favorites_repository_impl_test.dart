import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rick_and_morty_app/features/characters/data/datasources/local/favorites_local_data_source.dart';
import 'package:rick_and_morty_app/features/characters/data/mappers/character_db_mapper.dart';
import 'package:rick_and_morty_app/features/characters/data/repositories/favorites_repository_impl.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';

class MockFavoritesLocalDataSource extends Mock
    implements FavoritesLocalDataSource {}

void main() {
  late MockFavoritesLocalDataSource local;
  late FavoritesRepositoryImpl sut;

  setUp(() {
    local = MockFavoritesLocalDataSource();
    sut = FavoritesRepositoryImpl(local);
  });

  Character _character({required int id, required String name}) {
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
      episodesUrls: [
        Uri.parse('https://example.com/episodes/1'),
        Uri.parse('https://example.com/episodes/2'),
      ],
    );
  }

  group('FavoritesRepositoryImpl', () {
    test('addFavorite delegates to local.upsert with mapped row', () async {
      final character = _character(id: 1, name: 'Rick Sanchez');

      when(() => local.upsert(any())).thenAnswer((_) async {});

      await sut.addFavorite(character);

      final captured =
          verify(() => local.upsert(captureAny())).captured.single
              as Map<String, Object?>;

      expect(captured, CharacterDbMapper.toMap(character));
      verifyNoMoreInteractions(local);
    });

    test('getFavoriteCharacters maps rows into Character list', () async {
      final c1 = _character(id: 1, name: 'Rick Sanchez');
      final c2 = _character(id: 2, name: 'Morty Smith');

      final rows = [CharacterDbMapper.toMap(c1), CharacterDbMapper.toMap(c2)];

      when(() => local.getFavoritesRows()).thenAnswer((_) async => rows);

      final result = await sut.getFavoriteCharacters();

      expect(result.length, 2);
      expect(result[0].id, c1.id);
      expect(result[0].name, c1.name);
      expect(result[1].id, c2.id);
      expect(result[1].name, c2.name);

      verify(() => local.getFavoritesRows()).called(1);
      verifyNoMoreInteractions(local);
    });

    test('isFavorite delegates to local.exists', () async {
      when(() => local.exists(10)).thenAnswer((_) async => true);

      final result = await sut.isFavorite(10);

      expect(result, isTrue);
      verify(() => local.exists(10)).called(1);
      verifyNoMoreInteractions(local);
    });

    test('removeFavorite delegates to local.delete', () async {
      when(() => local.delete(10)).thenAnswer((_) async {});

      await sut.removeFavorite(10);

      verify(() => local.delete(10)).called(1);
      verifyNoMoreInteractions(local);
    });
  });
}

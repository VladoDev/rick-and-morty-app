import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rick_and_morty_app/features/characters/domain/repositories/favorite_characters_repository.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/remove_favorite_usecase.dart';

class MockFavoriteCharactersRepository extends Mock
    implements FavoriteCharactersRepository {}

void main() {
  late MockFavoriteCharactersRepository repo;
  late RemoveFavoriteUsecase usecase;

  setUp(() {
    repo = MockFavoriteCharactersRepository();
    usecase = RemoveFavoriteUsecase(repo);
  });

  group('RemoveFavoriteUsecase', () {
    test('delegates to repo.removeFavorite with the given id', () async {
      const id = 1;

      when(() => repo.removeFavorite(id)).thenAnswer((_) async {});

      await usecase(id);

      verify(() => repo.removeFavorite(id)).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}

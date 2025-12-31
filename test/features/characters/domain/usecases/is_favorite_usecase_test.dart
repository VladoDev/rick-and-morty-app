import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rick_and_morty_app/features/characters/domain/repositories/favorite_characters_repository.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/is_favorite_usecase.dart';

class MockFavoriteCharactersRepository extends Mock
    implements FavoriteCharactersRepository {}

void main() {
  late MockFavoriteCharactersRepository repo;
  late IsFavoriteUsecase usecase;

  setUp(() {
    repo = MockFavoriteCharactersRepository();
    usecase = IsFavoriteUsecase(repo);
  });

  group('IsFavoriteUsecase', () {
    test('delegates to repo.isFavorite and returns true', () async {
      const id = 1;

      when(() => repo.isFavorite(id)).thenAnswer((_) async => true);

      final result = await usecase(id);

      expect(result, isTrue);
      verify(() => repo.isFavorite(id)).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('delegates to repo.isFavorite and returns false', () async {
      const id = 2;

      when(() => repo.isFavorite(id)).thenAnswer((_) async => false);

      final result = await usecase(id);

      expect(result, isFalse);
      verify(() => repo.isFavorite(id)).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rick_and_morty_app/core/result/result.dart';
import 'package:rick_and_morty_app/features/characters/domain/common/paginated.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/repositories/character_repository.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/search_characters_usecase.dart';
import 'package:rick_and_morty_app/features/characters/domain/value_objects/character_filters.dart';

class MockCharacterRepository extends Mock implements CharacterRepository {}

void main() {
  late MockCharacterRepository repo;
  late SearchCharactersUsecase usecase;

  setUp(() {
    repo = MockCharacterRepository();
    usecase = SearchCharactersUsecase(repo);
  });

  group('SearchCharactersUsecase', () {
    test('delegates to repository and returns Ok', () async {
      final criteria = CharacterSearchCriteria(name: 'rick', page: 1);

      final paginated = Paginated<Character>(
        info: PageInfo(count: 0, pages: 0, next: null, prev: null),
        results: const <Character>[],
      );

      final expected = Ok<Paginated<Character>>(paginated);

      when(
        () => repo.searchCharacters(criteria),
      ).thenAnswer((_) async => expected);

      final result = await usecase(criteria);

      expect(result, expected);

      result.when(
        ok: (data) => expect(data, paginated),
        err: (_, __) => fail('Expected Ok, got Err'),
      );

      verify(() => repo.searchCharacters(criteria)).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('delegates to repository and returns Err', () async {
      final criteria = CharacterSearchCriteria(name: 'rick', page: 1);

      final error = Exception('network');
      final st = StackTrace.current;

      final expected = Err<Paginated<Character>>(error, st);

      when(
        () => repo.searchCharacters(criteria),
      ).thenAnswer((_) async => expected);

      final result = await usecase(criteria);

      expect(result, expected);

      result.when(
        ok: (_) => fail('Expected Err, got Ok'),
        err: (e, s) {
          expect(e, error);
          expect(s, st);
        },
      );

      verify(() => repo.searchCharacters(criteria)).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('criteria assert: page must be >= 1', () {
      expect(
        () => CharacterSearchCriteria(name: 'rick', page: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

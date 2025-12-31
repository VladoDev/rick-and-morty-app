import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rick_and_morty_app/core/errors/app_exception.dart';
import 'package:rick_and_morty_app/core/result/result.dart';

import 'package:rick_and_morty_app/features/characters/domain/common/paginated.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/repositories/character_repository.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/search_characters_usecase.dart';
import 'package:rick_and_morty_app/features/characters/domain/value_objects/character_filters.dart';

import 'package:rick_and_morty_app/features/characters/presentation/controllers/search_characters_controller.dart';

class MockCharacterRepository extends Mock implements CharacterRepository {}

void main() {
  late MockCharacterRepository repo;
  late SearchCharactersUsecase usecase;
  late SearchCharactersController sut;

  setUpAll(() {
    registerFallbackValue(const CharacterSearchCriteria());
  });

  setUp(() {
    repo = MockCharacterRepository();
    usecase = SearchCharactersUsecase(repo);
    sut = SearchCharactersController(usecase);
  });

  Character _c(int id, String name) {
    return Character(
      id: id,
      name: name,
      status: CharacterStatus.alive,
      species: 'Human',
      type: '',
      gender: CharacterGender.male,
      origin: NamedResource(
        name: 'Earth',
        uri: Uri.parse('https://example.com/o'),
      ),
      location: NamedResource(
        name: 'Earth',
        uri: Uri.parse('https://example.com/l'),
      ),
      image: Uri.parse('https://example.com/images/$id.png'),
      episodesUrls: [Uri.parse('https://example.com/episodes/1')],
    );
  }

  Paginated<Character> _page({
    required int count,
    required int pages,
    Uri? next,
    Uri? prev,
    required List<Character> results,
  }) {
    return Paginated<Character>(
      info: PageInfo(count: count, pages: pages, next: next, prev: prev),
      results: results,
    );
  }

  group('SearchCharactersController setters', () {
    test('setQuery updates query', () {
      sut.setQuery('rick');
      expect(sut.state.query, 'rick');
    });

    test('setStatus updates status', () {
      sut.setStatus(CharacterStatus.dead);
      expect(sut.state.status, CharacterStatus.dead);
    });

    test('setGender updates gender', () {
      sut.setGender(CharacterGender.female);
      expect(sut.state.gender, CharacterGender.female);
    });

    test('setSpecies updates species', () {
      sut.setSpecies('Human');
      expect(sut.state.species, 'Human');
    });

    test('setType updates type', () {
      sut.setType('Genetic experiment');
      expect(sut.state.type, 'Genetic experiment');
    });
  });

  group('search()', () {
    test('does nothing if already loading', () async {
      sut.state = sut.state.copyWith(isLoading: true);

      await sut.search();

      verifyNever(() => repo.searchCharacters(any()));
    });

    test(
      'sets loading, calls repo through usecase, then sets data on success',
      () async {
        final page1 = _page(
          count: 2,
          pages: 1,
          next: null,
          prev: null,
          results: [_c(1, 'Rick'), _c(2, 'Morty')],
        );

        when(
          () => repo.searchCharacters(any()),
        ).thenAnswer((_) async => Ok(page1));

        final future = sut.search();

        expect(sut.state.isLoading, isTrue);
        expect(sut.state.items, isEmpty);

        await future;

        expect(sut.state.isLoading, isFalse);
        expect(sut.state.errorMessage, isNull);
        expect(sut.state.items.map((c) => c.id).toList(), [1, 2]);
        expect(sut.state.info.count, 2);
        expect(sut.state.info.pages, 1);

        verify(() => repo.searchCharacters(any())).called(1);
        verifyNoMoreInteractions(repo);
      },
    );

    test('sets errorMessage using AppException.message on failure', () async {
      when(() => repo.searchCharacters(any())).thenAnswer(
        (_) async => Err(const AppException('Boom'), StackTrace.current),
      );

      await sut.search();

      expect(sut.state.isLoading, isFalse);
      expect(sut.state.errorMessage, 'Boom');

      verify(() => repo.searchCharacters(any())).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('sets errorMessage using toString for non-AppException', () async {
      when(
        () => repo.searchCharacters(any()),
      ).thenAnswer((_) async => Err(Exception('X'), StackTrace.current));

      await sut.search();

      expect(sut.state.isLoading, isFalse);
      expect(sut.state.errorMessage, contains('Exception: X'));

      verify(() => repo.searchCharacters(any())).called(1);
      verifyNoMoreInteractions(repo);
    });
  });

  group('loadNextPage()', () {
    test('does nothing if no next page', () async {
      sut.state = sut.state.copyWith(
        page: 1,
        info: const PageInfo(count: 1, pages: 1, next: null, prev: null),
        items: [_c(1, 'Rick')],
      );

      await sut.loadNextPage();

      verifyNever(() => repo.searchCharacters(any()));
      expect(sut.state.isLoadingMore, isFalse);
      expect(sut.state.items.length, 1);
    });

    test('does nothing if already loadingMore', () async {
      sut.state = sut.state.copyWith(isLoadingMore: true);

      await sut.loadNextPage();

      verifyNever(() => repo.searchCharacters(any()));
    });

    test('loads next page, appends results, updates info and page', () async {
      sut.state = sut.state.copyWith(
        page: 1,
        items: [_c(1, 'Rick')],
        info: PageInfo(
          count: 2,
          pages: 2,
          next: Uri.parse('https://example.com/character?page=2'),
          prev: null,
        ),
      );

      final page2 = _page(
        count: 2,
        pages: 2,
        next: null,
        prev: Uri.parse('https://example.com/character?page=1'),
        results: [_c(2, 'Morty')],
      );

      when(
        () => repo.searchCharacters(any()),
      ).thenAnswer((_) async => Ok(page2));

      final future = sut.loadNextPage();

      expect(sut.state.isLoadingMore, isTrue);
      expect(sut.state.page, 2);

      await future;

      expect(sut.state.isLoadingMore, isFalse);
      expect(sut.state.items.map((c) => c.id).toList(), [1, 2]);
      expect(sut.state.info.pages, 2);
      expect(sut.state.info.next, isNull);

      verify(() => repo.searchCharacters(any())).called(1);
      verifyNoMoreInteractions(repo);
    });

    test('on error sets errorMessage and stops loadingMore', () async {
      sut.state = sut.state.copyWith(
        page: 1,
        items: [_c(1, 'Rick')],
        info: PageInfo(
          count: 2,
          pages: 2,
          next: Uri.parse('https://example.com/character?page=2'),
          prev: null,
        ),
      );

      when(() => repo.searchCharacters(any())).thenAnswer(
        (_) async =>
            Err(const AppException('Network fail'), StackTrace.current),
      );

      await sut.loadNextPage();

      expect(sut.state.isLoadingMore, isFalse);
      expect(sut.state.errorMessage, 'Network fail');
      expect(sut.state.items.map((c) => c.id).toList(), [1]);

      verify(() => repo.searchCharacters(any())).called(1);
      verifyNoMoreInteractions(repo);
    });
  });

  group('retry()', () {
    test('invokes search (repo.searchCharacters called)', () async {
      when(() => repo.searchCharacters(any())).thenAnswer(
        (_) async => Ok(
          _page(count: 0, pages: 0, next: null, prev: null, results: const []),
        ),
      );

      await sut.retry();

      verify(() => repo.searchCharacters(any())).called(1);
      verifyNoMoreInteractions(repo);
    });
  });
}

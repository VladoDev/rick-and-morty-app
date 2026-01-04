import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rick_and_morty_app/core/errors/app_exception.dart';
import 'package:rick_and_morty_app/core/result/result.dart';

import 'package:rick_and_morty_app/features/characters/data/datasources/remote/characters_remote_datasource.dart';
import 'package:rick_and_morty_app/features/characters/data/repositories/character_repository_impl.dart';
import 'package:rick_and_morty_app/features/characters/domain/common/paginated.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/value_objects/character_filters.dart';

class MockCharactersRemoteDatasource extends Mock
    implements CharactersRemoteDatasource {}

void main() {
  late MockCharactersRemoteDatasource remote;
  late CharacterRepositoryImpl sut;

  setUp(() {
    remote = MockCharactersRemoteDatasource();
    sut = CharacterRepositoryImpl(remote);
  });

  Response<Map<String, dynamic>> _responseWith(Map<String, dynamic>? data) {
    return Response<Map<String, dynamic>>(
      data: data,
      statusCode: 200,
      requestOptions: RequestOptions(path: '/character'),
    );
  }

  DioException _dioExceptionWithStatus(int statusCode) {
    final requestOptions = RequestOptions(path: '/character');
    return DioException(
      requestOptions: requestOptions,
      response: Response<Map<String, dynamic>>(
        requestOptions: requestOptions,
        statusCode: statusCode,
      ),
      type: DioExceptionType.badResponse,
    );
  }

  group('CharacterRepositoryImpl.searchCharacters', () {
    test('returns Err(AppException) when response.data is null', () async {
      const criteria = CharacterSearchCriteria(page: 1);

      when(
        () => remote.fetchCharactersJson(criteria),
      ).thenAnswer((_) async => _responseWith(null));

      final result = await sut.searchCharacters(criteria);

      expect(result, isA<Err<Paginated<Character>>>());

      final err = result as dynamic;
      final ex = (err.exception ?? err.error ?? err.ex) as Object?;
      expect(ex, isA<AppException>());
      expect(ex.toString(), contains('Empty response body'));

      verify(() => remote.fetchCharactersJson(criteria)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('maps info + results and returns Ok(Paginated<Character>)', () async {
      const criteria = CharacterSearchCriteria(page: 2);

      final json = <String, dynamic>{
        'info': {
          'count': 826,
          'pages': 42,
          'next': 'https://example.com/character?page=3',
          'prev': 'https://example.com/character?page=1',
        },
        'results': [
          {
            'id': 1,
            'name': ' Rick Sanchez ',
            'status': 'alive',
            'species': ' Human ',
            'type': '',
            'gender': 'male',
            'origin': {
              'name': 'Earth',
              'url': 'https://example.com/location/1',
            },
            'location': {
              'name': 'Citadel of Ricks',
              'url': 'https://example.com/location/3',
            },
            'image': 'https://example.com/images/rick.png',
            'episode': [
              'https://example.com/episode/1',
              'https://example.com/episode/2',
            ],
          },
        ],
      };

      when(
        () => remote.fetchCharactersJson(criteria),
      ).thenAnswer((_) async => _responseWith(json));

      final result = await sut.searchCharacters(criteria);

      expect(result, isA<Ok<Paginated<Character>>>());

      final ok = result as Ok<Paginated<Character>>;
      final paginated = ok.data;

      expect(paginated.info.count, 826);
      expect(paginated.info.pages, 42);
      expect(
        paginated.info.next.toString(),
        'https://example.com/character?page=3',
      );
      expect(
        paginated.info.prev.toString(),
        'https://example.com/character?page=1',
      );

      expect(paginated.results, hasLength(1));
      final c = paginated.results.single;

      expect(c.id, 1);
      expect(c.name, 'Rick Sanchez');
      expect(c.status, CharacterStatus.alive);
      expect(c.species, 'Human');
      expect(c.gender, CharacterGender.male);
      expect(c.origin.name, 'Earth');
      expect(c.location.name, 'Citadel of Ricks');
      expect(c.image.toString(), 'https://example.com/images/rick.png');
      expect(c.episodesUrls.map((e) => e.toString()).toList(), [
        'https://example.com/episode/1',
        'https://example.com/episode/2',
      ]);

      verify(() => remote.fetchCharactersJson(criteria)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('filters results: ignores non-map entries in results list', () async {
      const criteria = CharacterSearchCriteria(page: 1);

      final json = <String, dynamic>{
        'info': {'count': 1, 'pages': 1, 'next': null, 'prev': null},
        'results': [
          'not a map',
          123,
          {
            'id': 1,
            'name': 'Rick',
            'status': 'alive',
            'species': 'Human',
            'type': '',
            'gender': 'male',
            'origin': {'name': 'Earth', 'url': null},
            'location': {'name': 'Earth', 'url': null},
            'image': 'https://example.com/images/rick.png',
            'episode': const <String>[],
          },
        ],
      };

      when(
        () => remote.fetchCharactersJson(criteria),
      ).thenAnswer((_) async => _responseWith(json));

      final result = await sut.searchCharacters(criteria);

      final ok = result as Ok<Paginated<Character>>;
      expect(ok.data.results, hasLength(1));
    });

    test('returns Ok(empty) when DioException is 404', () async {
      const criteria = CharacterSearchCriteria(page: 99);

      when(
        () => remote.fetchCharactersJson(criteria),
      ).thenThrow(_dioExceptionWithStatus(404));

      final result = await sut.searchCharacters(criteria);

      expect(result, isA<Ok<Paginated<Character>>>());

      final ok = result as Ok<Paginated<Character>>;
      expect(ok.data.results, isEmpty);
      expect(ok.data.info.count, 0);
      expect(ok.data.info.pages, 0);
      expect(ok.data.info.next, isNull);
      expect(ok.data.info.prev, isNull);

      verify(() => remote.fetchCharactersJson(criteria)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('for non-404 DioException returns Err(mapped error)', () async {
      const criteria = CharacterSearchCriteria(page: 1);

      when(
        () => remote.fetchCharactersJson(criteria),
      ).thenThrow(_dioExceptionWithStatus(500));

      final result = await sut.searchCharacters(criteria);

      expect(result, isA<Err<Paginated<Character>>>());
      verify(() => remote.fetchCharactersJson(criteria)).called(1);
      verifyNoMoreInteractions(remote);
    });

    test('next/prev are null when blank or invalid', () async {
      const criteria = CharacterSearchCriteria(page: 1);

      final json = <String, dynamic>{
        'info': {
          'count': 0,
          'pages': 0,
          'next': '::::not-a-url::::',
          'prev': '   ',
        },
        'results': const [],
      };

      when(
        () => remote.fetchCharactersJson(criteria),
      ).thenAnswer((_) async => _responseWith(json));

      final result = await sut.searchCharacters(criteria);

      final ok = result as Ok<Paginated<Character>>;
      expect(ok.data.info.next, isNull);
      expect(ok.data.info.prev, isNull);
    });
  });
}

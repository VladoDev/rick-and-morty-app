import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rick_and_morty_app/core/network/api_constants.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/value_objects/character_filters.dart';
import 'package:rick_and_morty_app/features/characters/data/datasources/remote/characters_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late CharactersRemoteDatasource sut;

  setUp(() {
    dio = MockDio();
    sut = CharactersRemoteDatasource(dio);
  });

  Response<Map<String, dynamic>> _fakeResponse() {
    return Response<Map<String, dynamic>>(
      data: <String, dynamic>{'ok': true},
      requestOptions: RequestOptions(path: Paths.character),
      statusCode: 200,
    );
  }

  group('CharactersRemoteDatasource.fetchCharactersJson', () {
    test('always sends page', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _fakeResponse());

      await sut.fetchCharactersJson(const CharacterSearchCriteria(page: 3));

      final captured =
          verify(
                () => dio.get<Map<String, dynamic>>(
                  Paths.character,
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(captured, containsPair('page', 3));
      verifyNoMoreInteractions(dio);
    });

    test('trims name/species/type and omits empty values', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _fakeResponse());

      await sut.fetchCharactersJson(
        const CharacterSearchCriteria(
          page: 1,
          name: '  Rick  ',
          species: '   ',
          type: '  Human  ',
        ),
      );

      final captured =
          verify(
                () => dio.get<Map<String, dynamic>>(
                  Paths.character,
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(captured['page'], 1);
      expect(captured['name'], 'Rick');
      expect(captured.containsKey('species'), isFalse);
      expect(captured['type'], 'Human');

      verifyNoMoreInteractions(dio);
    });

    test('includes status and gender using enum name', () async {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _fakeResponse());

      await sut.fetchCharactersJson(
        const CharacterSearchCriteria(
          page: 2,
          status: CharacterStatus.alive,
          gender: CharacterGender.male,
        ),
      );

      final captured =
          verify(
                () => dio.get<Map<String, dynamic>>(
                  Paths.character,
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(captured['page'], 2);
      expect(captured['status'], 'alive');
      expect(captured['gender'], 'male');

      verifyNoMoreInteractions(dio);
    });

    test('returns the same Response instance from dio', () async {
      final response = _fakeResponse();

      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => response);

      final result = await sut.fetchCharactersJson(
        const CharacterSearchCriteria(),
      );

      expect(result, same(response));
      verify(
        () => dio.get<Map<String, dynamic>>(
          Paths.character,
          queryParameters: any(named: 'queryParameters'),
        ),
      ).called(1);
      verifyNoMoreInteractions(dio);
    });
  });
}

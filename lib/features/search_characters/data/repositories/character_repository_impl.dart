// lib/features/search_characters/data/repositories/character_repository_impl.dart

import 'package:dio/dio.dart';

import 'package:rick_and_morty_app/core/errors/app_exception.dart';
import 'package:rick_and_morty_app/core/network/dio_error_mapper.dart';
import 'package:rick_and_morty_app/core/result/result.dart';
import 'package:rick_and_morty_app/features/search_characters/data/datasources/remote/characters_remote_datasource.dart';

import 'package:rick_and_morty_app/features/search_characters/domain/common/paginated.dart';
import 'package:rick_and_morty_app/features/search_characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/search_characters/domain/repositories/character_repository.dart';
import 'package:rick_and_morty_app/features/search_characters/domain/value_objects/character_filters.dart';

import 'package:rick_and_morty_app/features/search_characters/data/dtos/character_dto.dart';
import 'package:rick_and_morty_app/features/search_characters/data/mappers/character_mapper.dart';

final class CharacterRepositoryImpl implements CharacterRepository {
  final CharactersRemoteDatasource _remote;

  const CharacterRepositoryImpl(this._remote);

  @override
  Future<Result<Paginated<Character>>> searchCharacters(
    CharacterSearchCriteria criteria,
  ) async {
    try {
      final response = await _remote.fetchCharactersJson(criteria);
      final data = response.data;

      if (data == null) {
        return Err(
          const AppException('Empty response body'),
          StackTrace.current,
        );
      }

      final infoJson =
          (data['info'] as Map<String, dynamic>?) ?? const <String, dynamic>{};

      final count = (infoJson['count'] as num?)?.toInt() ?? 0;
      final pages = (infoJson['pages'] as num?)?.toInt() ?? 0;
      final nextRaw = infoJson['next'] as String?;
      final prevRaw = infoJson['prev'] as String?;

      final info = PageInfo(
        count: count,
        pages: pages,
        next: (nextRaw == null || nextRaw.trim().isEmpty)
            ? null
            : Uri.tryParse(nextRaw),
        prev: (prevRaw == null || prevRaw.trim().isEmpty)
            ? null
            : Uri.tryParse(prevRaw),
      );

      final resultsJson = (data['results'] as List<dynamic>?) ?? const [];

      final results = resultsJson
          .whereType<Map<String, dynamic>>()
          .map(CharacterDto.fromJson)
          .map(CharacterMapper.toEntity)
          .toList();

      return Ok(Paginated<Character>(info: info, results: results));
    } catch (e, st) {
      if (e is DioException && e.response?.statusCode == 404) {
        return Ok(
          Paginated<Character>(
            info: const PageInfo(count: 0, pages: 0, next: null, prev: null),
            results: const [],
          ),
        );
      }

      final ex = mapDioError(e);
      return Err(ex, st);
    }
  }
}

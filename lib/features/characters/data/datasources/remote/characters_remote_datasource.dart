import 'package:dio/dio.dart';
import 'package:rick_and_morty_app/core/network/api_constants.dart';
import 'package:rick_and_morty_app/features/characters/domain/value_objects/character_filters.dart';

class CharactersRemoteDatasource {
  final Dio _dio;
  const CharactersRemoteDatasource(this._dio);

  Map<String, dynamic> _buildQuery(CharacterSearchCriteria criteria) {
    final query = <String, dynamic>{'page': criteria.page};

    final name = criteria.name?.trim();
    if (name != null && name.isNotEmpty) query['name'] = name;

    final species = criteria.species?.trim();
    if (species != null && species.isNotEmpty) query['species'] = species;

    final type = criteria.type?.trim();
    if (type != null && type.isNotEmpty) query['type'] = type;

    if (criteria.status != null) query['status'] = criteria.status!.name;
    if (criteria.gender != null) query['gender'] = criteria.gender!.name;

    return query;
  }

  Future<Response<Map<String, dynamic>>> fetchCharactersJson(
    CharacterSearchCriteria criteria,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Paths.character,
      queryParameters: _buildQuery(criteria),
    );
    return response;
  }
}

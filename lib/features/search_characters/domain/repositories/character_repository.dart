import 'package:rick_and_morty_app/core/result/result.dart';
import 'package:rick_and_morty_app/features/search_characters/domain/common/paginated.dart';
import 'package:rick_and_morty_app/features/search_characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/search_characters/domain/value_objects/character_filters.dart';

abstract interface class CharacterRepository {
  Future<Result<Paginated<Character>>> searchCharacters(
    CharacterSearchCriteria criteria,
  );
}

import 'package:rick_and_morty_app/core/result/result.dart';
import 'package:rick_and_morty_app/features/characters/domain/common/paginated.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/repositories/character_repository.dart';
import 'package:rick_and_morty_app/features/characters/domain/value_objects/character_filters.dart';

final class SearchCharactersUsecase {
  final CharacterRepository _characterRepository;

  const SearchCharactersUsecase(this._characterRepository);

  Future<Result<Paginated<Character>>> call(CharacterSearchCriteria criteria) {
    return _characterRepository.searchCharacters(criteria);
  }
}

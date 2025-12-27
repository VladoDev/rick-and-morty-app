import 'package:rick_and_morty_app/features/search_characters/domain/entities/character.dart';

final class CharacterSearchCriteria {
  final String? name;
  final CharacterStatus? status;
  final String? species;
  final String? type;
  final CharacterGender? gender;
  final int page;

  const CharacterSearchCriteria({
    this.name,
    this.status,
    this.species,
    this.type,
    this.gender,
    this.page = 1,
  }) : assert(page >= 1, "Page must be greater than 1");
}

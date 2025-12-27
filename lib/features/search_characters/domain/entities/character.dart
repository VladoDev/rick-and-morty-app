enum CharacterStatus { alive, dead, unknown }

enum CharacterGender { female, male, genderless, unknown }

final class NamedResource {
  final String name;
  final Uri? uri;

  const NamedResource({required this.name, this.uri});
}

final class Character {
  final int id;
  final String name;
  final CharacterStatus status;
  final String species;
  final String type;
  final CharacterGender gender;

  final NamedResource origin;
  final NamedResource location;

  final Uri image;
  final List<Uri> episodesUrls;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
    required this.episodesUrls,
  });
}

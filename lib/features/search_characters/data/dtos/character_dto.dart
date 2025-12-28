class NamedResourceDto {
  final String name;
  final String? url;

  const NamedResourceDto({required this.name, this.url});

  factory NamedResourceDto.fromJson(Map<String, dynamic> json) {
    return NamedResourceDto(
      name: (json['name'] as String),
      url: json['url'] as String?,
    );
  }
}

class CharacterDto {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final NamedResourceDto origin;
  final NamedResourceDto location;
  final String image;
  final List<String> episode;

  const CharacterDto({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
    required this.episode,
  });

  factory CharacterDto.fromJson(Map<String, dynamic> json) {
    return CharacterDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'unknown',
      species: (json['species'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      gender: (json['gender'] as String?) ?? 'unknown',
      origin: NamedResourceDto.fromJson(
        (json['origin'] as Map<String, dynamic>?) ?? const <String, dynamic>{},
      ),
      location: NamedResourceDto.fromJson(
        (json['location'] as Map<String, dynamic>?) ??
            const <String, dynamic>{},
      ),
      image: (json['image'] as String?) ?? '',
      episode: (json['episode'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}

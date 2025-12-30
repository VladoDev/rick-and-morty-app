import 'dart:convert';

import '../../domain/entities/character.dart';

class CharacterDbMapper {
  static Map<String, Object?> toMap(Character c) {
    return {
      'id': c.id,
      'name': c.name,
      'status': c.status.name,
      'species': c.species,
      'type': c.type,
      'gender': c.gender.name,
      'origin_name': c.origin.name,
      'origin_url': c.origin.uri?.toString(),
      'location_name': c.location.name,
      'location_url': c.location.uri?.toString(),
      'image_url': c.image.toString(),
      'episodes_urls': jsonEncode(
        c.episodesUrls.map((e) => e.toString()).toList(),
      ),
    };
  }

  static Character fromMap(Map<String, Object?> map) {
    final episodesJson = (map['episodes_urls'] as String?) ?? '[]';
    final decoded = jsonDecode(episodesJson);

    final episodes = (decoded is List)
        ? decoded.map((e) => Uri.parse(e.toString())).toList()
        : <Uri>[];

    CharacterStatus parseStatus(String? v) {
      return CharacterStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => CharacterStatus.unknown,
      );
    }

    CharacterGender parseGender(String? v) {
      return CharacterGender.values.firstWhere(
        (e) => e.name == v,
        orElse: () => CharacterGender.unknown,
      );
    }

    return Character(
      id: (map['id'] as num).toInt(),
      name: (map['name'] as String?) ?? '',
      status: parseStatus(map['status'] as String?),
      species: (map['species'] as String?) ?? '',
      type: (map['type'] as String?) ?? '',
      gender: parseGender(map['gender'] as String?),
      origin: NamedResource(
        name: (map['origin_name'] as String?) ?? '',
        uri: (map['origin_url'] as String?)?.isNotEmpty == true
            ? Uri.parse(map['origin_url'] as String)
            : null,
      ),
      location: NamedResource(
        name: (map['location_name'] as String?) ?? '',
        uri: (map['location_url'] as String?)?.isNotEmpty == true
            ? Uri.parse(map['location_url'] as String)
            : null,
      ),
      image: Uri.parse((map['image_url'] as String?) ?? ''),
      episodesUrls: episodes,
    );
  }
}

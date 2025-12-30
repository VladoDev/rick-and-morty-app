// lib/features/search_characters/data/mappers/character_mapper.dart

import '../../domain/entities/character.dart';
import '../dtos/character_dto.dart';

class CharacterMapper {
  static CharacterStatus _mapStatus(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'alive':
        return CharacterStatus.alive;
      case 'dead':
        return CharacterStatus.dead;
      default:
        return CharacterStatus.unknown;
    }
  }

  static CharacterGender _mapGender(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'female':
        return CharacterGender.female;
      case 'male':
        return CharacterGender.male;
      case 'genderless':
        return CharacterGender.genderless;
      default:
        return CharacterGender.unknown;
    }
  }

  static NamedResource _mapNamedResource(NamedResourceDto dto) {
    final name = dto.name.trim();
    final url = dto.url?.trim();

    return NamedResource(
      name: name,
      uri: (url == null || url.isEmpty) ? null : Uri.tryParse(url),
    );
  }

  static Character toEntity(CharacterDto dto) {
    final image = dto.image.trim();
    final episodes = dto.episode;

    return Character(
      id: dto.id,
      name: dto.name.trim(),
      status: _mapStatus(dto.status),
      species: dto.species.trim(),
      type: dto.type.trim(),
      gender: _mapGender(dto.gender),
      origin: _mapNamedResource(dto.origin),
      location: _mapNamedResource(dto.location),
      image: Uri.parse(image.isEmpty ? 'about:blank' : image),
      episodesUrls: episodes.map((e) => Uri.parse(e)).toList(),
    );
  }
}

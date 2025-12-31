import 'package:flutter_test/flutter_test.dart';

import 'package:rick_and_morty_app/features/characters/data/dtos/character_dto.dart';

void main() {
  group('NamedResourceDto.fromJson', () {
    test('parses required name and optional url', () {
      const json = <String, dynamic>{
        'name': 'Earth',
        'url': 'https://example.com/location/1',
      };

      final dto = NamedResourceDto.fromJson(json);

      expect(dto.name, 'Earth');
      expect(dto.url, 'https://example.com/location/1');
    });

    test('parses url as null when absent', () {
      const json = <String, dynamic>{'name': 'Earth'};

      final dto = NamedResourceDto.fromJson(json);

      expect(dto.name, 'Earth');
      expect(dto.url, isNull);
    });
  });

  group('CharacterDto.fromJson', () {
    test('parses a full json object', () {
      final json = <String, dynamic>{
        'id': 1,
        'name': 'Rick Sanchez',
        'status': 'alive',
        'species': 'Human',
        'type': '',
        'gender': 'male',
        'origin': {'name': 'Earth', 'url': 'https://example.com/location/1'},
        'location': {
          'name': 'Citadel of Ricks',
          'url': 'https://example.com/location/3',
        },
        'image': 'https://example.com/images/rick.png',
        'episode': [
          'https://example.com/episode/1',
          'https://example.com/episode/2',
        ],
      };

      final dto = CharacterDto.fromJson(json);

      expect(dto.id, 1);
      expect(dto.name, 'Rick Sanchez');
      expect(dto.status, 'alive');
      expect(dto.species, 'Human');
      expect(dto.type, '');
      expect(dto.gender, 'male');

      expect(dto.origin.name, 'Earth');
      expect(dto.origin.url, 'https://example.com/location/1');

      expect(dto.location.name, 'Citadel of Ricks');
      expect(dto.location.url, 'https://example.com/location/3');

      expect(dto.image, 'https://example.com/images/rick.png');
      expect(dto.episode, [
        'https://example.com/episode/1',
        'https://example.com/episode/2',
      ]);
    });

    test('converts id from num to int', () {
      final json = <String, dynamic>{
        'id': 1.0,
        'origin': {'name': 'Earth'},
        'location': {'name': 'Earth'},
      };

      final dto = CharacterDto.fromJson(json);

      expect(dto.id, 1);
    });

    test('filters episode list keeping only String entries', () {
      final json = <String, dynamic>{
        'id': 10,
        'origin': {'name': 'Earth'},
        'location': {'name': 'Earth'},
        'episode': [
          'https://example.com/episode/1',
          123,
          null,
          true,
          'https://example.com/episode/2',
        ],
      };

      final dto = CharacterDto.fromJson(json);

      expect(dto.episode, [
        'https://example.com/episode/1',
        'https://example.com/episode/2',
      ]);
    });
  });
}

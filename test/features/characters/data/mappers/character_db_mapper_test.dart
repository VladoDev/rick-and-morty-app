import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/data/mappers/character_db_mapper.dart';

void main() {
  Character _character({
    required int id,
    required String name,
    CharacterStatus status = CharacterStatus.alive,
    String species = 'Human',
    String type = '',
    CharacterGender gender = CharacterGender.male,
    NamedResource? origin,
    NamedResource? location,
    Uri? image,
    List<Uri>? episodesUrls,
  }) {
    return Character(
      id: id,
      name: name,
      status: status,
      species: species,
      type: type,
      gender: gender,
      origin:
          origin ??
          NamedResource(
            name: 'Earth',
            uri: Uri.parse('https://example.com/locations/1'),
          ),
      location:
          location ??
          NamedResource(
            name: 'Citadel of Ricks',
            uri: Uri.parse('https://example.com/locations/3'),
          ),
      image: image ?? Uri.parse('https://example.com/images/$id.png'),
      episodesUrls:
          episodesUrls ??
          <Uri>[
            Uri.parse('https://example.com/episodes/1'),
            Uri.parse('https://example.com/episodes/2'),
          ],
    );
  }

  group('CharacterDbMapper.toMap', () {
    test('maps Character to db row with expected keys and values', () {
      final c = _character(id: 1, name: 'Rick Sanchez');

      final map = CharacterDbMapper.toMap(c);

      expect(map['id'], 1);
      expect(map['name'], 'Rick Sanchez');
      expect(map['status'], 'alive');
      expect(map['species'], 'Human');
      expect(map['type'], '');
      expect(map['gender'], 'male');

      expect(map['origin_name'], 'Earth');
      expect(map['origin_url'], 'https://example.com/locations/1');
      expect(map['location_name'], 'Citadel of Ricks');
      expect(map['location_url'], 'https://example.com/locations/3');

      expect(map['image_url'], 'https://example.com/images/1.png');

      final episodesEncoded = map['episodes_urls'] as String;
      expect(jsonDecode(episodesEncoded), [
        'https://example.com/episodes/1',
        'https://example.com/episodes/2',
      ]);
    });

    test('maps null origin/location uri as null (not empty string)', () {
      final c = _character(
        id: 2,
        name: 'Morty Smith',
        origin: const NamedResource(name: 'Earth', uri: null),
        location: const NamedResource(name: 'Earth', uri: null),
      );

      final map = CharacterDbMapper.toMap(c);

      expect(map['origin_url'], isNull);
      expect(map['location_url'], isNull);
    });
  });

  group('CharacterDbMapper.fromMap', () {
    test('maps db row to Character including episodes urls list', () {
      final row = <String, Object?>{
        'id': 1,
        'name': 'Rick Sanchez',
        'status': 'alive',
        'species': 'Human',
        'type': '',
        'gender': 'male',
        'origin_name': 'Earth',
        'origin_url': 'https://example.com/locations/1',
        'location_name': 'Citadel of Ricks',
        'location_url': 'https://example.com/locations/3',
        'image_url': 'https://example.com/images/1.png',
        'episodes_urls': jsonEncode([
          'https://example.com/episodes/1',
          'https://example.com/episodes/2',
        ]),
      };

      final c = CharacterDbMapper.fromMap(row);

      expect(c.id, 1);
      expect(c.name, 'Rick Sanchez');
      expect(c.status, CharacterStatus.alive);
      expect(c.species, 'Human');
      expect(c.type, '');
      expect(c.gender, CharacterGender.male);

      expect(c.origin.name, 'Earth');
      expect(c.origin.uri.toString(), 'https://example.com/locations/1');

      expect(c.location.name, 'Citadel of Ricks');
      expect(c.location.uri.toString(), 'https://example.com/locations/3');

      expect(c.image.toString(), 'https://example.com/images/1.png');
      expect(c.episodesUrls.map((e) => e.toString()).toList(), [
        'https://example.com/episodes/1',
        'https://example.com/episodes/2',
      ]);
    });

    test('parses id from num (double -> int)', () {
      final row = <String, Object?>{
        'id': 5.0,
        'name': 'Test',
        'status': 'alive',
        'species': 'Human',
        'type': '',
        'gender': 'male',
        'origin_name': 'Earth',
        'origin_url': 'https://example.com/locations/1',
        'location_name': 'Earth',
        'location_url': 'https://example.com/locations/1',
        'image_url': 'https://example.com/images/5.png',
        'episodes_urls': '[]',
      };

      final c = CharacterDbMapper.fromMap(row);

      expect(c.id, 5);
    });

    test('falls back to unknown for invalid status and gender', () {
      final row = <String, Object?>{
        'id': 1,
        'name': 'Test',
        'status': 'not_a_status',
        'species': 'Human',
        'type': '',
        'gender': 'not_a_gender',
        'origin_name': 'Earth',
        'origin_url': 'https://example.com/locations/1',
        'location_name': 'Earth',
        'location_url': 'https://example.com/locations/1',
        'image_url': 'https://example.com/images/1.png',
        'episodes_urls': '[]',
      };

      final c = CharacterDbMapper.fromMap(row);

      expect(c.status, CharacterStatus.unknown);
      expect(c.gender, CharacterGender.unknown);
    });

    test('handles missing/empty origin_url and location_url as null', () {
      final row = <String, Object?>{
        'id': 1,
        'name': 'Test',
        'status': 'alive',
        'species': 'Human',
        'type': '',
        'gender': 'male',
        'origin_name': 'Earth',
        'origin_url': '',
        'location_name': 'Earth',
        'location_url': null,
        'image_url': 'https://example.com/images/1.png',
        'episodes_urls': '[]',
      };

      final c = CharacterDbMapper.fromMap(row);

      expect(c.origin.uri, isNull);
      expect(c.location.uri, isNull);
    });

    test('episodes_urls defaults to empty list when missing', () {
      final row = <String, Object?>{
        'id': 1,
        'name': 'Test',
        'status': 'alive',
        'species': 'Human',
        'type': '',
        'gender': 'male',
        'origin_name': 'Earth',
        'origin_url': 'https://example.com/locations/1',
        'location_name': 'Earth',
        'location_url': 'https://example.com/locations/1',
        'image_url': 'https://example.com/images/1.png',
      };

      final c = CharacterDbMapper.fromMap(row);

      expect(c.episodesUrls, isEmpty);
    });

    test('episodes_urls becomes empty list when json is not a List', () {
      final row = <String, Object?>{
        'id': 1,
        'name': 'Test',
        'status': 'alive',
        'species': 'Human',
        'type': '',
        'gender': 'male',
        'origin_name': 'Earth',
        'origin_url': 'https://example.com/locations/1',
        'location_name': 'Earth',
        'location_url': 'https://example.com/locations/1',
        'image_url': 'https://example.com/images/1.png',
        'episodes_urls': jsonEncode({'a': 1}),
      };

      final c = CharacterDbMapper.fromMap(row);

      expect(c.episodesUrls, isEmpty);
    });
  });
}

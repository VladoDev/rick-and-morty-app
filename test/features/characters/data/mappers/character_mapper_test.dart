import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_app/features/characters/data/dtos/character_dto.dart';
import 'package:rick_and_morty_app/features/characters/data/mappers/character_mapper.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';

void main() {
  group('CharacterMapper.toEntity', () {
    test(
      'maps and trims fields, and maps status/gender case-insensitively',
      () {
        final dto = CharacterDto(
          id: 1,
          name: '  Rick Sanchez  ',
          status: ' ALIVE ',
          species: ' Human ',
          type: '  ',
          gender: ' MaLe ',
          origin: const NamedResourceDto(
            name: '  Earth  ',
            url: '  https://example.com/locations/1  ',
          ),
          location: const NamedResourceDto(
            name: '  Citadel of Ricks  ',
            url: '  https://example.com/locations/3  ',
          ),
          image: '  https://example.com/images/rick.png  ',
          episode: const [
            'https://example.com/episodes/1',
            'https://example.com/episodes/2',
          ],
        );

        final entity = CharacterMapper.toEntity(dto);

        expect(entity.id, 1);
        expect(entity.name, 'Rick Sanchez');
        expect(entity.status, CharacterStatus.alive);
        expect(entity.species, 'Human');
        expect(entity.type, '');
        expect(entity.gender, CharacterGender.male);

        expect(entity.origin.name, 'Earth');
        expect(entity.origin.uri.toString(), 'https://example.com/locations/1');

        expect(entity.location.name, 'Citadel of Ricks');
        expect(
          entity.location.uri.toString(),
          'https://example.com/locations/3',
        );

        expect(entity.image.toString(), 'https://example.com/images/rick.png');

        expect(entity.episodesUrls.map((e) => e.toString()).toList(), [
          'https://example.com/episodes/1',
          'https://example.com/episodes/2',
        ]);
      },
    );

    test('maps unknown status and gender to unknown', () {
      final dto = CharacterDto(
        id: 1,
        name: 'Rick',
        status: 'something-else',
        species: 'Human',
        type: '',
        gender: 'alien',
        origin: const NamedResourceDto(name: 'Earth', url: null),
        location: const NamedResourceDto(name: 'Earth', url: null),
        image: 'https://example.com/images/rick.png',
        episode: const [],
      );

      final entity = CharacterMapper.toEntity(dto);

      expect(entity.status, CharacterStatus.unknown);
      expect(entity.gender, CharacterGender.unknown);
    });

    test(
      'maps origin/location uri as null when url is null or empty/whitespace',
      () {
        final dto = CharacterDto(
          id: 1,
          name: 'Rick',
          status: 'alive',
          species: 'Human',
          type: '',
          gender: 'male',
          origin: const NamedResourceDto(name: 'Earth', url: null),
          location: const NamedResourceDto(name: 'Earth', url: '   '),
          image: 'https://example.com/images/rick.png',
          episode: const [],
        );

        final entity = CharacterMapper.toEntity(dto);

        expect(entity.origin.uri, isNull);
        expect(entity.location.uri, isNull);
      },
    );

    test('uses about:blank when image is empty or whitespace', () {
      final dto = CharacterDto(
        id: 1,
        name: 'Rick',
        status: 'alive',
        species: 'Human',
        type: '',
        gender: 'male',
        origin: const NamedResourceDto(name: 'Earth', url: null),
        location: const NamedResourceDto(name: 'Earth', url: null),
        image: '   ',
        episode: const [],
      );

      final entity = CharacterMapper.toEntity(dto);

      expect(entity.image.toString(), 'about:blank');
    });

    test(
      'uses Uri.tryParse for origin/location and returns null for invalid url',
      () {
        final dto = CharacterDto(
          id: 1,
          name: 'Rick',
          status: 'alive',
          species: 'Human',
          type: '',
          gender: 'male',
          origin: const NamedResourceDto(name: 'Earth', url: 'http://ok.com'),
          location: const NamedResourceDto(
            name: 'Bad',
            url: '::::not-a-url::::',
          ),
          image: 'https://example.com/images/rick.png',
          episode: const [],
        );

        final entity = CharacterMapper.toEntity(dto);

        expect(entity.origin.uri.toString(), 'http://ok.com');
        expect(entity.location.uri, isNull);
      },
    );

    test('parses episode urls as Uri list', () {
      final dto = CharacterDto(
        id: 1,
        name: 'Rick',
        status: 'alive',
        species: 'Human',
        type: '',
        gender: 'male',
        origin: const NamedResourceDto(name: 'Earth', url: null),
        location: const NamedResourceDto(name: 'Earth', url: null),
        image: 'https://example.com/images/rick.png',
        episode: const ['https://example.com/episodes/1'],
      );

      final entity = CharacterMapper.toEntity(dto);

      expect(entity.episodesUrls.length, 1);
      expect(entity.episodesUrls.first, isA<Uri>());
      expect(
        entity.episodesUrls.first.toString(),
        'https://example.com/episodes/1',
      );
    });

    test(
      'throws FormatException when an episode url is invalid (current behavior)',
      () {
        final dto = CharacterDto(
          id: 1,
          name: 'Rick',
          status: 'alive',
          species: 'Human',
          type: '',
          gender: 'male',
          origin: const NamedResourceDto(name: 'Earth', url: null),
          location: const NamedResourceDto(name: 'Earth', url: null),
          image: 'https://example.com/images/rick.png',
          episode: const ['::::not-a-url::::'],
        );

        expect(
          () => CharacterMapper.toEntity(dto),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}

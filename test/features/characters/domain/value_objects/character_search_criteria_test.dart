import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_app/features/characters/domain/value_objects/character_filters.dart';

void main() {
  group('CharacterSearchCriteria', () {
    test('defaults page to 1', () {
      const criteria = CharacterSearchCriteria();
      expect(criteria.page, 1);
    });

    test('throws AssertionError when page is < 1', () {
      expect(
        () => CharacterSearchCriteria(page: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

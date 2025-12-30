import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';

abstract interface class FavoriteCharactersRepository {
  Future<List<Character>> getFavoriteCharacters();
  Future<bool> isFavorite(int id);
  Future<void> addFavorite(Character character);
  Future<void> removeFavorite(int id);
}

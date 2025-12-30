import 'package:rick_and_morty_app/features/characters/data/datasources/local/favorites_local_data_source.dart';
import 'package:rick_and_morty_app/features/characters/data/mappers/character_db_mapper.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/repositories/favorite_characters_repository.dart';

class FavoritesRepositoryImpl implements FavoriteCharactersRepository {
  final FavoritesLocalDataSource _local;
  const FavoritesRepositoryImpl(this._local);

  @override
  Future<void> addFavorite(Character character) async {
    await _local.upsert(CharacterDbMapper.toMap(character));
  }

  @override
  Future<List<Character>> getFavoriteCharacters() async {
    final rows = await _local.getFavoritesRows();
    return rows.map(CharacterDbMapper.fromMap).toList();
  }

  @override
  Future<bool> isFavorite(int id) => _local.exists(id);

  @override
  Future<void> removeFavorite(int id) => _local.delete(id);
}

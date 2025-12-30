import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/repositories/favorite_characters_repository.dart';

class GetFavoriteCharactersUsecase {
  final FavoriteCharactersRepository _repo;
  const GetFavoriteCharactersUsecase(this._repo);

  Future<List<Character>> call() => _repo.getFavoriteCharacters();
}

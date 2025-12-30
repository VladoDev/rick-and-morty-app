import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/repositories/favorite_characters_repository.dart';

class AddFavoriteUsecase {
  final FavoriteCharactersRepository _repo;
  const AddFavoriteUsecase(this._repo);

  Future<void> call(Character character) => _repo.addFavorite(character);
}

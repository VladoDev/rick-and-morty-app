import 'package:rick_and_morty_app/features/characters/domain/repositories/favorite_characters_repository.dart';

class RemoveFavoriteUsecase {
  final FavoriteCharactersRepository _repo;
  const RemoveFavoriteUsecase(this._repo);

  Future<void> call(int id) => _repo.removeFavorite(id);
}

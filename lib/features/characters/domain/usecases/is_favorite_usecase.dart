import 'package:rick_and_morty_app/features/characters/domain/repositories/favorite_characters_repository.dart';

class IsFavoriteUsecase {
  final FavoriteCharactersRepository _repo;
  const IsFavoriteUsecase(this._repo);

  Future<bool> call(int id) => _repo.isFavorite(id);
}

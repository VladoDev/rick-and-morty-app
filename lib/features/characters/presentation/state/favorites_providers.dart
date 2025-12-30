import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rick_and_morty_app/features/characters/data/datasources/local/favorites_db.dart';
import 'package:rick_and_morty_app/features/characters/data/datasources/local/favorites_local_data_source.dart';
import 'package:rick_and_morty_app/features/characters/data/repositories/favorites_repository_impl.dart';
import 'package:rick_and_morty_app/features/characters/domain/repositories/favorite_characters_repository.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/add_favorite_usecase.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/get_favorites_characters_usecase.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/is_favorite_usecase.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/remove_favorite_usecase.dart';

final favoritesDbProvider = Provider<FavoritesDb>((ref) => FavoritesDb());

final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>((
  ref,
) {
  return FavoritesLocalDataSourceImpl(ref.watch(favoritesDbProvider));
});

final favoritesRepositoryProvider = Provider<FavoriteCharactersRepository>((
  ref,
) {
  return FavoritesRepositoryImpl(ref.watch(favoritesLocalDataSourceProvider));
});

final getFavoritesUseCaseProvider = Provider<GetFavoriteCharactersUsecase>((
  ref,
) {
  return GetFavoriteCharactersUsecase(ref.watch(favoritesRepositoryProvider));
});

final isFavoriteUseCaseProvider = Provider<IsFavoriteUsecase>((ref) {
  return IsFavoriteUsecase(ref.watch(favoritesRepositoryProvider));
});

final addFavoriteUseCaseProvider = Provider<AddFavoriteUsecase>((ref) {
  return AddFavoriteUsecase(ref.watch(favoritesRepositoryProvider));
});

final removeFavoriteUseCaseProvider = Provider<RemoveFavoriteUsecase>((ref) {
  return RemoveFavoriteUsecase(ref.watch(favoritesRepositoryProvider));
});

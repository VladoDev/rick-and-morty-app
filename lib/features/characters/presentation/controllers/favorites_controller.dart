import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rick_and_morty_app/features/characters/presentation/state/favorites_providers.dart';

import '../../domain/entities/character.dart';

class FavoritesController extends AsyncNotifier<List<Character>> {
  @override
  Future<List<Character>> build() async {
    final getFavorites = ref.read(getFavoritesUseCaseProvider);
    return getFavorites();
  }

  Future<void> refresh() async {
    final getFavorites = ref.read(getFavoritesUseCaseProvider);
    state = const AsyncLoading();
    state = AsyncData(await getFavorites());
  }

  Future<void> toggle(Character character) async {
    final current = state.asData?.value ?? const <Character>[];

    final isFav = current.any((c) => c.id == character.id);

    if (isFav) {
      state = AsyncData(current.where((c) => c.id != character.id).toList());
    } else {
      state = AsyncData([...current, character]);
    }

    try {
      if (isFav) {
        await ref.read(removeFavoriteUseCaseProvider)(character.id);
      } else {
        await ref.read(addFavoriteUseCaseProvider)(character);
      }

      final getFavorites = ref.read(getFavoritesUseCaseProvider);
      state = AsyncData(await getFavorites());
    } catch (e, st) {
      state = AsyncError(e, st);
      final getFavorites = ref.read(getFavoritesUseCaseProvider);
      state = AsyncData(await getFavorites());
    }
  }
}

final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, List<Character>>(
      FavoritesController.new,
    );

final favoriteIdsProvider = Provider<Set<int>>((ref) {
  final favs =
      ref.watch(favoritesControllerProvider).asData?.value ??
      const <Character>[];
  return favs.map((c) => c.id).toSet();
});

final isFavoriteProvider = Provider.family<bool, int>((ref, id) {
  return ref.watch(favoriteIdsProvider).contains(id);
});

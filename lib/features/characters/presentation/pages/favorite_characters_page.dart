import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rick_and_morty_app/features/characters/presentation/controllers/favorites_controller.dart';
import 'package:rick_and_morty_app/features/characters/presentation/widgets/character_card.dart';

class FavoriteCharactersPage extends ConsumerWidget {
  const FavoriteCharactersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsState = ref.watch(favoritesControllerProvider);

    return favsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (favs) {
        if (favs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_border, size: 56),
                  const SizedBox(height: 12),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse characters and tap the star to save your favorites here.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.go('/search-characters'),
                    icon: const Icon(Icons.search),
                    label: const Text('Go to Search'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: favs.length,
          itemBuilder: (context, index) {
            final character = favs[index];
            return CharacterCard(
              character: character,
              onCharacterTap: () {
                context.push(
                  "/search-characters/${character.id}",
                  extra: character,
                );
              },
            );
          },
        );
      },
    );
  }
}

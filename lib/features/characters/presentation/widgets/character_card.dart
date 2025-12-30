import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/presentation/controllers/favorites_controller.dart';

class CharacterCard extends ConsumerWidget {
  final Character character;
  final VoidCallback onCharacterTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onCharacterTap,
  });

  String _statusText(CharacterStatus s) {
    switch (s) {
      case CharacterStatus.alive:
        return 'Alive';
      case CharacterStatus.dead:
        return 'Dead';
      case CharacterStatus.unknown:
        return 'Unknown';
    }
  }

  String _genderText(CharacterGender g) {
    switch (g) {
      case CharacterGender.female:
        return 'Female';
      case CharacterGender.male:
        return 'Male';
      case CharacterGender.genderless:
        return 'Genderless';
      case CharacterGender.unknown:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isFavoriteProvider(character.id));
    final subtitle = [
      character.species.trim().isEmpty ? null : character.species,
      character.type.trim().isEmpty ? null : character.type,
      '${_statusText(character.status)} • ${_genderText(character.gender)}',
    ].whereType<String>().join(' • ');

    return GestureDetector(
      onTap: () {
        onCharacterTap.call();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Hero(
              tag: "character-image-${character.id}",
              child: Material(
                color: Colors.transparent,
                child: CachedNetworkImage(
                  imageUrl: character.image.toString(),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
          ),
          title: Text(character.name),
          subtitle: Text(subtitle),
          trailing: IconButton(
            icon: Icon(isFav ? Icons.star : Icons.star_border),
            color: isFav ? Colors.amber : null,
            onPressed: () => ref
                .read(favoritesControllerProvider.notifier)
                .toggle(character),
          ),
        ),
      ),
    );
  }
}

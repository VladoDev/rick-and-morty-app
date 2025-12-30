import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rick_and_morty_app/features/search_characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/search_characters/presentation/controllers/character_details_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class CharacterDetailsPage extends ConsumerWidget {
  final String characterId;
  final Character? character;
  final CharacterDetailsController Function() characterDetailsController;

  const CharacterDetailsPage({
    super.key,
    required this.characterId,
    required this.characterDetailsController,
    this.character,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = character;

    if (c == null) {
      return const Center(child: CircularProgressIndicator());
    }

    String episodeLabel(Uri uri) {
      final last = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      return last.isNotEmpty ? 'Episode $last' : uri.toString();
    }

    IconData statusIcon() {
      switch (c.status) {
        case CharacterStatus.alive:
          return Icons.favorite;
        case CharacterStatus.dead:
          return Icons.heart_broken;
        case CharacterStatus.unknown:
          return Icons.help_outline;
      }
    }

    String statusText() => c.status.name.toUpperCase();
    String genderText() => c.gender.name.toUpperCase();

    Future<void> openEpisodeUrl(BuildContext context, Uri uri) async {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo abrir: $uri')));
      }
    }

    const bool isFavorite = false; // TODO: conectar a riverpod
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: "character-image-${c.id}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CachedNetworkImage(
                        imageUrl: c.image.toString(),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const SizedBox(
                          width: 120,
                          height: 120,
                          child: Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              c.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            IconButton(
                              tooltip: isFavorite
                                  ? 'Quitar de favoritos'
                                  : 'Agregar a favoritos',
                              icon: Icon(
                                isFavorite ? Icons.star : Icons.star_border,
                              ),
                              onPressed: () {
                                // TODO: implementar toggle favorito (Riverpod/controller)
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              avatar: Icon(statusIcon(), size: 18),
                              label: Text(statusText()),
                            ),
                            Chip(label: Text(c.species)),
                            Chip(label: Text(genderText())),
                            if (c.type.trim().isNotEmpty)
                              Chip(label: Text(c.type)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: _InfoCard(
                title: 'Origen',
                subtitle: 'Lugar de origen del personaje',
                leading: Icons.public,
                content: c.origin.name,
                trailingText: c.origin.uri == null ? null : 'Ver',
                onTap: c.origin.uri == null ? null : () {},
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _InfoCard(
                title: 'Última ubicación conocida',
                subtitle: 'Ubicación actual según el API',
                leading: Icons.place,
                content: c.location.name,
                trailingText: c.location.uri == null ? null : 'Ver',
                onTap: c.location.uri == null ? null : () {},
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: Row(
                children: [
                  Text(
                    'Episodios',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${c.episodesUrls.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),

          SliverList.separated(
            itemCount: c.episodesUrls.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final uri = c.episodesUrls[index];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.tv),
                title: Text(episodeLabel(uri)),
                subtitle: Text(
                  uri.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openEpisodeUrl(context, uri),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData leading;
  final String content;
  final String? trailingText;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.title,
    this.subtitle,
    required this.leading,
    required this.content,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(leading, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(content, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              if (trailingText != null) ...[
                const SizedBox(width: 8),
                Text(
                  trailingText!,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

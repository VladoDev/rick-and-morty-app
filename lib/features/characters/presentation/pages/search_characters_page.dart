import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/presentation/controllers/favorites_controller.dart';
import 'package:rick_and_morty_app/features/characters/presentation/state/search_characters_state.dart';
import 'package:rick_and_morty_app/features/characters/presentation/widgets/character_card.dart';
import 'package:rick_and_morty_app/features/characters/presentation/widgets/search_characters_search_bar.dart';

class SearchCharactersPage extends ConsumerWidget {
  const SearchCharactersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchCharactersControllerProvider);
    final controller = ref.read(searchCharactersControllerProvider.notifier);
    ref.watch(favoritesControllerProvider);

    return Column(
      children: [
        SearchCharactersSearchBar(
          initialValue: state.query,
          isLoading: state.isLoading,
          onChanged: controller.setQuery,
          onSubmitted: (_) => controller.search(reset: true),
          onSearchPressed: () => controller.search(reset: true),
        ),
        if (state.errorMessage != null)
          MaterialBanner(
            content: Text(state.errorMessage!),
            actions: [
              TextButton(
                onPressed: controller.retry,
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        Expanded(
          child: _Body(
            isLoading: state.isLoading,
            items: state.items,
            hasNext: state.hasNextPage,
            onLoadMore: controller.loadNextPage,
          ),
        ),
      ],
    );
  }
}

class _Body extends StatefulWidget {
  final bool isLoading;
  final List<dynamic> items;
  final bool hasNext;
  final VoidCallback onLoadMore;

  const _Body({
    required this.isLoading,
    required this.items,
    required this.hasNext,
    required this.onLoadMore,
  });

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final ScrollController _scrollController;
  static const double _loadMoreThresholdPx = 300.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (!widget.hasNext || widget.isLoading) return;

    final isNearBottom =
        _scrollController.position.extentAfter < _loadMoreThresholdPx;
    if (isNearBottom) {
      widget.onLoadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No results. Try another search.'),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.items.length + 1,
      itemBuilder: (context, index) {
        if (index < widget.items.length) {
          Character character = widget.items[index];
          return CharacterCard(
            character: character,
            onCharacterTap: () {
              context.push(
                "/search-characters/${character.id}",
                extra: character,
              );
            },
          );
        }

        if (!widget.hasNext) {
          return const SizedBox(height: 16);
        }

        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rick_and_morty_app/app/di/service_locator.dart';
import 'package:rick_and_morty_app/features/characters/domain/common/paginated.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/search_characters_usecase.dart';
import 'package:rick_and_morty_app/features/characters/domain/value_objects/character_filters.dart';
import 'package:rick_and_morty_app/features/characters/presentation/controllers/search_characters_controller.dart';

final searchCharactersUseCaseProvider = Provider<SearchCharactersUsecase>((
  ref,
) {
  return sl<SearchCharactersUsecase>();
});

final searchCharactersControllerProvider =
    StateNotifierProvider.autoDispose<
      SearchCharactersController,
      SearchCharactersState
    >((ref) {
      final useCase = ref.watch(searchCharactersUseCaseProvider);
      return SearchCharactersController(useCase);
    });

class SearchCharactersState {
  final String query;
  final CharacterStatus? status;
  final CharacterGender? gender;
  final String? species;
  final String? type;

  final int page;
  final PageInfo info;
  final List<Character> items;

  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  const SearchCharactersState({
    required this.query,
    required this.status,
    required this.gender,
    required this.species,
    required this.type,
    required this.page,
    required this.info,
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.isLoadingMore,
  });

  factory SearchCharactersState.initial() => const SearchCharactersState(
    query: '',
    status: null,
    gender: null,
    species: null,
    type: null,
    page: 1,
    info: PageInfo(count: 0, pages: 0, next: null, prev: null),
    items: [],
    isLoading: false,
    isLoadingMore: false,
    errorMessage: null,
  );

  bool get hasNextPage => info.next != null;

  SearchCharactersState copyWith({
    String? query,
    CharacterStatus? status,
    CharacterGender? gender,
    String? species,
    String? type,
    int? page,
    PageInfo? info,
    List<Character>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchCharactersState(
      query: query ?? this.query,
      status: status ?? this.status,
      gender: gender ?? this.gender,
      species: species ?? this.species,
      type: type ?? this.type,
      page: page ?? this.page,
      info: info ?? this.info,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  CharacterSearchCriteria toCriteria() {
    final q = query.trim();
    return CharacterSearchCriteria(
      page: page,
      name: q.isEmpty ? null : q,
      status: status,
      gender: gender,
      species: species?.trim().isEmpty == true ? null : species?.trim(),
      type: type?.trim().isEmpty == true ? null : type?.trim(),
    );
  }
}

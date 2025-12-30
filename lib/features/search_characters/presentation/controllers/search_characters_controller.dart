import 'package:flutter_riverpod/legacy.dart';

import 'package:rick_and_morty_app/core/errors/app_exception.dart';

import 'package:rick_and_morty_app/features/search_characters/domain/common/paginated.dart';
import 'package:rick_and_morty_app/features/search_characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/search_characters/domain/usecases/search_characters_usecase.dart';
import 'package:rick_and_morty_app/features/search_characters/presentation/state/search_characters_state.dart';

class SearchCharactersController extends StateNotifier<SearchCharactersState> {
  final SearchCharactersUsecase _useCase;

  SearchCharactersController(this._useCase)
    : super(SearchCharactersState.initial());

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void setStatus(CharacterStatus? value) {
    state = state.copyWith(status: value);
  }

  void setGender(CharacterGender? value) {
    state = state.copyWith(gender: value);
  }

  void setSpecies(String? value) {
    state = state.copyWith(species: value);
  }

  void setType(String? value) {
    state = state.copyWith(type: value);
  }

  Future<void> search({bool reset = true}) async {
    if (state.isLoading || state.isLoadingMore) return;

    state = state.copyWith(
      page: 1,
      isLoading: true,
      clearError: true,
      items: const [],
      info: const PageInfo(count: 0, pages: 0, next: null, prev: null),
    );

    final result = await _useCase(state.toCriteria());

    result.when(
      ok: (data) {
        state = state.copyWith(
          isLoading: false,
          info: data.info,
          items: data.results,
        );
      },
      err: (error, st) {
        final message = (error is AppException)
            ? error.message
            : error.toString();
        state = state.copyWith(isLoading: false, errorMessage: message);
      },
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore) return;
    if (!state.hasNextPage) return;

    final nextPage = state.page + 1;

    state = state.copyWith(
      page: nextPage,
      isLoadingMore: true,
      clearError: true,
    );

    final result = await _useCase(state.toCriteria());

    result.when(
      ok: (data) {
        state = state.copyWith(
          isLoadingMore: false,
          info: data.info,
          items: [...state.items, ...data.results],
        );
      },
      err: (error, st) {
        final message = (error is AppException)
            ? error.message
            : error.toString();
        state = state.copyWith(isLoadingMore: false, errorMessage: message);
      },
    );
  }

  Future<void> retry() => search(reset: state.items.isEmpty);
}

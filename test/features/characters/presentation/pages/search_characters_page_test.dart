import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rick_and_morty_app/core/result/result.dart';
import 'package:rick_and_morty_app/features/characters/domain/common/paginated.dart';
import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/domain/repositories/character_repository.dart';
import 'package:rick_and_morty_app/features/characters/domain/usecases/search_characters_usecase.dart';
import 'package:rick_and_morty_app/features/characters/domain/value_objects/character_filters.dart';

import 'package:rick_and_morty_app/features/characters/presentation/controllers/favorites_controller.dart';
import 'package:rick_and_morty_app/features/characters/presentation/pages/search_characters_page.dart';
import 'package:rick_and_morty_app/features/characters/presentation/state/search_characters_state.dart';
import 'package:rick_and_morty_app/features/characters/presentation/controllers/search_characters_controller.dart';
import 'package:rick_and_morty_app/features/characters/presentation/widgets/character_card.dart';

final _transparentPngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO5nK9kAAAAASUVORK5CYII=',
);

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

class _FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _FakeHttpClientRequest(url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest(url);

  @override
  void close({bool force = false}) {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  final Uri _url;
  _FakeHttpClientRequest(this._url);

  @override
  Uri get uri => _url;

  @override
  Future<HttpClientResponse> close() async =>
      _FakeHttpClientResponse(_transparentPngBytes);

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final List<int> _bytes;
  _FakeHttpClientResponse(this._bytes);

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _bytes.length;

  @override
  HttpHeaders get headers => _FakeHttpHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestFavoritesController extends FavoritesController {
  final List<Character> initial;
  TestFavoritesController(this.initial);

  @override
  Future<List<Character>> build() async => initial;
}

class MockCharacterRepository extends Mock implements CharacterRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
    registerFallbackValue(const CharacterSearchCriteria());
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  Character c(int id, String name) => Character(
    id: id,
    name: name,
    status: CharacterStatus.alive,
    species: 'Human',
    type: '',
    gender: CharacterGender.male,
    origin: NamedResource(
      name: 'Earth',
      uri: Uri.parse('https://example.com/locations/1'),
    ),
    location: NamedResource(
      name: 'Earth',
      uri: Uri.parse('https://example.com/locations/1'),
    ),
    image: Uri.parse('https://example.com/images/$id.png'),
    episodesUrls: [Uri.parse('https://example.com/episodes/1')],
  );

  Paginated<Character> page({
    required PageInfo info,
    required List<Character> results,
  }) => Paginated<Character>(info: info, results: results);

  GoRouter makeRouter() => GoRouter(
    initialLocation: '/search-characters',
    routes: [
      GoRoute(
        path: '/search-characters',
        builder: (_, _) => const Scaffold(body: SearchCharactersPage()),
      ),
      GoRoute(
        path: '/search-characters/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          final name = (extra is Character) ? extra.name : 'no-extra';
          return Scaffold(body: Center(child: Text('Details $id $name')));
        },
      ),
    ],
  );

  testWidgets('initially shows empty state text', (tester) async {
    final repo = MockCharacterRepository();
    final usecase = SearchCharactersUsecase(repo);
    final controller = SearchCharactersController(usecase);

    final container = ProviderContainer(
      overrides: [
        searchCharactersControllerProvider.overrideWith((ref) => controller),
        favoritesControllerProvider.overrideWith(
          () => TestFavoritesController(const []),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: makeRouter()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('No results. Try another search.'), findsOneWidget);
  });

  testWidgets('shows loading spinner while search is in-flight', (
    tester,
  ) async {
    final repo = MockCharacterRepository();
    final usecase = SearchCharactersUsecase(repo);
    final controller = SearchCharactersController(usecase);

    final completer = Completer<Result<Paginated<Character>>>();
    when(
      () => repo.searchCharacters(any()),
    ).thenAnswer((_) => completer.future);

    final container = ProviderContainer(
      overrides: [
        searchCharactersControllerProvider.overrideWith((ref) => controller),
        favoritesControllerProvider.overrideWith(
          () => TestFavoritesController(const []),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: makeRouter()),
      ),
    );

    unawaited(
      container.read(searchCharactersControllerProvider.notifier).search(),
    );

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    completer.complete(
      Ok(
        page(
          info: const PageInfo(count: 0, pages: 0, next: null, prev: null),
          results: const [],
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('No results. Try another search.'), findsOneWidget);
  });

  testWidgets('renders results as CharacterCard and navigates on tap', (
    tester,
  ) async {
    final repo = MockCharacterRepository();
    final usecase = SearchCharactersUsecase(repo);
    final controller = SearchCharactersController(usecase);

    when(() => repo.searchCharacters(any())).thenAnswer(
      (_) async => Ok(
        page(
          info: const PageInfo(count: 2, pages: 1, next: null, prev: null),
          results: [c(1, 'Rick'), c(2, 'Morty')],
        ),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        searchCharactersControllerProvider.overrideWith((ref) => controller),
        favoritesControllerProvider.overrideWith(
          () => TestFavoritesController(const []),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: makeRouter()),
      ),
    );

    await container.read(searchCharactersControllerProvider.notifier).search();
    await tester.pumpAndSettle();

    expect(find.byType(CharacterCard), findsNWidgets(2));

    await tester.tap(find.text('Rick'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Details 1'), findsOneWidget);
    expect(find.textContaining('Rick'), findsOneWidget);
  });
}

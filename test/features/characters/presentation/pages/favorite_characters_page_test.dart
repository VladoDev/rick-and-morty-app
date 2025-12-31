import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/presentation/controllers/favorites_controller.dart';
import 'package:rick_and_morty_app/features/characters/presentation/pages/favorite_characters_page.dart';
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
  Future<HttpClientResponse> close() async {
    return _FakeHttpClientResponse(_transparentPngBytes);
  }

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

class LoadingFavoritesController extends FavoritesController {
  @override
  Future<List<Character>> build() => Completer<List<Character>>().future;
}

class ErrorFavoritesController extends FavoritesController {
  final Object error;
  ErrorFavoritesController(this.error);

  @override
  Future<List<Character>> build() => Future<List<Character>>.error(error);
}

class DataFavoritesController extends FavoritesController {
  final List<Character> data;
  DataFavoritesController(this.data);

  @override
  Future<List<Character>> build() async => data;
}

Character buildCharacter(int id, String name) {
  return Character(
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
      name: 'Citadel of Ricks',
      uri: Uri.parse('https://example.com/locations/3'),
    ),
    image: Uri.parse('https://example.com/images/$id.png'),
    episodesUrls: [Uri.parse('https://example.com/episodes/1')],
  );
}

GoRouter makeRouter() {
  return GoRouter(
    initialLocation: '/favorites',
    routes: [
      GoRoute(
        path: '/favorites',
        builder: (_, __) => const FavoriteCharactersPage(),
      ),
      GoRoute(
        path: '/search-characters',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Search Page'))),
      ),
      GoRoute(
        path: '/search-characters/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          final name = extra is Character ? extra.name : 'no-extra';
          return Scaffold(body: Center(child: Text('Details $id $name')));
        },
      ),
    ],
  );
}

String explainsName(Character c) => c.name;

Future<void> pumpApp(
  WidgetTester tester, {
  required FavoritesController controller,
}) async {
  final router = makeRouter();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [favoritesControllerProvider.overrideWith(() => controller)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('FavoriteCharactersPage', () {
    testWidgets('shows loader while favorites are loading', (tester) async {
      await pumpApp(tester, controller: LoadingFavoritesController());

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'when empty, shows empty state and navigates to search on button tap',
      (tester) async {
        await pumpApp(tester, controller: DataFavoritesController(const []));

        await tester.pumpAndSettle();

        expect(find.text('No favorites yet'), findsOneWidget);
        expect(find.byIcon(Icons.star_border), findsOneWidget);
        expect(find.text('Go to Search'), findsOneWidget);

        await tester.tap(find.text('Go to Search'));
        await tester.pumpAndSettle();

        expect(find.text('Search Page'), findsOneWidget);
      },
    );

    testWidgets(
      'when has data, renders list and navigates to details on card tap',
      (tester) async {
        final rick = buildCharacter(1, 'Rick Sanchez');

        await pumpApp(tester, controller: DataFavoritesController([rick]));
        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(CharacterCard), findsOneWidget);

        final card = find.byType(CharacterCard).first;
        final tappable = find.descendant(
          of: card,
          matching: find.byType(InkWell),
        );

        if (tappable.evaluate().isNotEmpty) {
          await tester.tap(tappable.first);
        } else {
          await tester.tap(card);
        }

        await tester.pumpAndSettle();

        expect(find.textContaining('Details 1'), findsOneWidget);
        expect(find.textContaining('Rick Sanchez'), findsOneWidget);
      },
    );
  });
}

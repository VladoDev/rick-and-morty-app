import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/presentation/controllers/favorites_controller.dart';
import 'package:rick_and_morty_app/features/characters/presentation/pages/character_details_page.dart';

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

class TestFavoritesController extends FavoritesController {
  TestFavoritesController(this.initial);
  final List<Character> initial;

  @override
  Future<List<Character>> build() async => initial;

  @override
  Future<void> toggle(Character character) async {
    final current = state.asData?.value ?? const <Character>[];
    final isFav = current.any((c) => c.id == character.id);

    final next = isFav
        ? current.where((c) => c.id != character.id).toList()
        : [...current, character];

    state = AsyncData(next);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  Character buildCharacter({
    required int id,
    required String name,
    List<Uri>? episodes,
  }) {
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
      episodesUrls:
          episodes ??
          <Uri>[
            Uri.parse('https://example.com/episodes/1'),
            Uri.parse('https://example.com/episodes/2'),
          ],
    );
  }

  Widget pumpPage(
    WidgetTester tester, {
    required Character? character,
    List<Character> initialFavorites = const [],
  }) {
    return ProviderScope(
      overrides: [
        favoritesControllerProvider.overrideWith(
          () => TestFavoritesController(initialFavorites),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: CharacterDetailsPage(
            characterId: '1',
            character: character,
            characterDetailsController: () => throw UnimplementedError(),
          ),
        ),
      ),
    );
  }

  group('CharacterDetailsPage', () {
    testWidgets('shows loader when character is null', (tester) async {
      await tester.pumpWidget(pumpPage(tester, character: null));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'renders name, episodes count and episode label without overflow',
      (tester) async {
        final c = buildCharacter(
          id: 1,
          name:
              'Rick Sanchez with an extremely long name that should not overflow the row',
        );

        await tester.pumpWidget(pumpPage(tester, character: c));

        await tester.pumpAndSettle();

        expect(find.textContaining('Episodes'), findsOneWidget);
        expect(find.text('(2)'), findsOneWidget);
        expect(find.text('Episode 1'), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('favorite button toggles star icon', (tester) async {
      final c = buildCharacter(id: 1, name: 'Rick');

      await tester.pumpWidget(
        pumpPage(tester, character: c, initialFavorites: const []),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets(
      'favorite button starts as filled when character is in favorites',
      (tester) async {
        final c = buildCharacter(id: 1, name: 'Rick');

        await tester.pumpWidget(
          pumpPage(tester, character: c, initialFavorites: [c]),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.byIcon(Icons.star_border), findsNothing);
      },
    );
  });
}

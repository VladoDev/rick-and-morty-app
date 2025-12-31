import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rick_and_morty_app/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_app/features/characters/presentation/controllers/favorites_controller.dart';
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

class TestFavoritesController extends FavoritesController {
  TestFavoritesController({required this.initial, this.onToggle});

  final List<Character> initial;
  final void Function(Character c)? onToggle;

  @override
  Future<List<Character>> build() async => initial;

  @override
  Future<void> toggle(Character character) async {
    onToggle?.call(character);

    final current = state.asData?.value ?? initial;
    final isFav = current.any((c) => c.id == character.id);

    final next = isFav
        ? current.where((c) => c.id != character.id).toList()
        : [...current, character];

    state = AsyncData(next);
  }
}

Character buildCharacter({
  required int id,
  required String name,
  String species = 'Human',
  String type = 'Scientist',
  CharacterStatus status = CharacterStatus.alive,
  CharacterGender gender = CharacterGender.male,
}) {
  return Character(
    id: id,
    name: name,
    status: status,
    species: species,
    type: type,
    gender: gender,
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
}

Widget pumpCard({
  required FavoritesController controller,
  required Character character,
  required VoidCallback onTap,
}) {
  return ProviderScope(
    overrides: [favoritesControllerProvider.overrideWith(() => controller)],
    child: MaterialApp(
      home: Scaffold(
        body: CharacterCard(character: character, onCharacterTap: onTap),
      ),
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

  group('CharacterCard', () {
    testWidgets(
      'renders title and computed subtitle (species/type/status/gender)',
      (tester) async {
        final c = buildCharacter(
          id: 1,
          name: 'Rick Sanchez',
          species: 'Human',
          type: 'Scientist',
          status: CharacterStatus.alive,
          gender: CharacterGender.male,
        );

        final controller = TestFavoritesController(initial: const []);

        await tester.pumpWidget(
          pumpCard(controller: controller, character: c, onTap: () {}),
        );
        await tester.pumpAndSettle();

        expect(find.text('Rick Sanchez'), findsOneWidget);
        expect(find.text('Human • Scientist • Alive • Male'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('shows star_border when not favorite; toggles to star on tap', (
      tester,
    ) async {
      final c = buildCharacter(id: 1, name: 'Rick Sanchez');

      Character? toggled;
      final controller = TestFavoritesController(
        initial: const [],
        onToggle: (x) => toggled = x,
      );

      await tester.pumpWidget(
        pumpCard(controller: controller, character: c, onTap: () {}),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(toggled?.id, 1);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('shows star when already favorite', (tester) async {
      final c = buildCharacter(id: 1, name: 'Rick Sanchez');

      final controller = TestFavoritesController(initial: [c]);

      await tester.pumpWidget(
        pumpCard(controller: controller, character: c, onTap: () {}),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('tapping the card triggers onCharacterTap', (tester) async {
      final c = buildCharacter(id: 1, name: 'Rick Sanchez');
      final controller = TestFavoritesController(initial: const []);

      var tapped = false;

      await tester.pumpWidget(
        pumpCard(
          controller: controller,
          character: c,
          onTap: () => tapped = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rick Sanchez'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}

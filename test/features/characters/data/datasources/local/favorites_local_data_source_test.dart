import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rick_and_morty_app/features/characters/data/datasources/local/favorites_local_data_source.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:rick_and_morty_app/features/characters/data/datasources/local/favorites_db.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<String> _dbPath() async {
    final databasesPath = await getDatabasesPath();
    return p.join(databasesPath, 'rick_and_morty.db');
  }

  Map<String, Object?> _row({
    required int id,
    required String name,
    String status = 'alive',
    String species = 'Human',
    String type = '',
    String gender = 'male',
  }) {
    return <String, Object?>{
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'origin_name': 'Earth',
      'origin_url': 'https://example.com/locations/1',
      'location_name': 'Earth',
      'location_url': 'https://example.com/locations/1',
      'image_url': 'https://example.com/images/$id.png',
      'episodes_urls': '["https://example.com/episodes/1"]',
    };
  }

  late FavoritesDb favoritesDb;
  late FavoritesLocalDataSource sut;

  setUp(() async {
    await deleteDatabase(await _dbPath());

    favoritesDb = FavoritesDb();
    sut = FavoritesLocalDataSourceImpl(favoritesDb);
  });

  tearDown(() async {
    final db = await favoritesDb.database;
    await db.close();
    await deleteDatabase(await _dbPath());
  });

  group('FavoritesLocalDataSourceImpl', () {
    test('exists returns false when id is not present', () async {
      final result = await sut.exists(999);
      expect(result, isFalse);
    });

    test('upsert inserts row and exists returns true', () async {
      await sut.upsert(_row(id: 1, name: 'Rick Sanchez'));

      final result = await sut.exists(1);
      expect(result, isTrue);
    });

    test(
      'upsert replaces existing row when same id is inserted again',
      () async {
        await sut.upsert(_row(id: 1, name: 'Rick Sanchez'));
        await sut.upsert(_row(id: 1, name: 'Morty Smith'));

        final rows = await sut.getFavoritesRows();

        expect(rows.length, 1);
        expect(rows.single['id'], 1);
        expect(rows.single['name'], 'Morty Smith');
      },
    );

    test(
      'getFavoritesRows returns rows ordered by name (case-insensitive)',
      () async {
        await sut.upsert(_row(id: 1, name: 'beta'));
        await sut.upsert(_row(id: 2, name: 'Alpha'));
        await sut.upsert(_row(id: 3, name: 'charlie'));

        final rows = await sut.getFavoritesRows();
        final names = rows.map((e) => e['name']).toList();

        expect(names, ['Alpha', 'beta', 'charlie']);
      },
    );

    test('delete removes row and exists returns false', () async {
      await sut.upsert(_row(id: 10, name: 'Summer'));
      expect(await sut.exists(10), isTrue);

      await sut.delete(10);

      expect(await sut.exists(10), isFalse);

      final rows = await sut.getFavoritesRows();
      expect(rows.any((r) => r['id'] == 10), isFalse);
    });

    test('delete on non-existing id does not throw', () async {
      await sut.delete(12345);
      expect(true, isTrue);
    });
  });
}

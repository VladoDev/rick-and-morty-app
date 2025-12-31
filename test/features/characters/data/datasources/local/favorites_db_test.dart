import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rick_and_morty_app/features/characters/data/datasources/local/favorites_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  setUp(() async {
    final path = await _dbPath();
    await deleteDatabase(path);
  });

  tearDown(() async {
    final path = await _dbPath();
    await deleteDatabase(path);
  });

  group('FavoritesDb', () {
    test('opens database and creates favorites table', () async {
      final sut = FavoritesDb();

      final db = await sut.database;

      // Verifica que la tabla exista
      final tables = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', FavoritesDb.favoritesTable],
      );

      expect(tables, isNotEmpty);

      await db.close();
    });

    test('favorites table has expected columns', () async {
      final sut = FavoritesDb();
      final db = await sut.database;

      final result = await db.rawQuery(
        'PRAGMA table_info(${FavoritesDb.favoritesTable});',
      );

      final columnNames = result
          .map((row) => row['name'] as String)
          .toList(growable: false);

      expect(
        columnNames,
        containsAll(<String>[
          'id',
          'name',
          'status',
          'species',
          'type',
          'gender',
          'origin_name',
          'origin_url',
          'location_name',
          'location_url',
          'image_url',
          'episodes_urls',
        ]),
      );

      await db.close();
    });

    test('database getter caches the same Database instance', () async {
      final sut = FavoritesDb();

      final db1 = await sut.database;
      final db2 = await sut.database;

      expect(db1, same(db2));

      await db1.close();
    });

    test('database version is set to 1', () async {
      final sut = FavoritesDb();
      final db = await sut.database;

      final version = await db.getVersion();
      expect(version, 1);

      await db.close();
    });
  });
}

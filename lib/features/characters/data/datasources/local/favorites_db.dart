import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class FavoritesDb {
  static const _dbName = 'rick_and_morty.db';
  static const _dbVersion = 1;

  static const favoritesTable = 'favorites';

  Database? _db;

  Future<Database> get database async {
    final db = _db;
    if (db != null) return db;

    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, _dbName);

    final opened = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $favoritesTable (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            status TEXT NOT NULL,
            species TEXT NOT NULL,
            type TEXT NOT NULL,
            gender TEXT NOT NULL,
            origin_name TEXT NOT NULL,
            origin_url TEXT,
            location_name TEXT NOT NULL,
            location_url TEXT,
            image_url TEXT NOT NULL,
            episodes_urls TEXT NOT NULL
          )
          ''');
      },
    );

    _db = opened;
    return opened;
  }
}

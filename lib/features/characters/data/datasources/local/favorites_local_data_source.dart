import 'package:sqflite/sqflite.dart';

import '../local/favorites_db.dart';

abstract class FavoritesLocalDataSource {
  Future<List<Map<String, Object?>>> getFavoritesRows();
  Future<bool> exists(int id);
  Future<void> upsert(Map<String, Object?> row);
  Future<void> delete(int id);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final FavoritesDb _db;
  const FavoritesLocalDataSourceImpl(this._db);

  @override
  Future<List<Map<String, Object?>>> getFavoritesRows() async {
    final db = await _db.database;
    return db.query(
      FavoritesDb.favoritesTable,
      orderBy: 'name COLLATE NOCASE ASC',
    );
  }

  @override
  Future<bool> exists(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      FavoritesDb.favoritesTable,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<void> upsert(Map<String, Object?> row) async {
    final db = await _db.database;
    await db.insert(
      FavoritesDb.favoritesTable,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete(
      FavoritesDb.favoritesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

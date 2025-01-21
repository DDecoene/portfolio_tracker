import 'package:portfolio_tracker/database/database_core.dart';
import 'package:portfolio_tracker/models/asset.dart';
import 'package:sqflite/sqflite.dart';

class AssetOperations {
  final DatabaseCore _dbCore = DatabaseCore();

  Future<int> insertAsset(Asset asset) async {
    final db = await _dbCore.database;
    return await db.insert('assets', asset.toMap());
  }

  Future<Asset?> getAsset(int id) async {
    final db = await _dbCore.database;
    List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Asset.fromMap(maps.first);
  }

  Future<List<Asset>> getAllAssets() async {
    final db = await _dbCore.database;
    List<Map<String, dynamic>> maps = await db.query(
      'assets',
      orderBy: 'symbol ASC',
    );
    return List.generate(maps.length, (i) => Asset.fromMap(maps[i]));
  }

  Future<Asset?> getAssetInTransaction(Transaction txn, int id) async {
    List<Map<String, dynamic>> maps = await txn.query(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Asset.fromMap(maps.first);
  }

  Future<int> updateAsset(Asset asset) async {
    final db = await _dbCore.database;
    return await db.update(
      'assets',
      asset.toMap(),
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  Future<int> deleteAsset(int id) async {
    final db = await _dbCore.database;
    return await db.transaction((txn) async {
      // First delete all transactions for this asset
      await txn.delete(
        'asset_transactions',
        where: 'asset_id = ?',
        whereArgs: [id],
      );
      // Then delete the asset
      return await txn.delete(
        'assets',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}
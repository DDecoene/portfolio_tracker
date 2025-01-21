import 'package:sqflite/sqflite.dart';
import '../models/asset.dart';
import '../models/asset_transaction.dart';
import 'database_core.dart';
import 'asset_operations.dart';

class InsufficientQuantityException implements Exception {
  final String message;
  InsufficientQuantityException(this.message);
  
  @override
  String toString() => message;
}

class TransactionOperations {
  final DatabaseCore _dbCore = DatabaseCore();
  final AssetOperations _assetOps = AssetOperations();

  Future<int> insertTransaction(AssetTransaction transaction) async {
    final db = await _dbCore.database;
    int transactionId = -1;

    await db.transaction((txn) async {
      // Get current asset state within transaction
      final asset = await _assetOps.getAssetInTransaction(txn, transaction.assetId);
      if (asset == null) {
        throw Exception('Asset not found');
      }

      // Get the latest transaction date for this asset
      final latestTransaction = await _getLatestTransaction(txn, transaction.assetId);
      final isNewerThanExisting = latestTransaction == null || 
          transaction.date.isAfter(DateTime.parse(latestTransaction['date']));

      // Handle different transaction types
      switch (transaction.type) {
        case TransactionType.buy:
          await _handleBuyTransaction(txn, transaction, asset, isNewerThanExisting);
          break;
        case TransactionType.sell:
          await _handleSellTransaction(txn, transaction, asset, isNewerThanExisting);
          break;
        case TransactionType.priceUpdate:
          await _handlePriceUpdateTransaction(txn, transaction, asset, isNewerThanExisting);
          break;
      }

      // Insert the transaction record
      transactionId = await txn.insert('asset_transactions', transaction.toMap());
    });

    return transactionId;
  }

  Future<Map<String, dynamic>?> _getLatestTransaction(Transaction txn, int assetId) async {
    final result = await txn.query(
      'asset_transactions',
      where: 'asset_id = ?',
      whereArgs: [assetId],
      orderBy: 'date DESC',
      limit: 1
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> _handleBuyTransaction(
    Transaction txn,
    AssetTransaction transaction,
    Asset asset,
    bool isNewerThanExisting,
  ) async {
    final quantity = transaction.quantity!;
    final price = transaction.price;
    
    // Calculate new position
    final newTotalQuantity = asset.totalQuantity + quantity;
    final newTotalCost = (asset.averagePurchasePrice * asset.totalQuantity) + 
                        (price * quantity);
    final newAveragePrice = newTotalCost / newTotalQuantity;

    // Create update map
    final Map<String, dynamic> updateMap = {
      'total_quantity': newTotalQuantity,
      'average_purchase_price': newAveragePrice,
    };
    
    // Only update current price if this is the newest transaction
    if (isNewerThanExisting) {
      updateMap['current_price'] = price;
    }

    // Update asset
    await txn.update(
      'assets',
      updateMap,
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  Future<void> _handleSellTransaction(
    Transaction txn,
    AssetTransaction transaction,
    Asset asset,
    bool isNewerThanExisting,
  ) async {
    final quantity = transaction.quantity!;
    final price = transaction.price;

    // Check if enough quantity is available
    if (quantity > asset.totalQuantity) {
      throw InsufficientQuantityException(
        'Insufficient quantity available. Have: ${asset.totalQuantity}, Trying to sell: $quantity'
      );
    }

    // Calculate new position
    final newTotalQuantity = asset.totalQuantity - quantity;
    
    // Create update map
    final Map<String, dynamic> updateMap = {
      'total_quantity': newTotalQuantity,
    };
    
    // Only update current price if this is the newest transaction
    if (isNewerThanExisting) {
      updateMap['current_price'] = price;
    }

    // Update asset
    await txn.update(
      'assets',
      updateMap,
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  Future<void> _handlePriceUpdateTransaction(
    Transaction txn,
    AssetTransaction transaction,
    Asset asset,
    bool isNewerThanExisting,
  ) async {
    // Only update the current price if this is the newest transaction
    if (isNewerThanExisting) {
      await txn.update(
        'assets',
        {'current_price': transaction.price},
        where: 'id = ?',
        whereArgs: [asset.id],
      );
    }
  }

  Future<List<AssetTransaction>> getAssetTransactions(int assetId) async {
    final db = await _dbCore.database;
    List<Map<String, dynamic>> maps = await db.query(
      'asset_transactions',
      where: 'asset_id = ?',
      whereArgs: [assetId],
      orderBy: 'date DESC'
    );
    return List.generate(maps.length, (i) => AssetTransaction.fromMap(maps[i]));
  }

  Future<List<AssetTransaction>> getAllTransactions() async {
    final db = await _dbCore.database;
    List<Map<String, dynamic>> maps = await db.query(
      'asset_transactions',
      orderBy: 'date DESC'
    );
    return List.generate(maps.length, (i) => AssetTransaction.fromMap(maps[i]));
  }
}
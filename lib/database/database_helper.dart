import 'asset_operations.dart';
import 'transaction_operations.dart';
import '../models/asset.dart';
import '../models/asset_transaction.dart';

export 'transaction_operations.dart' show InsufficientQuantityException;

/// DatabaseHelper provides a unified interface to all database operations.
/// It delegates to specialized operation classes internally.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  final AssetOperations _assetOps = AssetOperations();
  final TransactionOperations _transactionOps = TransactionOperations();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // Asset operations
  Future<int> insertAsset(Asset asset) => _assetOps.insertAsset(asset);
  
  Future<Asset?> getAsset(int id) => _assetOps.getAsset(id);
  
  Future<List<Asset>> getAllAssets() => _assetOps.getAllAssets();
  
  Future<int> updateAsset(Asset asset) => _assetOps.updateAsset(asset);
  
  Future<int> deleteAsset(int id) => _assetOps.deleteAsset(id);

  // Transaction operations
  Future<int> insertTransaction(AssetTransaction transaction) => 
      _transactionOps.insertTransaction(transaction);
  
  Future<List<AssetTransaction>> getAssetTransactions(int assetId) => 
      _transactionOps.getAssetTransactions(assetId);
  
  Future<List<AssetTransaction>> getAllTransactions() => 
      _transactionOps.getAllTransactions();

}
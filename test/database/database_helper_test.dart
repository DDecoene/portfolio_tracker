import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_tracker/database/database_helper.dart';
import 'package:portfolio_tracker/models/asset.dart';
import 'package:portfolio_tracker/models/asset_transaction.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper dbHelper;
  
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper();
  });

  group('Asset Operations', () {
    test('inserts and retrieves asset', () async {
      final asset = Asset(
        symbol: 'BTC',
        name: 'Bitcoin',
        currentPrice: 50000.0,
      );

      final id = await dbHelper.insertAsset(asset);
      final retrieved = await dbHelper.getAsset(id);

      expect(retrieved?.symbol, asset.symbol);
      expect(retrieved?.name, asset.name);
      expect(retrieved?.currentPrice, asset.currentPrice);
    });
  });

  group('Transaction Operations', () {
    late int assetId;

    setUp(() async {
      final asset = Asset(
        symbol: 'ETH',
        name: 'Ethereum',
        currentPrice: 2000.0,
      );
      assetId = await dbHelper.insertAsset(asset);
    });

    test('handles buy transaction correctly', () async {
      final transaction = AssetTransaction(
        assetId: assetId,
        type: TransactionType.buy,
        quantity: 2.0,
        price: 2000.0,
        date: DateTime.now(),
      );

      await dbHelper.insertTransaction(transaction);
      final asset = await dbHelper.getAsset(assetId);

      expect(asset?.totalQuantity, 2.0);
      expect(asset?.averagePurchasePrice, 2000.0);
    });

    test('handles insufficient quantity for sell', () async {
      final sellTransaction = AssetTransaction(
        assetId: assetId,
        type: TransactionType.sell,
        quantity: 1.0,
        price: 2000.0,
        date: DateTime.now(),
      );

      expect(
        () => dbHelper.insertTransaction(sellTransaction),
        throwsA(isA<InsufficientQuantityException>()),
      );
    });
  });
}


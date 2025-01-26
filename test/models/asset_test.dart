import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_tracker/models/asset.dart';

void main() {
  group('Asset', () {
    late Asset asset;

    setUp(() {
      asset = Asset(
        id: 1,
        symbol: 'BTC',
        name: 'Bitcoin',
        currentPrice: 50000.0,
        totalQuantity: 2.5,
        averagePurchasePrice: 45000.0,
      );
    });

    test('calculates total value correctly', () {
      expect(asset.totalValue, 125000.0);
    });

    test('calculates profit/loss correctly', () {
      expect(asset.profitLoss, 12500.0);
    });

    test('calculates profit/loss percentage correctly', () {
      expect(asset.profitLossPercentage, 11.11111111111111);
    });

    test('handles zero average purchase price', () {
      final zeroAsset = Asset(
        symbol: 'ETH',
        name: 'Ethereum',
        currentPrice: 2000.0,
        averagePurchasePrice: 0.0,
      );
      expect(zeroAsset.profitLossPercentage, 0.0);
    });

    test('converts to and from map', () {
      final map = asset.toMap();
      final newAsset = Asset.fromMap(map);

      expect(newAsset.id, asset.id);
      expect(newAsset.symbol, asset.symbol);
      expect(newAsset.name, asset.name);
      expect(newAsset.currentPrice, asset.currentPrice);
      expect(newAsset.totalQuantity, asset.totalQuantity);
      expect(newAsset.averagePurchasePrice, asset.averagePurchasePrice);
    });
  });
}


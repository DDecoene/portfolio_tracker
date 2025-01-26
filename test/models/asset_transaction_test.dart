import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_tracker/models/asset_transaction.dart';

void main() {
  group('AssetTransaction', () {
    late AssetTransaction transaction;
    final testDate = DateTime.utc(2025, 1, 15, 14, 30);

    setUp(() {
      transaction = AssetTransaction(
        id: 1,
        assetId: 1,
        type: TransactionType.buy,
        quantity: 1.5,
        price: 45000.0,
        date: testDate,
      );
    });

    test('converts to and from map with UTC dates', () {
      final map = transaction.toMap();
      final newTransaction = AssetTransaction.fromMap(map);

      expect(map['date'], endsWith('Z'));
      expect(newTransaction.id, transaction.id);
      expect(newTransaction.assetId, transaction.assetId);
      expect(newTransaction.type, transaction.type);
      expect(newTransaction.quantity, transaction.quantity);
      expect(newTransaction.price, transaction.price);
      expect(newTransaction.date.isUtc, false);
      expect(newTransaction.date.toUtc(), testDate);
    });

    test('formats date correctly', () {
      expect(transaction.formattedDate, '2025-01-15');
      expect(transaction.formattedDateTime, '2025-01-15 14:30');
    });
  });
}


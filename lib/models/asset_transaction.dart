enum TransactionType {
  buy,
  sell,
  priceUpdate
}

class AssetTransaction {
  final int? id;
  final int assetId;
  final TransactionType type;
  final double? quantity;
  final double price;
  final DateTime date;

  AssetTransaction({
    this.id,
    required this.assetId,
    required this.type,
    this.quantity,
    required this.price,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    // Ensure consistent UTC ISO format with Z suffix
    final utcDate = date.toUtc();
    final formattedDate = utcDate.toIso8601String();
    // Force Z suffix if not present
    final dateWithZ = formattedDate.endsWith('Z') ? formattedDate : '${formattedDate}Z';
    
    return {
      'id': id,
      'asset_id': assetId,
      'type': type.toString().split('.').last,
      'quantity': quantity,
      'price': price,
      'date': dateWithZ,
    };
  }

  factory AssetTransaction.fromMap(Map<String, dynamic> map) {
    return AssetTransaction(
      id: map['id'],
      assetId: map['asset_id'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type']
      ),
      quantity: map['quantity'],
      price: map['price'],
      date: DateTime.parse(map['date']).toLocal(),
    );
  }

  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get formattedDateTime {
    return '$formattedDate ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
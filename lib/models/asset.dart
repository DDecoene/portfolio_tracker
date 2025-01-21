class Asset {
  final int? id;
  final String symbol;
  final String name;
  double currentPrice;
  double totalQuantity;
  double averagePurchasePrice;

  Asset({
    this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    this.totalQuantity = 0.0,
    this.averagePurchasePrice = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'current_price': currentPrice,
      'total_quantity': totalQuantity,
      'average_purchase_price': averagePurchasePrice,
    };
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'],
      symbol: map['symbol'],
      name: map['name'],
      currentPrice: map['current_price'],
      totalQuantity: map['total_quantity'],
      averagePurchasePrice: map['average_purchase_price'],
    );
  }

  double get totalValue => currentPrice * totalQuantity;
  
  double get profitLoss => (currentPrice - averagePurchasePrice) * totalQuantity;
  
  double get profitLossPercentage {
    if (averagePurchasePrice == 0) return 0;
    return ((currentPrice - averagePurchasePrice) / averagePurchasePrice) * 100;
  }
}
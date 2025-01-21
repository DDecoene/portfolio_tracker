import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../models/asset_transaction.dart';
import '../database/database_helper.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final Asset asset;

  const TransactionHistoryScreen({
    Key? key,
    required this.asset,
  }) : super(key: key);

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<AssetTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await _dbHelper.getAssetTransactions(widget.asset.id!);
    setState(() {
      _transactions = transactions;
    });
  }

  String _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return '↑'; // Up arrow for buy
      case TransactionType.sell:
        return '↓'; // Down arrow for sell
      case TransactionType.priceUpdate:
        return '⟳'; // Circular arrow for update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.asset.symbol} Transactions'),
      ),
      body: Column(
        children: [
          // Asset Summary Card
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    widget.asset.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Price',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '\$${widget.asset.currentPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Quantity',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            widget.asset.totalQuantity.toStringAsFixed(4),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Average Price',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '\$${widget.asset.averagePurchasePrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Value',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '\$${widget.asset.totalValue.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Transactions List
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                final isPositive = transaction.type == TransactionType.buy;
                final showQuantity = transaction.type != TransactionType.priceUpdate;
                
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.type == TransactionType.priceUpdate
                          ? Colors.blue
                          : isPositive
                              ? Colors.green
                              : Colors.red,
                      child: Text(
                        _getTransactionTypeIcon(transaction.type),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          transaction.type.toString().split('.').last.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (showQuantity) ...[
                          const Text(' • '),
                          Text(
                            '${transaction.quantity?.toStringAsFixed(4)} ${widget.asset.symbol}',
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      '\$${transaction.price.toStringAsFixed(2)} per ${widget.asset.symbol}\n'
                      '${transaction.formattedDateTime}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
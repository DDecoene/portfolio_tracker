import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../database/database_helper.dart';
import 'transaction_form.dart';
import 'transaction_history_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Asset> _assets = [];

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final assets = await _dbHelper.getAllAssets();
    setState(() {
      _assets = assets;
    });
  }

  double get _totalPortfolioValue {
    return _assets.fold(0, (sum, asset) => sum + asset.totalValue);
  }

  double get _totalProfitLoss {
    return _assets.fold(0, (sum, asset) => sum + asset.profitLoss);
  }

  void _showTransactionForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TransactionForm(
        onTransactionComplete: _loadAssets,
      ),
    );
  }

  void _showTransactionHistory(Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionHistoryScreen(asset: asset),
      ),
    ).then((_) => _loadAssets()); // Refresh assets when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Tracker'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Total Portfolio Value',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$${_totalPortfolioValue.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Profit/Loss',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$${_totalProfitLoss.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _totalProfitLoss >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _assets.length,
              itemBuilder: (context, index) {
                final asset = _assets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: InkWell(
                    onTap: () => _showTransactionHistory(asset),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${asset.symbol} - ${asset.name}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      'Qty: ${asset.totalQuantity.toStringAsFixed(4)}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${asset.currentPrice.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${asset.profitLossPercentage.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: asset.profitLoss >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Avg: \$${asset.averagePurchasePrice.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Value: \$${asset.totalValue.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTransactionForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
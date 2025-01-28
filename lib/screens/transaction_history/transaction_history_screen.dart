import 'package:flutter/material.dart';
import '../../models/asset.dart';
import '../../models/asset_transaction.dart';
import '../../database/database_helper.dart';
import 'components/asset_summary_card.dart';
import 'components/transaction_list.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final Asset asset;

  const TransactionHistoryScreen({
    super.key,
    required this.asset,
  });

  @override
  TransactionHistoryScreenState createState() => TransactionHistoryScreenState();
}

class TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('${widget.asset.symbol} Transactions'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          AssetSummaryCard(asset: widget.asset),
          Expanded(
            child: TransactionList(
              transactions: _transactions,
              asset: widget.asset,
            ),
          ),
        ],
      ),
    );
  }
}

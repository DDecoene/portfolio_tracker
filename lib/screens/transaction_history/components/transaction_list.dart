import 'package:flutter/material.dart';
import '../../../models/asset.dart';
import '../../../models/asset_transaction.dart';
import 'transaction_list_item.dart';

class TransactionList extends StatelessWidget {
  final List<AssetTransaction> transactions;
  final Asset asset;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${transactions.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: transactions.length,
            itemBuilder: (context, index) => TransactionListItem(
              transaction: transactions[index],
              asset: asset,
            ),
          ),
        ),
      ],
    );
  }
}

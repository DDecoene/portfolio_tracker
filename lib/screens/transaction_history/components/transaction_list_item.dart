import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/asset.dart';
import '../../../models/asset_transaction.dart';
import '../../../providers/settings_provider.dart';

class TransactionListItem extends StatelessWidget {
  final AssetTransaction transaction;
  final Asset asset;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.asset,
  });

  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return Icons.arrow_upward;
      case TransactionType.sell:
        return Icons.arrow_downward;
      case TransactionType.priceUpdate:
        return Icons.sync;
    }
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.buy:
        return Colors.green;
      case TransactionType.sell:
        return Colors.red;
      case TransactionType.priceUpdate:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showQuantity = transaction.type != TransactionType.priceUpdate;
    final transactionColor = _getTransactionColor(transaction.type);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: transactionColor.withValues(alpha:.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTransactionTypeIcon(transaction.type),
                color: transactionColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        transaction.type.toString().split('.').last.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (showQuantity) ...[
                        const Text(' • '),
                        Text(
                          '${transaction.quantity?.toStringAsFixed(4)} ${asset.symbol}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) => Text(
                      '${settings.currencySymbol}${transaction.price.toStringAsFixed(2)} per ${asset.symbol}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.formattedDateTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

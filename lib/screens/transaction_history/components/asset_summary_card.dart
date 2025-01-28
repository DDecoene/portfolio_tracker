import 'package:flutter/material.dart';
import 'package:portfolio_tracker/shared/styles.dart';
import 'package:provider/provider.dart';
import '../../../models/asset.dart';
import '../../../providers/settings_provider.dart';

class AssetSummaryCard extends StatelessWidget {
  final Asset asset;

  const AssetSummaryCard({
    super.key,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha:.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAssetHeader(context),
            const SizedBox(height: 24),
            _buildStatisticsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: colorScheme.onPrimaryContainer.withValues(alpha:.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                asset.symbol,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              asset.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: asset.profitLoss >= 0
                ? Colors.green.withValues(alpha:.2)
                : Colors.red.withValues(alpha:.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${asset.profitLoss >= 0 ? '+' : ''}${asset.profitLossPercentage.toStringAsFixed(2)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: asset.profitLoss >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => Column(
        children: [
          // Current Price Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Current Price', style: AppStyles.captionStyle),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  settings.currencySymbol +
                      asset.currentPrice.toStringAsFixed(2),
                  style: AppStyles.subtitleStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Total Quantity Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Total Quantity', style: AppStyles.captionStyle),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  asset.totalQuantity.toStringAsFixed(4),
                  style: AppStyles.subtitleStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Average Price Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Average Price', style: AppStyles.captionStyle),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  settings.currencySymbol +
                      asset.averagePurchasePrice.toStringAsFixed(2),
                  style: AppStyles.subtitleStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Total Value Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Total Value', style: AppStyles.captionStyle),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  settings.currencySymbol + asset.totalValue.toStringAsFixed(2),
                  style: AppStyles.subtitleStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

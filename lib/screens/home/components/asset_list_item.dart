import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/asset.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/styles.dart';

class AssetCard extends BaseListItem {
  const AssetCard({
    super.key,
    required super.colorScheme,
    required super.onTap,
    required super.child,
  });
}

class AssetListItem extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;

  const AssetListItem({
    super.key,
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AssetCard(
      colorScheme: colorScheme,
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              AppStyles.buildSymbolBadge(
                symbol: asset.symbol,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: AppStyles.subtitleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${asset.totalQuantity.toStringAsFixed(4)}',
                      style: AppStyles.captionStyle.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) => Text(
                      '${settings.currencySymbol}${asset.currentPrice.toStringAsFixed(2)}',
                      style: AppStyles.subtitleStyle,
                    ),
                  ),
                  AppStyles.buildProfitLossIndicator(
                    isProfit: asset.profitLoss >= 0,
                    value: '${asset.profitLossPercentage.toStringAsFixed(2)}%',
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppStyles.statisticsContainerDecoration(colorScheme),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) => AppStyles.buildStatisticItem(
                    label: 'Avg. Price',
                    value: '${settings.currencySymbol}${asset.averagePurchasePrice.toStringAsFixed(2)}',
                    colorScheme: colorScheme,
                  ),
                ),
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) => AppStyles.buildStatisticItem(
                    label: 'Total Value',
                    value: '${settings.currencySymbol}${asset.totalValue.toStringAsFixed(2)}',
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
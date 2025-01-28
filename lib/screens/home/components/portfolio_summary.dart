import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/styles.dart';

class PortfolioCard extends BaseSummaryCard {
  const PortfolioCard({
    super.key,
    required super.colorScheme,
    required super.child,
  });
}

class PortfolioSummary extends StatelessWidget {
  final double totalValue;
  final double totalProfitLoss;

  const PortfolioSummary({
    super.key,
    required this.totalValue,
    required this.totalProfitLoss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return PortfolioCard(
      colorScheme: colorScheme,
      child: Column(
        children: [
          Text(
            'Total Portfolio Value',
            style: AppStyles.subtitleStyle.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => Text(
              '${settings.currencySymbol}${totalValue.toStringAsFixed(2)}',
              style: AppStyles.headlineStyle.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => AppStyles.buildProfitLossIndicator(
              isProfit: totalProfitLoss >= 0,
              value: '${settings.currencySymbol}${totalProfitLoss.toStringAsFixed(2)}',
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }
}
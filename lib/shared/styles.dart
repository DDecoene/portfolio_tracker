import 'package:flutter/material.dart';

/// Shared styles and components for consistent UI across the app
class AppStyles {
  /// Gradient container decoration used in summary cards
  static BoxDecoration gradientCardDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.primaryContainer,
          colorScheme.primary.withValues(alpha:.8),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withValues(alpha:.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Card decoration used in list items
  static BoxDecoration listItemDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: colorScheme.onSurface.withValues(alpha:.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Container decoration for statistics sections
  static BoxDecoration statisticsContainerDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      color: colorScheme.surfaceContainerHighest.withValues(alpha:.5),
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Profit/Loss indicator container decoration
  static BoxDecoration profitLossDecoration(bool isProfit, ColorScheme colorScheme) {
    final color = isProfit ? Colors.green : Colors.red;
    return BoxDecoration(
      color: color.withValues(alpha:.1),
      borderRadius: BorderRadius.circular(8),
    );
  }

  /// Symbol badge decoration
  static BoxDecoration symbolBadgeDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Standard card margin
  static const EdgeInsets cardMargin = EdgeInsets.only(bottom: 12);

  /// Standard padding for cards and containers
  static const EdgeInsets standardPadding = EdgeInsets.all(16);

  /// Text styles for consistent typography
  static TextStyle get headlineStyle => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get titleStyle => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get subtitleStyle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get bodyStyle => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get captionStyle => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  /// Shared widgets
  static Widget buildProfitLossIndicator({
    required bool isProfit,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: profitLossDecoration(isProfit, colorScheme),
      child: Text(
        '${isProfit ? '+' : ''}$value',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isProfit ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  static Widget buildSymbolBadge({
    required String symbol,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: symbolBadgeDecoration(colorScheme),
      child: Text(
        symbol,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget buildStatisticItem({
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: captionStyle.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: subtitleStyle.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Base class for summary cards with shared functionality
abstract class BaseSummaryCard extends StatelessWidget {
  final ColorScheme colorScheme;
  final EdgeInsets margin;
  final Widget child;

  const BaseSummaryCard({
    super.key,
    required this.colorScheme,
    this.margin = const EdgeInsets.all(16),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: AppStyles.gradientCardDecoration(colorScheme),
      child: Padding(
        padding: AppStyles.standardPadding,
        child: child,
      ),
    );
  }
}

/// Base class for list items with shared functionality
abstract class BaseListItem extends StatelessWidget {
  final ColorScheme colorScheme;
  final VoidCallback? onTap;
  final Widget child;

  const BaseListItem({
    super.key,
    required this.colorScheme,
    this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppStyles.cardMargin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: AppStyles.standardPadding,
          child: child,
        ),
      ),
    );
  }
}
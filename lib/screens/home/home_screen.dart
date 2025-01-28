import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:portfolio_tracker/screens/transaction_history/transaction_history_screen.dart';
import '../../models/asset.dart';
import '../../database/database_helper.dart';
import '../transaction_form.dart';
import '../settings_screen.dart';
import 'components/portfolio_summary.dart';
import 'components/asset_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Asset> _assets = [];
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadAssets();
    _loadVersion();
  }

  Future<void> _loadAssets() async {
    final assets = await _dbHelper.getAllAssets();
    setState(() {
      _assets = assets;
    });
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: TransactionForm(
          onTransactionComplete: _loadAssets,
        ),
      ),
    );
  }

  void _showTransactionHistory(Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionHistoryScreen(asset: asset),
      ),
    ).then((_) => _loadAssets());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Portfolio Tracker v$_version'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          PortfolioSummary(
            totalValue: _totalPortfolioValue,
            totalProfitLoss: _totalProfitLoss,
          ),
          AssetList(
            assets: _assets,
            onAssetTap: _showTransactionHistory,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTransactionForm,
        icon: const Icon(Icons.add),
        label: const Text('New Transaction'),
      ),
    );
  }
}

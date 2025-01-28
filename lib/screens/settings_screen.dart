import 'package:flutter/material.dart';
import 'package:portfolio_tracker/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../settings/settings_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  String _currentCurrencySymbol = '\$';
  final List<String> _availableCurrencySymbols = [
    '\$', // USD
    '€', // EUR
    '£', // GBP
    '¥', // JPY/CNY
    '₹', // INR
    'Fr', // CHF
    'A\$', // AUD
    'C\$', // CAD
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final symbol = await SettingsHelper.getCurrencySymbol();
    setState(() {
      _currentCurrencySymbol = symbol;
    });
  }

  Future<void> _updateCurrencySymbol(String? newSymbol) async {
    if (newSymbol == null) return;

    await Provider.of<SettingsProvider>(context, listen: false)
        .updateCurrencySymbol(newSymbol);
    
    await SettingsHelper.setCurrencySymbol(newSymbol);
    setState(() {
      _currentCurrencySymbol = newSymbol;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Currency symbol updated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Currency Symbol',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _currentCurrencySymbol,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: _availableCurrencySymbols.map((String symbol) {
                      return DropdownMenuItem<String>(
                        value: symbol,
                        child: Text(symbol),
                      );
                    }).toList(),
                    onChanged: _updateCurrencySymbol,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
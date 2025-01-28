import 'package:flutter/foundation.dart';
import '../settings/settings_helper.dart';

class SettingsProvider extends ChangeNotifier {
  String _currencySymbol = SettingsHelper.defaultCurrencySymbol;

  String get currencySymbol => _currencySymbol;

  Future<void> loadSettings() async {
    _currencySymbol = await SettingsHelper.getCurrencySymbol();
    notifyListeners();
  }

  Future<void> updateCurrencySymbol(String symbol) async {
    await SettingsHelper.setCurrencySymbol(symbol);
    _currencySymbol = symbol;
    notifyListeners();
  }
}
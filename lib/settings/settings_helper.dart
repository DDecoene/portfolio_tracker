import 'package:shared_preferences/shared_preferences.dart';

class SettingsHelper {
  static const String _currencySymbolKey = 'currency_symbol';
  static const String defaultCurrencySymbol = '\$';

  static Future<String> getCurrencySymbol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencySymbolKey) ?? defaultCurrencySymbol;
  }

  static Future<void> setCurrencySymbol(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencySymbolKey, symbol);
  }
}
import 'package:flutter/material.dart';
import 'translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal() {
    _loadFromPrefs();
  }

  SharedPreferences? _prefs;

  String _currency = 'USD';
  String _currencySymbol = '\$';
  double _exchangeRate = 1.0;
  String _currentLanguage = 'English';

  String get currency => _currency;
  String get currencySymbol => _currencySymbol;
  String get currentLanguage => _currentLanguage;

  final Map<String, Map<String, dynamic>> _currencyData = {
    'USD': {'symbol': '\u0024', 'rate': 1.0},
    'EUR': {'symbol': '\u20AC', 'rate': 0.92},
    'GBP': {'symbol': '\u00A3', 'rate': 0.79},
    'JPY': {'symbol': '\u00A5', 'rate': 151.0},
    'LKR': {'symbol': 'Rs', 'rate': 300.0},
  };

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _currentLanguage = _prefs?.getString('language') ?? 'English';
    _currency = _prefs?.getString('currency') ?? 'USD';
    if (_currencyData.containsKey(_currency)) {
      _currencySymbol = _currencyData[_currency]!['symbol'];
      _exchangeRate = _currencyData[_currency]!['rate'];
    }
    notifyListeners();
  }

  void setCurrency(String code) {
    if (_currencyData.containsKey(code)) {
      _currency = code;
      _currencySymbol = _currencyData[code]!['symbol'];
      _exchangeRate = _currencyData[code]!['rate'];
      _prefs?.setString('currency', code);
      notifyListeners();
    }
  }

  void setLanguage(String language) {
    _currentLanguage = language;
    _prefs?.setString('language', language);
    notifyListeners();
  }

  String translate(String key) {
    if (translations.containsKey(_currentLanguage) && 
        translations[_currentLanguage]!.containsKey(key)) {
      return translations[_currentLanguage]![key]!;
    }
    // Fallback to English if translation is missing
    if (translations['English']!.containsKey(key)) {
      return translations['English']![key]!;
    }
    // Return key as last resort
    return key;
  }

  String formatPrice(double price) {
    double convertedPrice = price * _exchangeRate;
    if (_currency == 'JPY' || _currency == 'LKR') {
      return '$_currencySymbol ${convertedPrice.toStringAsFixed(0)}';
    }
    return '$_currencySymbol ${convertedPrice.toStringAsFixed(2)}';
  }

  void reset() {
    _currency = 'USD';
    _currencySymbol = '\$';
    _exchangeRate = 1.0;
    _currentLanguage = 'English';
    _prefs?.clear();
    notifyListeners();
  }
}

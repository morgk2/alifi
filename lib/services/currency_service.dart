import 'package:flutter/material.dart';

enum Currency { USD, DZD }

class CurrencyService extends ChangeNotifier {
  static const double _usdToDzdRate = 235.0;
  static const double _dzdToUsdRate = 1.0 / 235.0;
  
  Currency _currentCurrency = Currency.DZD;
  
  Currency get currentCurrency => _currentCurrency;
  
  // Get currency symbol
  String get symbol {
    switch (_currentCurrency) {
      case Currency.USD:
        return '\$';
      case Currency.DZD:
        return 'DZD'; // Return identifier for DZD to use custom widget
    }
  }
  
  // Get currency name
  String get currencyName {
    switch (_currentCurrency) {
      case Currency.USD:
        return 'USD';
      case Currency.DZD:
        return 'DZD';
    }
  }
  
  // Convert USD to current currency
  double convertFromUsd(double usdAmount) {
    switch (_currentCurrency) {
      case Currency.USD:
        return usdAmount;
      case Currency.DZD:
        return usdAmount * _usdToDzdRate;
    }
  }
  
  // Convert current currency to USD
  double convertToUsd(double amount) {
    switch (_currentCurrency) {
      case Currency.USD:
        return amount;
      case Currency.DZD:
        return amount * _dzdToUsdRate;
    }
  }
  
  // Format price with currency symbol
  String formatPrice(double price) {
    final convertedPrice = convertFromUsd(price);
    if (_currentCurrency == Currency.DZD) {
      return '${convertedPrice.toStringAsFixed(2)}'; // Return just the number for DZD
    }
    return '$symbol${convertedPrice.toStringAsFixed(2)}';
  }
  
  // Format price without symbol (for input fields)
  String formatPriceWithoutSymbol(double price) {
    final convertedPrice = convertFromUsd(price);
    return convertedPrice.toStringAsFixed(2);
  }
  
  // Parse price from string (for input fields)
  double parsePrice(String priceString) {
    try {
      final amount = double.parse(priceString);
      return convertToUsd(amount);
    } catch (e) {
      return 0.0;
    }
  }
  
  // Change currency
  void changeCurrency(Currency currency) {
    if (_currentCurrency != currency) {
      _currentCurrency = currency;
      notifyListeners();
    }
  }
  
  // Toggle between currencies
  void toggleCurrency() {
    _currentCurrency = _currentCurrency == Currency.USD ? Currency.DZD : Currency.USD;
    notifyListeners();
  }
  
  // Get conversion rate
  double get conversionRate {
    switch (_currentCurrency) {
      case Currency.USD:
        return 1.0;
      case Currency.DZD:
        return _usdToDzdRate;
    }
  }
} 
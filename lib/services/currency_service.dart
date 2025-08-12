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
  
  // NEW: Format price based on product currency and user preference
  String formatProductPrice(double price, String productCurrency) {
    final displayPrice = _getDisplayPrice(price, productCurrency);
    
    if (_currentCurrency == Currency.DZD) {
      return '${displayPrice.toStringAsFixed(2)}'; // Return just the number for DZD
    }
    return '$symbol${displayPrice.toStringAsFixed(2)}';
  }
  
  // NEW: Get the price to display based on product currency and user preference
  double _getDisplayPrice(double price, String productCurrency) {
    // If product currency matches user preference, no conversion needed
    if ((productCurrency == 'DZD' && _currentCurrency == Currency.DZD) ||
        (productCurrency == 'USD' && _currentCurrency == Currency.USD)) {
      return price;
    }
    
    // Convert if needed
    if (productCurrency == 'USD' && _currentCurrency == Currency.DZD) {
      return price * _usdToDzdRate; // USD → DZD
    } else if (productCurrency == 'DZD' && _currentCurrency == Currency.USD) {
      return price * _dzdToUsdRate; // DZD → USD
    }
    
    return price; // Fallback
  }
  
  // NEW: Get payment amount (convert to DZD if needed for Chargily)
  double getPaymentAmount(double price, String productCurrency) {
    // Chargily only accepts DZD, so convert USD to DZD if needed
    if (productCurrency == 'USD') {
      return price * _usdToDzdRate; // Convert USD to DZD
    }
    return price; // Already in DZD
  }
  
  // NEW: Get payment currency (always use DZD for Chargily)
  String getPaymentCurrency(String productCurrency) {
    // Chargily only accepts DZD, so always return DZD
    return 'DZD';
  }
  
  // Legacy methods for backward compatibility
  double convertFromUsd(double usdAmount) {
    switch (_currentCurrency) {
      case Currency.USD:
        return usdAmount;
      case Currency.DZD:
        return usdAmount * _usdToDzdRate;
    }
  }
  
  double convertToUsd(double amount) {
    switch (_currentCurrency) {
      case Currency.USD:
        return amount;
      case Currency.DZD:
        return amount * _dzdToUsdRate;
    }
  }
  
  String formatPrice(double price) {
    final convertedPrice = convertFromUsd(price);
    if (_currentCurrency == Currency.DZD) {
      return '${convertedPrice.toStringAsFixed(2)}';
    }
    return '$symbol${convertedPrice.toStringAsFixed(2)}';
  }
  
  String formatPriceWithoutSymbol(double price) {
    final convertedPrice = convertFromUsd(price);
    return convertedPrice.toStringAsFixed(2);
  }
  
  double parsePrice(String priceString) {
    try {
      final amount = double.parse(priceString);
      return convertToUsd(amount);
    } catch (e) {
      return 0.0;
    }
  }
  
  void changeCurrency(Currency currency) {
    if (_currentCurrency != currency) {
      _currentCurrency = currency;
      notifyListeners();
    }
  }
  
  void toggleCurrency() {
    _currentCurrency = _currentCurrency == Currency.USD ? Currency.DZD : Currency.USD;
    notifyListeners();
  }
  
  double get conversionRate {
    switch (_currentCurrency) {
      case Currency.USD:
        return 1.0;
      case Currency.DZD:
        return _usdToDzdRate;
    }
  }
} 
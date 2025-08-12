import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService extends ChangeNotifier {
  static const String _languageKey = 'user_language';
  static const String _tabBarBlurKey = 'tab_bar_blur_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _currencyKey = 'user_currency';
  
  // Default values
  Locale _language = const Locale('en');
  bool _tabBarBlurEnabled = true;
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;
  String _currency = 'USD';
  
  // Getters
  Locale get language => _language;
  bool get tabBarBlurEnabled => _tabBarBlurEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  String get currency => _currency;
  
  // Initialize and load settings from storage
  Future<void> initialize() async {
    await _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load language preference
      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        _language = Locale(languageCode);
      }
      
      // Load display settings
      _tabBarBlurEnabled = prefs.getBool(_tabBarBlurKey) ?? true;
      _darkModeEnabled = prefs.getBool(_darkModeKey) ?? false;
      
      // Load notification settings
      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
      
      // Load currency preference
      _currency = prefs.getString(_currencyKey) ?? 'USD';
      
      notifyListeners();
      
      if (kDebugMode) {
        print('User preferences loaded:');
        print('  Language: ${_language.languageCode}');
        print('  Tab bar blur: $_tabBarBlurEnabled');
        print('  Dark mode: $_darkModeEnabled');
        print('  Notifications: $_notificationsEnabled');
        print('  Currency: $_currency');
      }
    } catch (e) {
      print('Error loading user preferences: $e');
    }
  }
  
  // Language preference methods
  Future<void> setLanguage(Locale locale) async {
    if (_language != locale) {
      _language = locale;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, locale.languageCode);
        
        if (kDebugMode) {
          print('Language preference saved: ${locale.languageCode}');
        }
      } catch (e) {
        print('Error saving language preference: $e');
      }
    }
  }
  
  // Display settings methods
  Future<void> setTabBarBlurEnabled(bool enabled) async {
    if (_tabBarBlurEnabled != enabled) {
      _tabBarBlurEnabled = enabled;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_tabBarBlurKey, enabled);
        
        if (kDebugMode) {
          print('Tab bar blur setting saved: $enabled');
        }
      } catch (e) {
        print('Error saving tab bar blur setting: $e');
      }
    }
  }
  
  Future<void> setDarkModeEnabled(bool enabled) async {
    if (_darkModeEnabled != enabled) {
      _darkModeEnabled = enabled;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_darkModeKey, enabled);
        
        if (kDebugMode) {
          print('Dark mode setting saved: $enabled');
        }
      } catch (e) {
        print('Error saving dark mode setting: $e');
      }
    }
  }
  
  // Notification settings methods
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled != enabled) {
      _notificationsEnabled = enabled;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_notificationsEnabledKey, enabled);
        
        if (kDebugMode) {
          print('Notifications setting saved: $enabled');
        }
      } catch (e) {
        print('Error saving notifications setting: $e');
      }
    }
  }
  
  // Currency preference methods
  Future<void> setCurrency(String currency) async {
    if (_currency != currency) {
      _currency = currency;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_currencyKey, currency);
        
        if (kDebugMode) {
          print('Currency preference saved: $currency');
        }
      } catch (e) {
        print('Error saving currency preference: $e');
      }
    }
  }
  
  // Convenience methods
  Future<void> toggleTabBarBlur() async {
    await setTabBarBlurEnabled(!_tabBarBlurEnabled);
  }
  
  Future<void> toggleDarkMode() async {
    await setDarkModeEnabled(!_darkModeEnabled);
  }
  
  Future<void> toggleNotifications() async {
    await setNotificationsEnabled(!_notificationsEnabled);
  }
  
  // Reset all preferences to defaults
  Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _language = const Locale('en');
      _tabBarBlurEnabled = true;
      _darkModeEnabled = false;
      _notificationsEnabled = true;
      _currency = 'USD';
      
      notifyListeners();
      
      if (kDebugMode) {
        print('User preferences reset to defaults');
      }
    } catch (e) {
      print('Error resetting user preferences: $e');
    }
  }
  
  // Export preferences as Map (useful for debugging or backup)
  Map<String, dynamic> exportPreferences() {
    return {
      'language': _language.languageCode,
      'tabBarBlurEnabled': _tabBarBlurEnabled,
      'darkModeEnabled': _darkModeEnabled,
      'notificationsEnabled': _notificationsEnabled,
      'currency': _currency,
    };
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/liquid_glass_nav_bar.dart';

class UserPreferencesService extends ChangeNotifier {
  static const String _languageKey = 'user_language';
  static const String _tabBarBlurKey = 'tab_bar_blur_enabled';
  static const String _tabBarLiquidGlassKey = 'tab_bar_liquid_glass_enabled';
  static const String _tabBarSolidColorKey = 'tab_bar_solid_color_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _currencyKey = 'user_currency';
  
  // Default values
  Locale _language = const Locale('en');
  bool _tabBarBlurEnabled = true;
  bool _tabBarLiquidGlassEnabled = false;
  bool _tabBarSolidColorEnabled = false;
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;
  String _currency = 'USD';
  
  // Getters
  Locale get language => _language;
  bool get tabBarBlurEnabled => _tabBarBlurEnabled;
  bool get tabBarLiquidGlassEnabled => _tabBarLiquidGlassEnabled;
  bool get tabBarSolidColorEnabled => _tabBarSolidColorEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  String get currency => _currency;
  
  // Check if liquid glass is supported on this platform
  bool get isLiquidGlassSupported => LiquidGlassNavBar.isSupported;
  
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
      _tabBarLiquidGlassEnabled = prefs.getBool(_tabBarLiquidGlassKey) ?? false;
      _tabBarSolidColorEnabled = prefs.getBool(_tabBarSolidColorKey) ?? false;
      _darkModeEnabled = prefs.getBool(_darkModeKey) ?? false;
      
      // Ensure only one tab bar effect is enabled at a time
      _ensureTabBarEffectConsistency();
      
      // Load notification settings
      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
      
      // Load currency preference
      _currency = prefs.getString(_currencyKey) ?? 'USD';
      
      notifyListeners();
      
      if (kDebugMode) {
        print('User preferences loaded:');
        print('  Language: ${_language.languageCode}');
        print('  Tab bar blur: $_tabBarBlurEnabled');
        print('  Tab bar liquid glass: $_tabBarLiquidGlassEnabled');
        print('  Tab bar solid color: $_tabBarSolidColorEnabled');
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
  
  // Display settings methods with mutually exclusive logic
  Future<void> setTabBarBlurEnabled(bool enabled) async {
    if (enabled && (_tabBarBlurEnabled != enabled)) {
      // When enabling blur, disable other effects
      _tabBarBlurEnabled = true;
      _tabBarLiquidGlassEnabled = false;
      _tabBarSolidColorEnabled = false;
    } else if (!enabled && _tabBarBlurEnabled) {
      // When disabling blur, enable solid color as default
      _tabBarBlurEnabled = false;
      _tabBarLiquidGlassEnabled = false;
      _tabBarSolidColorEnabled = true;
    } else {
      return; // No change needed
    }
    
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tabBarBlurKey, _tabBarBlurEnabled);
      await prefs.setBool(_tabBarLiquidGlassKey, _tabBarLiquidGlassEnabled);
      await prefs.setBool(_tabBarSolidColorKey, _tabBarSolidColorEnabled);
      
      if (kDebugMode) {
        print('Tab bar effects updated: blur=$_tabBarBlurEnabled, liquid=$_tabBarLiquidGlassEnabled, solid=$_tabBarSolidColorEnabled');
      }
    } catch (e) {
      print('Error saving tab bar effects: $e');
    }
  }
  
  Future<void> setTabBarLiquidGlassEnabled(bool enabled) async {
    if (enabled && (_tabBarLiquidGlassEnabled != enabled)) {
      // When enabling liquid glass, disable other effects
      _tabBarBlurEnabled = false;
      _tabBarLiquidGlassEnabled = true;
      _tabBarSolidColorEnabled = false;
    } else if (!enabled && _tabBarLiquidGlassEnabled) {
      // When disabling liquid glass, enable solid color as default
      _tabBarBlurEnabled = false;
      _tabBarLiquidGlassEnabled = false;
      _tabBarSolidColorEnabled = true;
    } else {
      return; // No change needed
    }
    
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tabBarBlurKey, _tabBarBlurEnabled);
      await prefs.setBool(_tabBarLiquidGlassKey, _tabBarLiquidGlassEnabled);
      await prefs.setBool(_tabBarSolidColorKey, _tabBarSolidColorEnabled);
      
      if (kDebugMode) {
        print('Tab bar effects updated: blur=$_tabBarBlurEnabled, liquid=$_tabBarLiquidGlassEnabled, solid=$_tabBarSolidColorEnabled');
      }
    } catch (e) {
      print('Error saving tab bar effects: $e');
    }
  }
  
  Future<void> setTabBarSolidColorEnabled(bool enabled) async {
    if (enabled && (_tabBarSolidColorEnabled != enabled)) {
      // When enabling solid color, disable other effects
      _tabBarBlurEnabled = false;
      _tabBarLiquidGlassEnabled = false;
      _tabBarSolidColorEnabled = true;
    } else if (!enabled && _tabBarSolidColorEnabled) {
      // When disabling solid color, enable blur as default
      _tabBarBlurEnabled = true;
      _tabBarLiquidGlassEnabled = false;
      _tabBarSolidColorEnabled = false;
    } else {
      return; // No change needed
    }
    
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tabBarBlurKey, _tabBarBlurEnabled);
      await prefs.setBool(_tabBarLiquidGlassKey, _tabBarLiquidGlassEnabled);
      await prefs.setBool(_tabBarSolidColorKey, _tabBarSolidColorEnabled);
      
      if (kDebugMode) {
        print('Tab bar effects updated: blur=$_tabBarBlurEnabled, liquid=$_tabBarLiquidGlassEnabled, solid=$_tabBarSolidColorEnabled');
      }
    } catch (e) {
      print('Error saving tab bar effects: $e');
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
  
  Future<void> toggleTabBarLiquidGlass() async {
    await setTabBarLiquidGlassEnabled(!_tabBarLiquidGlassEnabled);
  }
  
  Future<void> toggleTabBarSolidColor() async {
    await setTabBarSolidColorEnabled(!_tabBarSolidColorEnabled);
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
      _tabBarLiquidGlassEnabled = false;
      _tabBarSolidColorEnabled = false;
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
  
  // Private method to ensure only one tab bar effect is enabled
  void _ensureTabBarEffectConsistency() {
    final enabledEffects = [
      _tabBarBlurEnabled,
      _tabBarLiquidGlassEnabled,
      _tabBarSolidColorEnabled,
    ];
    
    final enabledCount = enabledEffects.where((effect) => effect).length;
    
    if (enabledCount == 0) {
      // If no effect is enabled, enable blur as default
      _tabBarBlurEnabled = true;
      _tabBarLiquidGlassEnabled = false;
      _tabBarSolidColorEnabled = false;
    } else if (enabledCount > 1) {
      // If multiple effects are enabled, prioritize in order: liquid glass > blur > solid
      if (_tabBarLiquidGlassEnabled) {
        _tabBarBlurEnabled = false;
        _tabBarSolidColorEnabled = false;
      } else if (_tabBarBlurEnabled) {
        _tabBarLiquidGlassEnabled = false;
        _tabBarSolidColorEnabled = false;
      } else {
        _tabBarBlurEnabled = false;
        _tabBarLiquidGlassEnabled = false;
        _tabBarSolidColorEnabled = true;
      }
    }
    
    if (kDebugMode) {
      print('Tab bar effect consistency ensured: blur=$_tabBarBlurEnabled, liquid=$_tabBarLiquidGlassEnabled, solid=$_tabBarSolidColorEnabled');
    }
  }

  // Export preferences as Map (useful for debugging or backup)
  Map<String, dynamic> exportPreferences() {
    return {
      'language': _language.languageCode,
      'tabBarBlurEnabled': _tabBarBlurEnabled,
      'tabBarLiquidGlassEnabled': _tabBarLiquidGlassEnabled,
      'tabBarSolidColorEnabled': _tabBarSolidColorEnabled,
      'darkModeEnabled': _darkModeEnabled,
      'notificationsEnabled': _notificationsEnabled,
      'currency': _currency,
    };
  }
}

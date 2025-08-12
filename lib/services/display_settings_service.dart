import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'user_preferences_service.dart';

class DisplaySettingsService extends ChangeNotifier {
  UserPreferencesService? _preferencesService;
  
  bool get tabBarBlurEnabled {
    return _preferencesService?.tabBarBlurEnabled ?? true;
  }

  // Initialize and connect to UserPreferencesService
  Future<void> initialize() async {
    // This will be called after the UserPreferencesService is available
    // The actual connection will be done through the setPreferencesService method
  }
  
  void setPreferencesService(UserPreferencesService preferencesService) {
    _preferencesService = preferencesService;
    // Listen to changes in the preferences service
    _preferencesService!.addListener(_onPreferencesChanged);
    notifyListeners();
  }
  
  void _onPreferencesChanged() {
    notifyListeners();
  }

  Future<void> setTabBarBlurEnabled(bool enabled) async {
    await _preferencesService?.setTabBarBlurEnabled(enabled);
  }

  Future<void> toggleTabBarBlur() async {
    await _preferencesService?.toggleTabBarBlur();
  }
  
  @override
  void dispose() {
    _preferencesService?.removeListener(_onPreferencesChanged);
    super.dispose();
  }
}


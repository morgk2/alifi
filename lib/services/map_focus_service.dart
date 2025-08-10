import 'package:flutter/foundation.dart';
import '../models/user.dart';

class MapFocusService extends ChangeNotifier {
  User? _focusUser;
  
  User? get focusUser => _focusUser;
  
  void setFocusUser(User user) {
    _focusUser = user;
    notifyListeners();
  }
  
  void clearFocusUser() {
    _focusUser = null;
    notifyListeners();
  }
}

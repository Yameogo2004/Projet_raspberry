import 'package:flutter/material.dart';
import '../data/models/user.dart';           // ← NOUVEAU CHEMIN
import '../data/services/auth_service.dart'; // ← NOUVEAU CHEMIN

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    _isLoggedIn = await AuthService.isLoggedIn();
    
    if (_isLoggedIn) {
      final result = await AuthService.getUserInfo();
      if (result['success']) {
        _user = User.fromJson(result['user']);
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await AuthService.login(email, password);
    
    if (result['success']) {
      _user = result['user'];
      _isLoggedIn = true;
      notifyListeners();
    }
    
    return result;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final result = await AuthService.register(userData);
    return result;
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}

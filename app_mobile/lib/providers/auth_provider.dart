import 'package:flutter/material.dart';
import 'package:app_mobile/data/models/user.dart';
import 'package:app_mobile/data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _user?.role == 'admin';

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    _isLoggedIn = await AuthService.isLoggedIn();
    
    if (_isLoggedIn) {
      // ✅ CORRIGÉ : utiliser getCurrentUser()
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        _user = user;
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> initializeAuth() async {
    await _checkAuthStatus();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await AuthService.login(email: email, password: password);
    
    if (result['success']) {
      _user = result['user'];
      _isLoggedIn = true;
      notifyListeners();
    }
    
    return result;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final result = await AuthService.register(
      nom: userData['nom'],
      prenom: userData['prenom'],
      email: userData['email'],
      telephone: userData['telephone'],
      password: userData['password'],
    );
    return result;
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
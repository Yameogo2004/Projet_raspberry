import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_mobile/data/services/api_service.dart';
import 'package:app_mobile/data/models/user.dart';

class AuthService {
  static const storage = FlutterSecureStorage();

  // ========== AUTHENTIFICATION ==========
  
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/api/auth/login', {
        'email': email,
        'password': password,
      });
      
      await storage.write(key: 'auth_token', value: response['token']);
      await storage.write(key: 'user_id', value: response['user_id'].toString());
      await storage.write(key: 'user_role', value: response['user']['role']);
      
      return {
        'success': true,
        'user': User.fromJson(response['user']),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/api/auth/register', {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'telephone': telephone,
        'password': password,
      });
      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<void> logout() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'user_role');
  }

  static Future<bool> isLoggedIn() async {
    String? token = await storage.read(key: 'auth_token');
    return token != null;
  }
  
  // ========== GESTION UTILISATEUR ==========
  
  static Future<User?> getCurrentUser() async {
    try {
      final response = await ApiService.get('/api/auth/me');
      if (response['user'] != null) {
        return User.fromJson(response['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  static Future<String?> getStoredRole() async {
    return await storage.read(key: 'user_role');
  }
}
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  static const storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.post('/api/auth/login', {
        'email': email,
        'password': password,
      });
      
      await storage.write(key: 'auth_token', value: response['token']);
      await storage.write(key: 'user_id', value: response['user_id'].toString());
      
      return {
        'success': true,
        'user': User.fromJson(response['user']),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await ApiService.post('/api/auth/register', userData);
      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<void> logout() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user_id');
  }

  static Future<bool> isLoggedIn() async {
    String? token = await storage.read(key: 'auth_token');
    return token != null;
  }
  
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await ApiService.get('/api/auth/me');
      return {'success': true, 'user': response['user']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
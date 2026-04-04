import 'package:app_mobile/core/errors/app_exception.dart';
import 'package:app_mobile/core/errors/failure.dart';
import 'package:app_mobile/data/models/user.dart';
import 'package:app_mobile/data/services/auth_service.dart';

class AuthRepository {
  Future<User?> getCurrentUser() async {
    try {
      return await AuthService.getCurrentUser();
    } on AppException catch (e) {
      throw AuthFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      return await AuthService.login(email: email, password: password);
    } on AppException catch (e) {
      throw AuthFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    try {
      return await AuthService.register(
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        password: password,
      );
    } on AppException catch (e) {
      throw ValidationFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await AuthService.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  Future<String?> getStoredRole() async {
    try {
      return await AuthService.getStoredRole();
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
    } on AppException catch (e) {
      throw AuthFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }
}
import '../../core/errors/app_exception.dart';
import '../../core/errors/failure.dart';
import '../models/alerte.dart';
import '../models/capteur.dart';
import '../models/elevator.dart';
import '../models/parking_statut.dart';
import '../models/payment.dart';
import '../models/stationnement.dart';
import '../models/vehicle.dart';
import '../services/admin_service.dart';

class AdminRepository {
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      return await AdminService.getDashboardData();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Alerte>> getAlertes() async {
    try {
      return await AdminService.getAlertes();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Capteur>> getCapteurs() async {
    try {
      return await AdminService.getCapteurs();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Vehicle>> getVehicules() async {
    try {
      return await AdminService.getVehicules();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Stationnement>> getStationnements() async {
    try {
      return await AdminService.getStationnements();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<Payment>> getPaiements() async {
    try {
      return await AdminService.getPaiements();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<List<ParkingStatut>> getParkingStatusByLevel() async {
    try {
      return await AdminService.getParkingStatusByLevel();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<Elevator?> getElevatorStatus() async {
    try {
      return await AdminService.getElevatorStatus();
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  Future<void> resolveAlerte({
    required int alerteId,
    String? commentaire,
  }) async {
    try {
      await AdminService.resolveAlerte(
        alerteId: alerteId,
        commentaire: commentaire,
      );
    } on AppException catch (e) {
      throw ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }
}
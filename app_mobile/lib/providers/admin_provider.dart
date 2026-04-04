import 'package:flutter/material.dart';

import '../core/errors/error_messages.dart';
import '../data/models/alerte.dart';
import '../data/models/capteur.dart';
import '../data/models/elevator.dart';
import '../data/models/parking_statut.dart';
import '../data/models/payment.dart';
import '../data/models/stationnement.dart';
import '../data/models/vehicle.dart';
import '../data/repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _adminRepository = AdminRepository();

  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  Map<String, dynamic> _dashboardData = {};
  List<Alerte> _alertes = [];
  List<Capteur> _capteurs = [];
  List<Vehicle> _vehicules = [];
  List<Stationnement> _stationnements = [];
  List<Payment> _paiements = [];
  List<ParkingStatut> _parkingLevels = [];
  Elevator? _elevator;

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic> get dashboardData => _dashboardData;
  List<Alerte> get alertes => _alertes;
  List<Capteur> get capteurs => _capteurs;
  List<Vehicle> get vehicules => _vehicules;
  List<Stationnement> get stationnements => _stationnements;
  List<Payment> get paiements => _paiements;
  List<ParkingStatut> get parkingLevels => _parkingLevels;
  Elevator? get elevator => _elevator;

  int get totalAlertesCritiques =>
      _alertes.where((a) => a.niveau.toLowerCase() == 'critique').length;

  int get totalCapteursOffline =>
      _capteurs.where((c) => c.statut.toLowerCase() != 'online').length;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final results = await Future.wait([
        _adminRepository.getDashboardData(),
        _adminRepository.getAlertes(),
        _adminRepository.getCapteurs(),
        _adminRepository.getVehicules(),
        _adminRepository.getStationnements(),
        _adminRepository.getPaiements(),
        _adminRepository.getParkingStatusByLevel(),
        _adminRepository.getElevatorStatus(),
      ]);

      _dashboardData = results[0] as Map<String, dynamic>;
      _alertes = results[1] as List<Alerte>;
      _capteurs = results[2] as List<Capteur>;
      _vehicules = results[3] as List<Vehicle>;
      _stationnements = results[4] as List<Stationnement>;
      _paiements = results[5] as List<Payment>;
      _parkingLevels = results[6] as List<ParkingStatut>;
      _elevator = results[7] as Elevator?;
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    _isRefreshing = true;
    _clearError();
    notifyListeners();

    try {
      await loadDashboard();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadAlertes() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _alertes = await _adminRepository.getAlertes();
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCapteurs() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _capteurs = await _adminRepository.getCapteurs();
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVehicules() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _vehicules = await _adminRepository.getVehicules();
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStationnements() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _stationnements = await _adminRepository.getStationnements();
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPaiements() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _paiements = await _adminRepository.getPaiements();
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resolveAlerte({
    required int alerteId,
    String? commentaire,
  }) async {
    _clearError();
    notifyListeners();

    try {
      await _adminRepository.resolveAlerte(
        alerteId: alerteId,
        commentaire: commentaire,
      );
      await loadAlertes();
    } catch (e) {
      _errorMessage = ErrorMessages.fromException(e);
      notifyListeners();
    }
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
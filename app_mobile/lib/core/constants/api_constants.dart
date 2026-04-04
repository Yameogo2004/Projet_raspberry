class ApiConstants {
  ApiConstants._();

  static const String appName = 'Smart Parking Admin';

  // Change selon ton environnement
  // Android Emulator -> 10.0.2.2
  // Web / Desktop local -> 127.0.0.1
  static const String baseUrl = 'http://127.0.0.1:5000';

  static const String apiPrefix = '/api';

  // Auth
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String me = '$apiPrefix/auth/me';
  static const String logout = '$apiPrefix/auth/logout';

  // Admin Dashboard
  static const String adminDashboard = '$apiPrefix/admin/dashboard';
  static const String adminAlerts = '$apiPrefix/admin/alertes';
  static const String adminSensors = '$apiPrefix/admin/capteurs';
  static const String adminVehicles = '$apiPrefix/admin/vehicules';
  static const String adminParkings = '$apiPrefix/admin/parking';
  static const String adminParkingLevels = '$apiPrefix/admin/parking/niveaux';
  static const String adminParkingSpots = '$apiPrefix/admin/parking/places';
  static const String adminStationnements = '$apiPrefix/admin/stationnements';
  static const String adminPayments = '$apiPrefix/admin/paiements';
  static const String adminElevator = '$apiPrefix/admin/ascenseur';

  // General parking
  static const String parkingStatus = '$apiPrefix/parking/statut';
  static const String parkingStatusByLevel = '$apiPrefix/parking/statut-par-niveau';

  // Client / reservation / vehicle
  static const String reservations = '$apiPrefix/reservation';
  static const String activeParking = '$apiPrefix/stationnement/actif';
  static const String vehicles = '$apiPrefix/vehicules';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
import 'dart:async';

import 'package:flutter/material.dart';

import '../core/network/network_info.dart';

class ConnectivityProvider extends ChangeNotifier {
  final NetworkInfo _networkInfo = const NetworkInfoImpl();

  bool _isConnected = true;
  bool _isChecking = false;
  Timer? _timer;

  bool get isConnected => _isConnected;
  bool get isChecking => _isChecking;

  ConnectivityProvider() {
    checkConnection();
    _startMonitoring();
  }

  Future<void> checkConnection() async {
    _isChecking = true;
    notifyListeners();

    try {
      _isConnected = await _networkInfo.isConnected;
    } catch (_) {
      _isConnected = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  void _startMonitoring() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final result = await _networkInfo.isConnected;
      if (result != _isConnected) {
        _isConnected = result;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1E88E5);
  static const Color secondary = Color(0xFF00ACC1);
  static const Color accent = Color(0xFFFFC107);

  // Dark theme background
  static const Color background = Color(0xFF0F1115);
  static const Color surface = Color(0xFF171A21);
  static const Color surfaceLight = Color(0xFF1F2430);
  static const Color card = Color(0xFF1A1F29);
  static const Color border = Color(0xFF2A3140);

  // Text
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFB0B8C4);
  static const Color textMuted = Color(0xFF7D8795);
  static const Color textOnPrimary = Colors.white;

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Parking-specific
  static const Color parkingFree = Color(0xFF22C55E);
  static const Color parkingOccupied = Color(0xFFEF4444);
  static const Color parkingReserved = Color(0xFFF59E0B);
  static const Color parkingDisabled = Color(0xFF6B7280);
  static const Color parkingElectric = Color(0xFF14B8A6);

  // Alert levels
  static const Color alertInfo = Color(0xFF3B82F6);
  static const Color alertWarning = Color(0xFFF59E0B);
  static const Color alertCritical = Color(0xFFDC2626);

  // Sensor states
  static const Color sensorOnline = Color(0xFF22C55E);
  static const Color sensorOffline = Color(0xFF9CA3AF);
  static const Color sensorError = Color(0xFFEF4444);

  // Overlays
  static const Color overlayDark = Color(0x99000000);
  static const Color divider = Color(0xFF2A3140);

  // Neutral greys
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ✅ CORRIGÉ ICI
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
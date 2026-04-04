import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color card;
  final Color border;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  final Color parkingFree;
  final Color parkingOccupied;
  final Color parkingReserved;
  final Color parkingDisabled;
  final Color parkingElectric;

  final Color sensorOnline;
  final Color sensorOffline;
  final Color sensorError;

  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.parkingFree,
    required this.parkingOccupied,
    required this.parkingReserved,
    required this.parkingDisabled,
    required this.parkingElectric,
    required this.sensorOnline,
    required this.sensorOffline,
    required this.sensorError,
  });

  const AppThemeColors.dark()
      : background = AppColors.background,
        surface = AppColors.surface,
        surfaceLight = AppColors.surfaceLight,
        card = AppColors.card,
        border = AppColors.border,
        textPrimary = AppColors.textPrimary,
        textSecondary = AppColors.textSecondary,
        textMuted = AppColors.textMuted,
        success = AppColors.success,
        warning = AppColors.warning,
        danger = AppColors.danger,
        info = AppColors.info,
        parkingFree = AppColors.parkingFree,
        parkingOccupied = AppColors.parkingOccupied,
        parkingReserved = AppColors.parkingReserved,
        parkingDisabled = AppColors.parkingDisabled,
        parkingElectric = AppColors.parkingElectric,
        sensorOnline = AppColors.sensorOnline,
        sensorOffline = AppColors.sensorOffline,
        sensorError = AppColors.sensorError;

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceLight,
    Color? card,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? parkingFree,
    Color? parkingOccupied,
    Color? parkingReserved,
    Color? parkingDisabled,
    Color? parkingElectric,
    Color? sensorOnline,
    Color? sensorOffline,
    Color? sensorError,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      card: card ?? this.card,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      parkingFree: parkingFree ?? this.parkingFree,
      parkingOccupied: parkingOccupied ?? this.parkingOccupied,
      parkingReserved: parkingReserved ?? this.parkingReserved,
      parkingDisabled: parkingDisabled ?? this.parkingDisabled,
      parkingElectric: parkingElectric ?? this.parkingElectric,
      sensorOnline: sensorOnline ?? this.sensorOnline,
      sensorOffline: sensorOffline ?? this.sensorOffline,
      sensorError: sensorError ?? this.sensorError,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;

    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      parkingFree: Color.lerp(parkingFree, other.parkingFree, t)!,
      parkingOccupied: Color.lerp(parkingOccupied, other.parkingOccupied, t)!,
      parkingReserved: Color.lerp(parkingReserved, other.parkingReserved, t)!,
      parkingDisabled: Color.lerp(parkingDisabled, other.parkingDisabled, t)!,
      parkingElectric: Color.lerp(parkingElectric, other.parkingElectric, t)!,
      sensorOnline: Color.lerp(sensorOnline, other.sensorOnline, t)!,
      sensorOffline: Color.lerp(sensorOffline, other.sensorOffline, t)!,
      sensorError: Color.lerp(sensorError, other.sensorError, t)!,
    );
  }
}

extension ThemeDataX on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? const AppThemeColors.dark();
}
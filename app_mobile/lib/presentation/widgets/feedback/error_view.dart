import 'package:flutter/material.dart';
import 'package:app_mobile/core/constants/app_colors.dart';
import 'package:app_mobile/core/constants/app_radius.dart';
import 'package:app_mobile/core/constants/app_spacing.dart';
import 'package:app_mobile/core/theme/text_styles.dart';
import 'package:app_mobile/presentation/widgets/buttons/custom_button.dart';

class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;
  final EdgeInsetsGeometry padding;

  const ErrorView({
    super.key,
    this.title = 'Une erreur est survenue',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Réessayer',
    this.icon = Icons.error_outline_rounded,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.danger,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.lg),
                // ✅ CORRIGÉ : utilisation des bons paramètres
                CustomButton(
                  text: retryLabel,
                  onPressed: onRetry!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/payment.dart';
import '../../../../providers/admin_provider.dart';

class AdminPaiementsScreen extends StatefulWidget {
  const AdminPaiementsScreen({super.key});

  @override
  State<AdminPaiementsScreen> createState() => _AdminPaiementsScreenState();
}

class _AdminPaiementsScreenState extends State<AdminPaiementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadPaiements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiements'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.paiements.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null && provider.paiements.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
            );
          }

          if (provider.paiements.isEmpty) {
            return Center(
              child: Text(
                'Aucun paiement trouvé.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          final double totalAmount = provider.paiements.fold<double>(
            0,
            (sum, payment) => sum + payment.montant,
          );

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [const
                      Text(
                        'Montant total',
                        style: AppTextStyles.bodySmall,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        '${totalAmount.toStringAsFixed(2)} MAD',
                        style: AppTextStyles.kpiValue,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  itemCount: provider.paiements.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final payment = provider.paiements[index];
                    return _PaymentCard(payment: payment);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Payment payment;

  const _PaymentCard({
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(payment.statut);

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.payments_rounded,
              color: statusColor,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${payment.montant.toStringAsFixed(2)} MAD',
                  style: AppTextStyles.cardTitle,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  'Paiement #${payment.id}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              payment.statut,
              style: AppTextStyles.labelMedium.copyWith(
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
      case 'error':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }
}

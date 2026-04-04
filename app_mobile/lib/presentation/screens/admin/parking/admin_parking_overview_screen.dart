import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/parking_statut.dart';
import '../../../../providers/admin_provider.dart';

class AdminParkingOverviewScreen extends StatefulWidget {
  const AdminParkingOverviewScreen({super.key});

  @override
  State<AdminParkingOverviewScreen> createState() =>
      _AdminParkingOverviewScreenState();
}

class _AdminParkingOverviewScreenState
    extends State<AdminParkingOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vue globale du parking'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.parkingLevels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final levels = provider.parkingLevels;

          if (levels.isEmpty) {
            return Center(
              child: Text(
                'Aucune donnée parking disponible.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          final ParkingStatut global = _aggregate(levels);

          return ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              _ParkingGlobalCard(global: global),
              SizedBox(height: AppSpacing.sectionGap),
              const
              Text('Par niveau', style: AppTextStyles.sectionTitle),
              SizedBox(height: AppSpacing.md),
              ...List.generate(levels.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ParkingLevelCard(
                    levelIndex: index + 1,
                    statut: levels[index],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  ParkingStatut _aggregate(List<ParkingStatut> levels) {
    int total = 0;
    int libres = 0;
    int occupes = 0;

    for (final level in levels) {
      total += level.total;
      libres += level.libres;
      occupes += level.occupes;
    }

    return ParkingStatut(
      total: total,
      libres: libres,
      occupes: occupes,
    );
  }
}

class _ParkingGlobalCard extends StatelessWidget {
  final ParkingStatut global;

  const _ParkingGlobalCard({required this.global});

  @override
  Widget build(BuildContext context) {
    final double occupancyRate =
        global.total > 0 ? global.occupes / global.total : 0;

    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const
          Text('État global', style: AppTextStyles.sectionTitle),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Total',
                  value: '${global.total}',
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  label: 'Libres',
                  value: '${global.libres}',
                  color: AppColors.parkingFree,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  label: 'Occupées',
                  value: '${global.occupes}',
                  color: AppColors.parkingOccupied,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: occupancyRate.clamp(0, 1),
              minHeight: 12,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                occupancyRate > 0.8
                    ? AppColors.danger
                    : occupancyRate > 0.6
                        ? AppColors.warning
                        : AppColors.success,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Taux d’occupation: ${(occupancyRate * 100).toStringAsFixed(1)}%',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.kpiValue.copyWith(fontSize: 22, color: color),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _ParkingLevelCard extends StatelessWidget {
  final int levelIndex;
  final ParkingStatut statut;

  const _ParkingLevelCard({
    required this.levelIndex,
    required this.statut,
  });

  @override
  Widget build(BuildContext context) {
    final double occupation =
        statut.total > 0 ? statut.occupes / statut.total : 0;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Niveau $levelIndex', style: AppTextStyles.cardTitle),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total: ${statut.total}',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              Expanded(
                child: Text(
                  'Libres: ${statut.libres}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Occupées: ${statut.occupes}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: occupation.clamp(0, 1),
              minHeight: 10,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

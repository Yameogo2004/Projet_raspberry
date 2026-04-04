import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/vehicle.dart';
import '../../../../providers/admin_provider.dart';

class AdminVehiculesScreen extends StatefulWidget {
  const AdminVehiculesScreen({super.key});

  @override
  State<AdminVehiculesScreen> createState() => _AdminVehiculesScreenState();
}

class _AdminVehiculesScreenState extends State<AdminVehiculesScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadVehicules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Véhicules'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.vehicules.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ CORRIGÉ : utilisation de 'plaque' au lieu de 'matricule'
          final vehicles = provider.vehicules.where((vehicle) {
            final key = '${vehicle.id} ${vehicle.plaque} ${vehicle.modele} ${vehicle.marque}'.toLowerCase();
            return key.contains(_search.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un véhicule...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              Expanded(
                child: vehicles.isEmpty
                    ? const _EmptyVehiclesState()
                    : ListView.separated(
                        padding: EdgeInsets.all(AppSpacing.md),
                        itemCount: vehicles.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          return _VehicleCard(vehicle: vehicle);
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

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: AppColors.info,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ CORRIGÉ : 'plaque' au lieu de 'matricule'
                Text(vehicle.plaque, style: AppTextStyles.cardTitle),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  'Modèle: ${vehicle.modele}',  // ← 'modele' au lieu de 'type'
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  'Marque: ${vehicle.marque}',  // ← Ajouté
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  'ID: ${vehicle.id}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyVehiclesState extends StatelessWidget {
  const _EmptyVehiclesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Aucun véhicule trouvé.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

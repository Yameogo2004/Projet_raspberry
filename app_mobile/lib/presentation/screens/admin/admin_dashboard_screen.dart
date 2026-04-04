import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../providers/admin_provider.dart';
import 'alerts/admin_alerts_screen.dart';
import 'capteurs/admin_capteurs_screen.dart';
import 'paiements/admin_paiements_screen.dart';
import 'parking/admin_parking_overview_screen.dart';
import 'parking/admin_parking_spots_screen.dart';
import 'settings/admin_settings_screen.dart';
import 'stationnements/admin_stationnements_screen.dart';
import 'vehicules/admin_vehicules_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading &&
              adminProvider.dashboardData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.errorMessage != null &&
              adminProvider.dashboardData.isEmpty) {
            return _AdminErrorState(
              message: adminProvider.errorMessage!,
              onRetry: adminProvider.loadDashboard,
            );
          }

          final dashboard = adminProvider.dashboardData;

          final int totalPlaces = _toInt(dashboard['total_places']);
          final int occupiedPlaces = _toInt(dashboard['occupied_places']);
          final int freePlaces = _toInt(dashboard['free_places']);
          final int totalVehicles = adminProvider.vehicules.length;
          final int totalPayments = adminProvider.paiements.length;
          final int totalSensors = adminProvider.capteurs.length;

          final double occupancyRate = totalPlaces > 0
              ? (occupiedPlaces / totalPlaces) * 100
              : 0;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: adminProvider.refreshDashboard,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.screenHorizontal),
              children: [
                _DashboardHeroCard(
                  title: 'Centre de supervision',
                  subtitle:
                      'Surveillez le parking, les alertes, les capteurs et les paiements en temps réel.',
                  isRefreshing: adminProvider.isRefreshing,
                ),
                SizedBox(height: AppSpacing.sectionGap),

                const Text('Vue globale', style: AppTextStyles.sectionTitle),
                SizedBox(height: AppSpacing.md),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.dashboardGridGap,
                  mainAxisSpacing: AppSpacing.dashboardGridGap,
                  childAspectRatio: 1.08,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _KpiCard(
                      title: 'Places totales',
                      value: '$totalPlaces',
                      subtitle: 'Capacité globale',
                      icon: Icons.local_parking_rounded,
                      color: AppColors.primary,
                    ),
                    _KpiCard(
                      title: 'Places occupées',
                      value: '$occupiedPlaces',
                      subtitle:
                          '${occupancyRate.toStringAsFixed(1)}% d’occupation',
                      icon: Icons.directions_car_filled_rounded,
                      color: AppColors.parkingOccupied,
                    ),
                    _KpiCard(
                      title: 'Places libres',
                      value: '$freePlaces',
                      subtitle: 'Disponibles maintenant',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.parkingFree,
                    ),
                    _KpiCard(
                      title: 'Alertes critiques',
                      value: '${adminProvider.totalAlertesCritiques}',
                      subtitle: 'Demandent une action',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.alertCritical,
                    ),
                    _KpiCard(
                      title: 'Capteurs',
                      value: '$totalSensors',
                      subtitle:
                          '${adminProvider.totalCapteursOffline} hors ligne',
                      icon: Icons.sensors_rounded,
                      color: AppColors.secondary,
                    ),
                    _KpiCard(
                      title: 'Paiements',
                      value: '$totalPayments',
                      subtitle: 'Transactions reçues',
                      icon: Icons.payments_rounded,
                      color: AppColors.parkingElectric,
                    ),
                    _KpiCard(
                      title: 'Véhicules',
                      value: '$totalVehicles',
                      subtitle: 'Enregistrés / détectés',
                      icon: Icons.directions_car_rounded,
                      color: AppColors.info,
                    ),
                    _KpiCard(
                      title: 'Ascenseur',
                      value: adminProvider.elevator?.statut ?? 'N/A',
                      subtitle: adminProvider.elevator != null
                          ? 'Niveau ${adminProvider.elevator!.niveauActuel}'
                          : 'État système',
                      icon: Icons.elevator_rounded,
                      color: AppColors.accent,
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.sectionGap),

                const Text('Accès rapide', style: AppTextStyles.sectionTitle),
                SizedBox(height: AppSpacing.md),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.dashboardGridGap,
                  mainAxisSpacing: AppSpacing.dashboardGridGap,
                  childAspectRatio: 1.22,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _QuickActionCard(
                      title: 'Alertes',
                      subtitle: 'Incidents et sécurité',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.alertCritical,
                      onTap: () =>
                          _open(context, const AdminAlertsScreen()),
                    ),
                    _QuickActionCard(
                      title: 'Capteurs',
                      subtitle: 'État et supervision',
                      icon: Icons.sensors_rounded,
                      color: AppColors.secondary,
                      onTap: () =>
                          _open(context, const AdminCapteursScreen()),
                    ),
                    _QuickActionCard(
                      title: 'Parking global',
                      subtitle: 'Niveaux et occupation',
                      icon: Icons.local_parking_rounded,
                      color: AppColors.primary,
                      onTap: () => _open(
                          context, const AdminParkingOverviewScreen()),
                    ),
                    _QuickActionCard(
                      title: 'Places',
                      subtitle: 'Suivi détaillé',
                      icon: Icons.grid_view_rounded,
                      color: AppColors.parkingFree,
                      onTap: () => _open(
                          context, const AdminParkingSpotsScreen()),
                    ),
                    _QuickActionCard(
                      title: 'Véhicules',
                      subtitle: 'Liste et plaques',
                      icon: Icons.directions_car_filled_rounded,
                      color: AppColors.info,
                      onTap: () =>
                          _open(context, const AdminVehiculesScreen()),
                    ),
                    _QuickActionCard(
                      title: 'Stationnements',
                      subtitle: 'Entrées et sorties',
                      icon: Icons.history_rounded,
                      color: AppColors.warning,
                      onTap: () => _open(
                          context, const AdminStationnementsScreen()),
                    ),
                    _QuickActionCard(
                      title: 'Paiements',
                      subtitle: 'Transactions',
                      icon: Icons.payments_rounded,
                      color: AppColors.parkingElectric,
                      onTap: () =>
                          _open(context, const AdminPaiementsScreen()),
                    ),
                    _QuickActionCard(
                      title: 'Paramètres',
                      subtitle: 'Configuration admin',
                      icon: Icons.settings_rounded,
                      color: AppColors.grey400,
                      onTap: () =>
                          _open(context, const AdminSettingsScreen()),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _DashboardHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isRefreshing;

  const _DashboardHeroCard({
    required this.title,
    required this.subtitle,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1565C0),
            Color(0xFF0D47A1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: Colors.white)),
                SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.white.withOpacity(0.88)),
                ),
                if (isRefreshing) ...[
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Actualisation en cours...',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.90)),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.kpiValue),
          SizedBox(height: AppSpacing.xs),
          Text(title, style: AppTextStyles.kpiLabel),
          SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Text(title, style: AppTextStyles.cardTitle),
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _AdminErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.danger, size: 56),
            SizedBox(height: AppSpacing.md),
            const Text('Impossible de charger le dashboard',
                style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center),
            SizedBox(height: AppSpacing.sm),
            Text(message,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
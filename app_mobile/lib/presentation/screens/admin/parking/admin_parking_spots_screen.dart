import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/parking_spot.dart';
import '../../../../data/services/api_service.dart';

class AdminParkingSpotsScreen extends StatefulWidget {
  const AdminParkingSpotsScreen({super.key});

  @override
  State<AdminParkingSpotsScreen> createState() =>
      _AdminParkingSpotsScreenState();
}

class _AdminParkingSpotsScreenState extends State<AdminParkingSpotsScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedStatus = 'Tous';

  List<ParkingSpot> _allSpots = [];

  @override
  void initState() {
    super.initState();
    _loadParkingSpots();
  }

  Future<void> _loadParkingSpots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get(ApiConstants.adminParkingSpots);
      final List<ParkingSpot> parsedSpots = _parseParkingSpots(response);

      setState(() {
        _allSpots = parsedSpots;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger les places de parking.\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshParkingSpots() async {
    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get(ApiConstants.adminParkingSpots);
      final List<ParkingSpot> parsedSpots = _parseParkingSpots(response);

      setState(() {
        _allSpots = parsedSpots;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible d’actualiser les places.\n$e';
      });
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  List<ParkingSpot> _parseParkingSpots(dynamic response) {
    if (response is List) {
      return response
          .map((item) => ParkingSpot.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (response is Map) {
      if (response['places'] is List) {
        return (response['places'] as List)
            .map(
              (item) => ParkingSpot.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      if (response['parking_spots'] is List) {
        return (response['parking_spots'] as List)
            .map(
              (item) => ParkingSpot.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      if (response['data'] is List) {
        return (response['data'] as List)
            .map(
              (item) => ParkingSpot.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
    }

    return [];
  }

  List<ParkingSpot> get _filteredSpots {
    return _allSpots.where((spot) {
      final matchesSearch =
          spot.numero.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              spot.id.toString().contains(_searchQuery);

      final matchesStatus = _selectedStatus == 'Tous'
          ? true
          : spot.statut.toLowerCase() == _selectedStatus.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int get _freeCount =>
      _allSpots.where((spot) => spot.statut.toLowerCase() == 'libre').length;

  int get _occupiedCount => _allSpots
      .where((spot) => spot.statut.toLowerCase() == 'occupée')
      .length;

  int get _reservedCount => _allSpots
      .where((spot) => spot.statut.toLowerCase() == 'réservée')
      .length;

  int get _otherCount =>
      _allSpots.length - _freeCount - _occupiedCount - _reservedCount;

  @override
  Widget build(BuildContext context) {
    final filteredSpots = _filteredSpots;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Places de parking'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null && _allSpots.isEmpty
              ? _ParkingSpotsErrorState(
                  message: _errorMessage!,
                  onRetry: _loadParkingSpots,
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _refreshParkingSpots,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(AppSpacing.md),
                    children: [
                      _ParkingSpotsHeaderCard(
                        total: _allSpots.length,
                        free: _freeCount,
                        occupied: _occupiedCount,
                        reserved: _reservedCount,
                        other: _otherCount,
                        isRefreshing: _isRefreshing,
                      ),
                      SizedBox(height: AppSpacing.sectionGap),
                      const Text(
                        'Recherche et filtres',
                        style: AppTextStyles.sectionTitle,
                      ),
                      SizedBox(height: AppSpacing.md),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Rechercher par numéro ou ID...',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _StatusFilterChip(
                              label: 'Tous',
                              selected: _selectedStatus == 'Tous',
                              onTap: () {
                                setState(() {
                                  _selectedStatus = 'Tous';
                                });
                              },
                            ),
                            _StatusFilterChip(
                              label: 'Libre',
                              selected: _selectedStatus == 'Libre',
                              onTap: () {
                                setState(() {
                                  _selectedStatus = 'Libre';
                                });
                              },
                            ),
                            _StatusFilterChip(
                              label: 'Occupée',
                              selected: _selectedStatus == 'Occupée',
                              onTap: () {
                                setState(() {
                                  _selectedStatus = 'Occupée';
                                });
                              },
                            ),
                            _StatusFilterChip(
                              label: 'Réservée',
                              selected: _selectedStatus == 'Réservée',
                              onTap: () {
                                setState(() {
                                  _selectedStatus = 'Réservée';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.sectionGap),
                      const Text(
                        'Liste des places',
                        style: AppTextStyles.sectionTitle,
                      ),
                      SizedBox(height: AppSpacing.md),
                      if (_errorMessage != null && _allSpots.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(bottom: AppSpacing.md),
                          padding: EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      if (filteredSpots.isEmpty)
                        const _ParkingSpotsEmptyState()
                      else
                        ...filteredSpots.map(
                          (spot) => Padding(
                            padding: EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _ParkingSpotCard(spot: spot),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _ParkingSpotsHeaderCard extends StatelessWidget {
  final int total;
  final int free;
  final int occupied;
  final int reserved;
  final int other;
  final bool isRefreshing;

  const _ParkingSpotsHeaderCard({
    required this.total,
    required this.free,
    required this.occupied,
    required this.reserved,
    required this.other,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supervision des places',
            style: AppTextStyles.sectionTitle,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Consultez l’état détaillé de chaque place de parking.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (isRefreshing) ...[
            SizedBox(height: AppSpacing.sm),
            const Row(
              children: [
                SizedBox(
                  width: 14,
                   height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Actualisation...',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
          SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MiniOverviewBadge(
                label: 'Total',
                value: '$total',
                color: AppColors.primary,
              ),
              _MiniOverviewBadge(
                label: 'Libres',
                value: '$free',
                color: AppColors.parkingFree,
              ),
              _MiniOverviewBadge(
                label: 'Occupées',
                value: '$occupied',
                color: AppColors.parkingOccupied,
              ),
              _MiniOverviewBadge(
                label: 'Réservées',
                value: '$reserved',
                color: AppColors.parkingReserved,
              ),
              if (other > 0)
                _MiniOverviewBadge(
                  label: 'Autres',
                  value: '$other',
                  color: AppColors.grey400,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniOverviewBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniOverviewBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            TextSpan(
              text: value,
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = selected
        ? AppColors.primary.withValues(alpha: 0.16)
        : AppColors.surfaceLight;

    final Color textColor =
        selected ? AppColors.primary : AppColors.textSecondary;

    final Color borderColor =
        selected ? AppColors.primary : AppColors.border;

    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _ParkingSpotCard extends StatelessWidget {
  final ParkingSpot spot;

  const _ParkingSpotCard({
    required this.spot,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(spot.statut);
    final IconData statusIcon = _statusIcon(spot.statut);

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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spot.numero,
                  style: AppTextStyles.cardTitle,
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  'ID place: ${spot.id}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          _SpotStatusBadge(
            label: spot.statut,
            color: statusColor,
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'libre':
        return AppColors.parkingFree;
      case 'occupée':
      case 'occupee':
        return AppColors.parkingOccupied;
      case 'réservée':
      case 'reservee':
        return AppColors.parkingReserved;
      case 'disabled':
      case 'indisponible':
        return AppColors.parkingDisabled;
      default:
        return AppColors.grey400;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'libre':
        return Icons.check_circle_rounded;
      case 'occupée':
      case 'occupee':
        return Icons.directions_car_filled_rounded;
      case 'réservée':
      case 'reservee':
        return Icons.bookmark_rounded;
      case 'disabled':
      case 'indisponible':
        return Icons.block_rounded;
      default:
        return Icons.local_parking_rounded;
    }
  }
}

class _SpotStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SpotStatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ParkingSpotsErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ParkingSpotsErrorState({
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
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.danger,
            ),
            SizedBox(height: AppSpacing.md),
            const Text(
              'Impossible de charger les places',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
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

class _ParkingSpotsEmptyState extends StatelessWidget {
  const _ParkingSpotsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_parking_outlined,
            size: 44,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppSpacing.md),
          const Text(
            'Aucune place trouvée',
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Essaie de changer le filtre ou le texte de recherche.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

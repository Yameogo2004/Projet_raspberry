import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/alerte.dart';
import '../../../../providers/admin_provider.dart';

class AdminAlertsScreen extends StatefulWidget {
  const AdminAlertsScreen({super.key});

  @override
  State<AdminAlertsScreen> createState() => _AdminAlertsScreenState();
}

class _AdminAlertsScreenState extends State<AdminAlertsScreen> {
  String _selectedLevel = 'Toutes';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAlertes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.alertes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = _filterAlertes(provider.alertes);

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: _AlertSummaryCard(
                        title: 'Total',
                        value: '${provider.alertes.length}',
                        color: AppColors.info,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _AlertSummaryCard(
                        title: 'Critiques',
                        value: '${provider.totalAlertesCritiques}',
                        color: AppColors.alertCritical,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Toutes',
                        selected: _selectedLevel == 'Toutes',
                        onTap: () => setState(() => _selectedLevel = 'Toutes'),
                      ),
                      _FilterChip(
                        label: 'Critique',
                        selected: _selectedLevel == 'Critique',
                        onTap: () => setState(() => _selectedLevel = 'Critique'),
                      ),
                      _FilterChip(
                        label: 'Warning',
                        selected: _selectedLevel == 'Warning',
                        onTap: () => setState(() => _selectedLevel = 'Warning'),
                      ),
                      _FilterChip(
                        label: 'Info',
                        selected: _selectedLevel == 'Info',
                        onTap: () => setState(() => _selectedLevel = 'Info'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Expanded(
                child: filtered.isEmpty
                    ? const _EmptyState(message: 'Aucune alerte trouvée.')
                    : ListView.separated(
                        padding: EdgeInsets.all(AppSpacing.md),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final alerte = filtered[index];
                          return _AlerteCard(alerte: alerte);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Alerte> _filterAlertes(List<Alerte> source) {
    if (_selectedLevel == 'Toutes') return source;
    return source
        .where(
          (a) => a.niveau.toLowerCase() == _selectedLevel.toLowerCase(),
        )
        .toList();
  }
}

class _AlerteCard extends StatelessWidget {
  final Alerte alerte;

  const _AlerteCard({required this.alerte});

  @override
  Widget build(BuildContext context) {
    final color = _alertColor(alerte.niveau);

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: color,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alerte.type,
                        style: AppTextStyles.cardTitle,
                      ),
                    ),
                    _LevelBadge(
                      label: alerte.niveau,
                      color: color,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  alerte.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      await context.read<AdminProvider>().resolveAlerte(
                            alerteId: alerte.id,
                          );
                    },
                    icon: const Icon(Icons.task_alt_rounded, size: 18),
                    label: const Text('Résoudre'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _alertColor(String niveau) {
    switch (niveau.toLowerCase()) {
      case 'critique':
        return AppColors.alertCritical;
      case 'warning':
        return AppColors.alertWarning;
      case 'info':
        return AppColors.alertInfo;
      default:
        return AppColors.warning;
    }
  }
}

class _LevelBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _LevelBadge({
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
        style: AppTextStyles.labelMedium.copyWith(color: color),
      ),
    );
  }
}

class _AlertSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _AlertSummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.kpiValue),
          SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.primary.withValues(alpha: 0.118)
        : AppColors.surfaceLight;

    final fg = selected ? AppColors.primary : AppColors.textSecondary;

    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.xs),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: fg),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

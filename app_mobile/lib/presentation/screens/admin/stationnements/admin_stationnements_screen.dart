import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/stationnement.dart';
import '../../../../providers/admin_provider.dart';

class AdminStationnementsScreen extends StatefulWidget {
  const AdminStationnementsScreen({super.key});

  @override
  State<AdminStationnementsScreen> createState() =>
      _AdminStationnementsScreenState();
}

class _AdminStationnementsScreenState extends State<AdminStationnementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadStationnements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stationnements'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.stationnements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.stationnements.isEmpty) {
            return Center(
              child: Text(
                'Aucun stationnement trouvé.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: provider.stationnements.length,
            separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final stationnement = provider.stationnements[index];
              return _StationnementCard(stationnement: stationnement);
            },
          );
        },
      ),
    );
  }
}

class _StationnementCard extends StatelessWidget {
  final Stationnement stationnement;

  const _StationnementCard({
    required this.stationnement,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ CORRIGÉ : utilisation de dateSortie
    final bool actif = stationnement.dateSortie == null && stationnement.estActif;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Session #${stationnement.id}',
                  style: AppTextStyles.cardTitle,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: (actif ? AppColors.success : AppColors.grey500)
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  actif ? 'En cours' : 'Terminée',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: actif ? AppColors.success : AppColors.grey400,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          // ✅ CORRIGÉ : utilisation de vehiculeId
          _InfoRow(label: 'Véhicule ID', value: '${stationnement.vehiculeId ?? '-'}'),
          // ✅ CORRIGÉ : utilisation de emplacementId
          _InfoRow(label: 'Place ID', value: '${stationnement.emplacementId ?? '-'}'),
          // ✅ CORRIGÉ : utilisation de dateEntree
          _InfoRow(
            label: 'Entrée',
            value: _formatDate(stationnement.dateEntree),
          ),
          // ✅ CORRIGÉ : utilisation de dateSortie
          _InfoRow(
            label: 'Sortie',
            value: stationnement.dateSortie != null 
                ? _formatDate(stationnement.dateSortie!) 
                : '—',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

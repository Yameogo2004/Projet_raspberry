import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool notificationsEnabled = true;
  bool autoRefreshEnabled = true;
  bool criticalAlertsOnly = false;
  bool maintenanceMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres Admin'),
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          const Text(
            'Préférences',
            style: AppTextStyles.sectionTitle,
          ),
          SizedBox(height: AppSpacing.md),
          _SettingTile(
            title: 'Notifications activées',
            subtitle: 'Recevoir les notifications système',
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),
          _SettingTile(
            title: 'Actualisation automatique',
            subtitle: 'Rafraîchir les données périodiquement',
            value: autoRefreshEnabled,
            onChanged: (value) {
              setState(() => autoRefreshEnabled = value);
            },
          ),
          _SettingTile(
            title: 'Alertes critiques uniquement',
            subtitle: 'Filtrer les alertes non prioritaires',
            value: criticalAlertsOnly,
            onChanged: (value) {
              setState(() => criticalAlertsOnly = value);
            },
          ),
          _SettingTile(
            title: 'Mode maintenance',
            subtitle: 'Basculer le système en maintenance',
            value: maintenanceMode,
            onChanged: (value) {
              setState(() => maintenanceMode = value);
            },
          ),
          SizedBox(height: AppSpacing.sectionGap),
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informations système',
                  style: AppTextStyles.cardTitle,
                ),
                SizedBox(height: AppSpacing.md),
                _InfoItem(label: 'Version', value: '1.0.0'),
                _InfoItem(label: 'Environnement', value: 'Production'),
                _InfoItem(label: 'Thème', value: 'Dark'),
                _InfoItem(label: 'Module', value: 'Administration'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        title: Text(
          title,
          style: AppTextStyles.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

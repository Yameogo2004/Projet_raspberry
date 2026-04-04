import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../auth/login_screen.dart';
import '../settings/language_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color primaryColor = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec photo
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: primaryColor,
                        child: Text(
                          user?.prenom?.isNotEmpty == true
                              ? user!.prenom[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.nomComplet ?? 'Utilisateur',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role?.toUpperCase() ?? 'CLIENT',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Cartes d'informations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    title: 'Informations personnelles',
                    children: [
                      _buildInfoRow('Nom complet', user?.nomComplet ?? 'Non renseigné'),
                      _buildInfoRow('Email', user?.email ?? 'Non renseigné'),
                      _buildInfoRow('Téléphone', user?.telephone ?? 'Non renseigné'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoCard(
                    icon: Icons.settings,
                    title: 'Préférences',
                    children: [
                      _buildSwitchRow('Notifications', user?.notificationsActives ?? true),
                      _buildInfoRow('Langue', 'Français'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoCard(
                    icon: Icons.payment,
                    title: 'Paiement',
                    children: [
                      _buildInfoRow('Carte enregistrée', user?.carteBancaireId != null ? '**** **** **** ${user!.carteBancaireId!.substring(user.carteBancaireId!.length - 4)}' : 'Aucune carte'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Carte Langue
                  _buildInfoCard(
                    icon: Icons.language,
                    title: 'Langue',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language, color: primaryColor),
                        title: const Text('Changer la langue'),
                        subtitle: const Text('Français, English, Español, العربية'),
                        trailing: const Icon(Icons.chevron_right, color: primaryColor),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LanguageScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Bouton déconnexion
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('SE DÉCONNECTER', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: primaryColor, size: 22),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children.map((child) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: child,
          )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Switch(
          value: value,
          onChanged: (newValue) {},
          activeColor: primaryColor,
        ),
      ],
    );
  }
}
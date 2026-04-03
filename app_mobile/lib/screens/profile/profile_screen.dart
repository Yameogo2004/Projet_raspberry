import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                user?.prenom[0].toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            
            // Nom
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Nom complet'),
                subtitle: Text(user?.nomComplet ?? 'Non renseigné'),
              ),
            ),
            
            // Email
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(user?.email ?? 'Non renseigné'),
              ),
            ),
            
            // Téléphone
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Téléphone'),
                subtitle: Text(user?.telephone ?? 'Non renseigné'),
              ),
            ),
            
            const SizedBox(height: 30),
            
            CustomButton(
              text: 'Se déconnecter',
              onPressed: () async {
                await authProvider.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/parking.dart';
import '../reservation/reservation_form_screen.dart';
import '../parking/locate_vehicle_screen.dart';
import '../profile/profile_screen.dart';
import '../parking/active_parking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  ParkingStatut? _parkingStatut;
  bool _isLoading = true;
  bool _hasActiveParking = false;
  Map<String, dynamic>? _activeParking;

  final List<Widget> _screens = [
    const HomeContent(),
    const LocateVehicleScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    await _chargerStatutParking();
    await _verifierStationnementActif();
  }

  Future<void> _chargerStatutParking() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/api/parking/statut');
      setState(() {
        _parkingStatut = ParkingStatut.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifierStationnementActif() async {
    try {
      final response = await ApiService.get('/api/stationnement/actif');
      setState(() {
        _hasActiveParking = response['has_active'] ?? false;
        _activeParking = response['stationnement'];
      });
    } catch (e) {
      // Pas de stationnement actif
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.location_on), label: 'Localiser'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: _hasActiveParking
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActiveParkingScreen(
                      stationnement: _activeParking,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.directions_car),
              label: const Text('Ma place'),
              backgroundColor: Colors.green,
            )
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReservationFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Réserver'),
            ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return FutureBuilder(
      future: Future.wait([
        ApiService.get('/api/parking/statut-par-niveau'),
        ApiService.get('/api/stationnement/actif'),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final statutNiveaux = snapshot.data?[0] as List? ?? [];
        final activeParking = snapshot.data?[1] as Map?;
        final hasActiveParking = activeParking?['has_active'] ?? false;
        final parkingInfo = activeParking?['stationnement'];
        
        return RefreshIndicator(
          onRefresh: () async {},
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Bienvenue
                Text(
                  'Bonjour ${authProvider.user?.prenom ?? "Visiteur"}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prêt pour votre prochain stationnement ?',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                
                // Carte stationnement actif
                if (hasActiveParking && parkingInfo != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade500],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.park, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'VOTRE VÉHICULE EST GARÉ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          parkingInfo['emplacement'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Entré le ${_formatDate(parkingInfo['date_entree'])}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActiveParkingScreen(
                                  stationnement: parkingInfo,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code),
                          label: const Text('Voir mon ticket'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Titre places disponibles
                const Text(
                  'Places disponibles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                // Cartes par niveau
                if (statutNiveaux.isNotEmpty)
                  ...statutNiveaux.map((niveau) => _buildNiveauCard(niveau, context)),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildNiveauCard(dynamic niveau, BuildContext context) {
    final isRDC = niveau['niveau'] == 0;
    final icon = isRDC ? Icons.business : Icons.elevator;
    final color = isRDC ? Colors.orange : Colors.blue;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          isRDC ? 'Rez-de-chaussée' : 'Étage ${niveau['niveau']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${niveau['places_libres']} places libres'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: niveau['places_libres'] > 0 ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            niveau['places_libres'] > 0 ? 'Disponible' : 'Complet',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        onTap: () {
          // Voir détails des places de ce niveau
        },
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}
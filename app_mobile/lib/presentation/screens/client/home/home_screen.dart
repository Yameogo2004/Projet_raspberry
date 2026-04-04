import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_mobile/providers/auth_provider.dart';
import 'package:app_mobile/data/services/api_service.dart';
import 'package:app_mobile/presentation/screens/client/reservation/reservation_form_screen.dart';
import 'package:app_mobile/presentation/screens/client/parking/active_parking_screen.dart';
import 'package:app_mobile/presentation/screens/client/profile/profile_screen.dart';
import 'package:app_mobile/presentation/screens/client/settings/language_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _hasActiveParking = false;
  Map<String, dynamic>? _activeParking;
  List<dynamic> _placesParNiveau = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tous';
  late AnimationController _animationController;

  final List<String> _filters = ['Tous', 'VIP', 'Électrique', 'Handicapé'];

  final List<Widget> _screens = [
    const HomeContent(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _checkActiveParking(),
      _loadPlacesLibres(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _checkActiveParking() async {
    try {
      final response = await ApiService.get('/api/stationnement/actif');
      setState(() {
        _hasActiveParking = response['has_active'] ?? false;
        _activeParking = response['stationnement'];
      });
    } catch (e) {
      setState(() {
        _hasActiveParking = false;
        _activeParking = null;
      });
    }
  }

  Future<void> _loadPlacesLibres() async {
    try {
      final response = await ApiService.get('/api/parking/statut-par-niveau');
      setState(() {
        _placesParNiveau = response ?? [];
      });
    } catch (e) {
      setState(() {
        _placesParNiveau = [
          {'niveau': 0, 'libelle': 'Rez-de-chaussée', 'libres': 8, 'total': 12, 'type': 'standard'},
          {'niveau': 1, 'libelle': 'Étage 1', 'libres': 5, 'total': 12, 'type': 'standard'},
          {'niveau': 2, 'libelle': 'Étage 2', 'libres': 3, 'total': 12, 'type': 'VIP'},
        ];
      });
    }
  }

  void _updateFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Accueil'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
          ],
        ),
      ),
      floatingActionButton: _hasActiveParking
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveParkingScreen(
                      stationnement: _activeParking,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code, color: Colors.white),
              label: const Text('MON TICKET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFF1E3A5F),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReservationFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('RÉSERVER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFF1E3A5F),
            ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  static const Color primaryColor = Color(0xFF1E3A5F);
  
  final List<String> _filters = const ['Tous', 'VIP', 'Électrique', 'Handicapé'];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    final hasActiveParking = homeState?._hasActiveParking ?? false;
    final activeParking = homeState?._activeParking;
    final placesParNiveau = homeState?._placesParNiveau ?? [];
    final selectedFilter = homeState?._selectedFilter ?? 'Tous';
    final animationController = homeState?._animationController;

    return RefreshIndicator(
      onRefresh: () async {
        await homeState?._loadUserData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (animationController != null)
              FadeTransition(
                opacity: animationController.drive(
                  Tween(begin: 0.0, end: 1.0),
                ),
                child: Column(
                  children: [
                    _buildWelcomeBanner(authProvider),
                    const SizedBox(height: 24),
                    _buildFilters(homeState, selectedFilter),
                    const SizedBox(height: 20),
                    if (hasActiveParking && activeParking != null)
                      _buildParkedCard(activeParking, context)
                    else
                      _buildAvailableSpotsCard(placesParNiveau, selectedFilter),
                  ],
                ),
              )
            else
              Column(
                children: [
                  _buildWelcomeBanner(authProvider),
                  const SizedBox(height: 24),
                  _buildFilters(homeState, selectedFilter),
                  const SizedBox(height: 20),
                  if (hasActiveParking && activeParking != null)
                    _buildParkedCard(activeParking, context)
                  else
                    _buildAvailableSpotsCard(placesParNiveau, selectedFilter),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: primaryColor,
              child: Text(
                authProvider.user?.prenom?.isNotEmpty == true
                    ? authProvider.user!.prenom[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour ${authProvider.user?.prenom ?? "Visiteur"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Paris, 22°C',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.notifications_none, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Aucune alerte',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications, color: Colors.white, size: 20),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(_HomeScreenState? homeState, String selectedFilter) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = selectedFilter == filter;
          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              homeState?._updateFilter(filter);
            },
            backgroundColor: Colors.white,
            selectedColor: primaryColor.withOpacity(0.1),
            checkmarkColor: primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? primaryColor : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? primaryColor : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  Widget _buildParkedCard(Map<String, dynamic> parking, BuildContext context) {
    final int niveau = (parking['niveau'] ?? 1) as int;
    final int placeNumero = (parking['place_numero'] ?? 2) as int;
    final String plaque = parking['plaque'] ?? 'AB-123-CD';
    final String rfidTicket = parking['rfid_ticket'] ?? 'RFID001';
    final String dateEntree = parking['date_entree'] ?? DateTime.now().toString();
    
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF57A6A1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'STATIONNEMENT ACTIF',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildParkingInfo('NIVEAU', niveau == 0 ? 'RDC' : '$niveau', Icons.elevator),
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.grey.shade200,
                    ),
                    _buildParkingInfo('PLACE', '$placeNumero', Icons.local_parking),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    _buildDetailItem(Icons.directions_car, 'Plaque', plaque),
                    const SizedBox(height: 12),
                    _buildDetailItem(Icons.credit_card, 'Ticket RFID', rfidTicket),
                    const SizedBox(height: 12),
                    _buildDetailItem(Icons.access_time, 'Heure d\'entrée', _formatHeure(dateEntree)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActiveParkingScreen(stationnement: parking),
                ),
              );
            },
            icon: const Icon(Icons.qr_code, color: primaryColor),
            label: const Text('VOIR MON TICKET', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: primaryColor, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableSpotsCard(List<dynamic> places, String filter) {
    List<dynamic> filteredPlaces = places;
    if (filter != 'Tous') {
      filteredPlaces = places.where((place) {
        final type = place['type'] ?? 'standard';
        if (filter == 'VIP') return type == 'VIP';
        if (filter == 'Électrique') return type == 'electrique';
        if (filter == 'Handicapé') return type == 'handicape';
        return true;
      }).toList();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sélectionnez un étage pour voir les places disponibles',
                  style: TextStyle(color: primaryColor, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...filteredPlaces.map((niveau) => _buildNiveauCard(
          niveau['niveau'] ?? 0,
          niveau['libelle'] ?? (niveau['niveau'] == 0 ? 'Rez-de-chaussée' : 'Étage ${niveau['niveau']}'),
          niveau['libres'] ?? 0,
          niveau['total'] ?? 12,
          niveau['type'] ?? 'standard',
        )),
      ],
    );
  }

  Widget _buildNiveauCard(int niveau, String libelle, int libres, int total, String type) {
    double pourcentage = libres / total;
    Color color = niveau == 0 ? Colors.orange : (type == 'VIP' ? Colors.purple : Colors.blue);
    
    IconData typeIcon = Icons.local_parking;
    if (type == 'VIP') typeIcon = Icons.star;
    if (type == 'electrique') typeIcon = Icons.ev_station;
    if (type == 'handicape') typeIcon = Icons.accessible;
    
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(typeIcon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          libelle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (type != 'standard') ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  type,
                                  style: TextStyle(fontSize: 10, color: color),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              '$libres / $total places',
                              style: TextStyle(
                                fontSize: 12,
                                color: libres > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: libres > 0 ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      libres > 0 ? '$libres libres' : 'Complet',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (libres > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pourcentage,
                    backgroundColor: Colors.grey.shade200,
                    color: color,
                    minHeight: 6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  String _formatHeure(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month} - ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
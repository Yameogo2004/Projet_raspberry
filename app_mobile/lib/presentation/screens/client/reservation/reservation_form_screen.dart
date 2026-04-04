import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../../../data/services/api_service.dart';
import '../../../presentation/widgets/custom_button.dart';
import '../../../presentation/widgets/custom_text_field.dart';
import 'reservation_history_screen.dart';
import '../payment/payment_screen.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Informations personnelles
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  
  // Informations véhicule
  final _plaqueController = TextEditingController();
  final _modeleController = TextEditingController();
  final _chargeController = TextEditingController();
  
  // Réservation
  DateTime _dateDebut = DateTime.now().add(const Duration(hours: 1));
  DateTime _dateFin = DateTime.now().add(const Duration(hours: 3));
  double _chargeSupplementaire = 0;
  bool _isLoading = false;
  
  // Localisation
  Position? _currentPosition;
  double _distanceParking = 0;
  int _tempsTrajet = 0;
  bool _isLoadingLocation = false;
  
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Contrôleur pour le scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _prefillUserData();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _plaqueController.dispose();
    _modeleController.dispose();
    _chargeController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _prefillUserData() async {
    try {
      final response = await ApiService.get('/api/auth/me');
      if (response['user'] != null) {
        final user = response['user'];
        _nomController.text = user['nom'] ?? '';
        _prenomController.text = user['prenom'] ?? '';
        _emailController.text = user['email'] ?? '';
        _telephoneController.text = user['telephone'] ?? '';
      }
    } catch (e) {
      // Ignorer, l'utilisateur remplira manuellement
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false);
      return;
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }
    
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _isLoadingLocation = false;
    });
    
    _calculerDistanceEtTemps();
  }

  Future<void> _calculerDistanceEtTemps() async {
    if (_currentPosition == null) return;
    
    const parkingLat = 33.95;
    const parkingLng = -118.15;
    
    double distance = _calculerDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      parkingLat,
      parkingLng,
    );
    
    int temps = (distance / 40 * 60).round();
    
    setState(() {
      _distanceParking = distance;
      _tempsTrajet = temps;
    });
  }

  double _calculerDistance(double lat1, double lng1, double lat2, double lng2) {
    const double R = 6371;
    
    double radLat1 = lat1 * math.pi / 180;
    double radLat2 = lat2 * math.pi / 180;
    double radLng1 = lng1 * math.pi / 180;
    double radLng2 = lng2 * math.pi / 180;
    
    double dlat = radLat2 - radLat1;
    double dlng = radLng2 - radLng1;
    
    double a = math.sin(dlat / 2) * math.sin(dlat / 2) +
               math.cos(radLat1) * math.cos(radLat2) *
               math.sin(dlng / 2) * math.sin(dlng / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return R * c;
  }

  double _calculerMontant() {
    double dureeHeures = _dateFin.difference(_dateDebut).inHours.toDouble();
    double prixBase = dureeHeures * 2.50;
    double prixCharge = _chargeSupplementaire * 0.10;
    return prixBase + prixCharge;
  }

  Future<void> _creerReservation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final reservationData = {
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'email': _emailController.text.trim(),
        'telephone': _telephoneController.text.trim(),
        'plaque': _plaqueController.text.trim().toUpperCase(),
        'modele': _modeleController.text.trim(),
        'charge_supplementaire': _chargeSupplementaire,
        'date_debut': _dateDebut.toIso8601String(),
        'date_fin': _dateFin.toIso8601String(),
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
        'distance': _distanceParking,
        'temps_trajet': _tempsTrajet,
      };
      
      final response = await ApiService.post('/api/reservation', reservationData);

      if (mounted) {
        // ✅ NAVIGATION VERS L'ÉCRAN DE PAIEMENT
        final paymentResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              montant: _calculerMontant(),
              reservationId: response['reservation_id'],
              reservationCode: response['code_confirmation'],
            ),
          ),
        );
        
        // Si le paiement a réussi
        if (paymentResult == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Réservation confirmée et paiement effectué !'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context); // Retour à l'accueil
        } else {
          // Paiement annulé ou échoué
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Réservation créée mais paiement en attente.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('Réserver', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFF1E3A5F),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.edit_calendar), text: 'Nouvelle réservation'),
              Tab(icon: Icon(Icons.history), text: 'Historique'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildReservationForm(),
            ),
            const ReservationHistoryScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationForm() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationCard(),
            const SizedBox(height: 20),
            _buildSectionTitle('Informations personnelles', Icons.person_outline),
            const SizedBox(height: 12),
            _buildPersonalInfoForm(),
            const SizedBox(height: 20),
            _buildSectionTitle('Informations véhicule', Icons.directions_car_outlined),
            const SizedBox(height: 12),
            _buildVehicleInfoForm(),
            const SizedBox(height: 20),
            _buildSectionTitle('Date et heure', Icons.calendar_today),
            const SizedBox(height: 12),
            _buildDateTimePicker(),
            const SizedBox(height: 20),
            _buildSectionTitle('Charge supplémentaire', Icons.fitness_center),
            const SizedBox(height: 12),
            _buildChargeSlider(),
            const SizedBox(height: 20),
            _buildSummaryCard(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _creerReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'CONFIRMER LA RÉSERVATION',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1E3A5F)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A5F),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on, color: Color(0xFF1E3A5F), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Distance du parking', style: TextStyle(fontSize: 12, color: Colors.grey)),
                if (_isLoadingLocation)
                  const SizedBox(height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                else
                  Text(
                    '${_distanceParking.toStringAsFixed(1)} km • ${_tempsTrajet} min',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          const Icon(Icons.directions_car, color: Color(0xFF1E3A5F)),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _nomController,
                  label: 'Nom',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => value == null || value.isEmpty ? 'Champs requis' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _prenomController,
                  label: 'Prénom',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => value == null || value.isEmpty ? 'Champs requis' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || value.isEmpty ? 'Champs requis' : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _telephoneController,
            label: 'Téléphone',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.isEmpty ? 'Champs requis' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: _plaqueController,
            label: 'Plaque d\'immatriculation',
            prefixIcon: Icons.badge,
            textCapitalization: TextCapitalization.characters,
            validator: (value) => value == null || value.isEmpty ? 'Champs requis' : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _modeleController,
            label: 'Modèle du véhicule',
            prefixIcon: Icons.directions_car_outlined,
            validator: (value) => value == null || value.isEmpty ? 'Champs requis' : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _chargeController,
            label: 'Charge supplémentaire (kg)',
            prefixIcon: Icons.fitness_center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _chargeSupplementaire = double.tryParse(value) ?? 0;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Color(0xFF1E3A5F)),
            title: const Text('Début'),
            subtitle: Text(DateFormat('dd/MM/yyyy à HH:mm').format(_dateDebut)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dateDebut,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null && mounted) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_dateDebut),
                );
                if (time != null && mounted) {
                  setState(() {
                    _dateDebut = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                    if (_dateFin.isBefore(_dateDebut)) {
                      _dateFin = _dateDebut.add(const Duration(hours: 2));
                    }
                  });
                  _calculerDistanceEtTemps();
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Color(0xFF1E3A5F)),
            title: const Text('Fin'),
            subtitle: Text(DateFormat('dd/MM/yyyy à HH:mm').format(_dateFin)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dateFin,
                firstDate: _dateDebut,
                lastDate: _dateDebut.add(const Duration(days: 7)),
              );
              if (date != null && mounted) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_dateFin),
                );
                if (time != null && mounted) {
                  setState(() {
                    _dateFin = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChargeSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Charge supplémentaire', style: TextStyle(fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_chargeSupplementaire.toStringAsFixed(0)} kg',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _chargeSupplementaire,
            min: 0,
            max: 500,
            divisions: 10,
            label: '${_chargeSupplementaire.toStringAsFixed(0)} kg',
            onChanged: (value) {
              setState(() {
                _chargeSupplementaire = value;
                _chargeController.text = value.toStringAsFixed(0);
              });
            },
            activeColor: const Color(0xFF1E3A5F),
          ),
          Text(
            'Frais supplémentaire: +${(_chargeSupplementaire * 0.10).toStringAsFixed(2)} DH',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    double duree = _dateFin.difference(_dateDebut).inHours.toDouble();
    double montantBase = duree * 2.50;
    double montantCharge = _chargeSupplementaire * 0.10;
    double montantTotal = montantBase + montantCharge;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E3A5F), const Color(0xFF2E5A7F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RÉCAPITULATIF', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 12),
          _buildSummaryRow('Durée', '${duree.toStringAsFixed(0)}h', Colors.white),
          const SizedBox(height: 8),
          _buildSummaryRow('Tarif horaire', '2,50 DH/h', Colors.white),
          const SizedBox(height: 8),
          _buildSummaryRow('Montant base', '${montantBase.toStringAsFixed(2)} DH', Colors.white),
          if (_chargeSupplementaire > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Charge supp.', '+ ${montantCharge.toStringAsFixed(2)} DH', Colors.white70),
          ],
          const Divider(color: Colors.white30, height: 16),
          _buildSummaryRow('TOTAL', '${montantTotal.toStringAsFixed(2)} DH', Colors.white, isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: color, fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

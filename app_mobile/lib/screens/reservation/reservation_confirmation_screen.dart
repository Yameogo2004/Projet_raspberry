import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Réservation
  int? _selectedVehiculeId;
  DateTime _dateDebut = DateTime.now().add(const Duration(hours: 1));
  DateTime _dateFin = DateTime.now().add(const Duration(hours: 3));
  double _charge = 200;
  
  // Véhicule (modèle + charge)
  final _modeleController = TextEditingController();
  final _chargeController = TextEditingController();
  bool _utiliserVehiculeExistant = true;
  
  // Localisation
  Position? _currentPosition;
  double _distanceParking = 0;
  int _tempsTrajet = 0;
  bool _isLoadingLocation = false;
  
  bool _isLoading = false;
  List<dynamic> _vehicules = [];

  @override
  void initState() {
    super.initState();
    _chargerVehicules();
    _getCurrentLocation();
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
    
    // Coordonnées du parking (à remplacer par les vraies)
    const parkingLat = 33.95;
    const parkingLng = -118.15;
    
    double distance = _calculerDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      parkingLat,
      parkingLng,
    );
    
    int temps = (distance / 40 * 60).round(); // 40 km/h moyenne
    
    setState(() {
      _distanceParking = distance;
      _tempsTrajet = temps;
    });
  }

  // ========== MÉTHODE DE CALCUL DE DISTANCE CORRIGÉE ==========
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

  Future<void> _chargerVehicules() async {
    try {
      final response = await ApiService.get('/api/vehicules');
      setState(() {
        _vehicules = response['vehicules'] ?? [];
      });
    } catch (e) {
      // Ignorer
    }
  }

  Future<void> _prolongerReservation() async {
    final duree = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prolonger la réservation'),
        content: const Text('Combien d\'heures supplémentaires ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 1),
            child: const Text('+1h'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 2),
            child: const Text('+2h'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 3),
            child: const Text('+3h'),
          ),
        ],
      ),
    );
    
    if (duree != null && mounted) {
      setState(() {
        _dateFin = _dateFin.add(Duration(hours: duree));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Réservation prolongée de $duree heure(s)')),
      );
    }
  }

  Future<void> _creerReservation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final reservationData = {
        'date_debut': _dateDebut.toIso8601String(),
        'date_fin': _dateFin.toIso8601String(),
        'charge': _charge,
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
        'distance': _distanceParking,
        'temps_trajet': _tempsTrajet,
      };
      
      if (_utiliserVehiculeExistant && _selectedVehiculeId != null) {
        reservationData['vehicule_id'] = _selectedVehiculeId;
      } else {
        reservationData['nouveau_vehicule'] = {
          'modele': _modeleController.text,
          'charge': double.parse(_chargeController.text),
        };
      }
      
      final response = await ApiService.post('/api/reservation', reservationData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation créée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle réservation'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _prolongerReservation,
            icon: const Icon(Icons.timer),
            tooltip: 'Prolonger',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOCALISATION
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Distance du parking',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if (_isLoadingLocation)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Text(
                              '${_distanceParking.toStringAsFixed(1)} km • ${_tempsTrajet} min',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.directions_car, color: Colors.blue),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // DATE ET HEURE
              const Text('Date et heure', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDateTimePicker(),
              const SizedBox(height: 24),
              
              // VÉHICULE
              const Text('Véhicule', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Véhicule existant'),
                      value: true,
                      groupValue: _utiliserVehiculeExistant,
                      onChanged: (value) {
                        setState(() => _utiliserVehiculeExistant = value!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Nouveau véhicule'),
                      value: false,
                      groupValue: _utiliserVehiculeExistant,
                      onChanged: (value) {
                        setState(() => _utiliserVehiculeExistant = value!);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              
              if (_utiliserVehiculeExistant)
                DropdownButtonFormField<int>(
                  value: _selectedVehiculeId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Sélectionnez votre véhicule',
                  ),
                  items: _vehicules.map<DropdownMenuItem<int>>((v) {
                    return DropdownMenuItem<int>(
                      value: v['id'],
                      child: Text('${v['plaque']} - ${v['modele']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedVehiculeId = value);
                  },
                  validator: (value) {
                    if (value == null) return 'Veuillez sélectionner un véhicule';
                    return null;
                  },
                )
              else
                Column(
                  children: [
                    CustomTextField(
                      controller: _modeleController,
                      label: 'Modèle du véhicule',
                      prefixIcon: Icons.directions_car,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le modèle';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _chargeController,
                      label: 'Charge (kg)',
                      prefixIcon: Icons.fitness_center,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer la charge';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              
              const SizedBox(height: 24),
              
              // CHARGE (personnes + bagages)
              const Text('Charge supplémentaire', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _charge,
                      min: 0,
                      max: 600,
                      divisions: 12,
                      label: '${_charge.toInt()} kg',
                      onChanged: (value) {
                        setState(() => _charge = value);
                      },
                    ),
                  ),
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_charge.toInt()} kg',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // BOUTON RÉSERVER
              CustomButton(
                text: 'Réserver maintenant',
                onPressed: _creerReservation,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Début'),
          subtitle: Text(DateFormat('dd/MM/yyyy à HH:mm').format(_dateDebut)),
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
                  _dateDebut = DateTime(
                    date.year, date.month, date.day,
                    time.hour, time.minute,
                  );
                  if (_dateFin.isBefore(_dateDebut)) {
                    _dateFin = _dateDebut.add(const Duration(hours: 2));
                  }
                });
                _calculerDistanceEtTemps();
              }
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Fin'),
          subtitle: Text(DateFormat('dd/MM/yyyy à HH:mm').format(_dateFin)),
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
                  _dateFin = DateTime(
                    date.year, date.month, date.day,
                    time.hour, time.minute,
                  );
                });
              }
            }
          },
        ),
      ],
    );
  }
}
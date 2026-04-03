import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  int? _selectedVehiculeId;
  DateTime _dateDebut = DateTime.now().add(const Duration(hours: 1));
  DateTime _dateFin = DateTime.now().add(const Duration(hours: 3));
  double _charge = 200;
  bool _isLoading = false;
  
  List<dynamic> _vehicules = [];

  @override
  void initState() {
    super.initState();
    _chargerVehicules();
  }

  Future<void> _chargerVehicules() async {
    try {
      final response = await ApiService.get('/api/vehicules');
      setState(() {
        _vehicules = response['vehicules'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _creerReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehiculeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un véhicule')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post('/api/reservation', {
        'vehicule_id': _selectedVehiculeId,
        'date_debut': _dateDebut.toIso8601String(),
        'date_fin': _dateFin.toIso8601String(),
        'charge': _charge,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Réservation créée ! ${response['message']}'),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélection véhicule
              const Text('Véhicule', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedVehiculeId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Sélectionnez votre véhicule',
                ),
                items: _vehicules.map<DropdownMenuItem<int>>((v) {
                  return DropdownMenuItem<int>(
                    value: v['id'] as int,
                    child: Text('${v['plaque']} - ${v['modele']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVehiculeId = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Veuillez sélectionner un véhicule';
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Date et heure
              const Text('Date et heure', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Date début
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
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_dateDebut),
                    );
                    if (time != null) {
                      setState(() {
                        _dateDebut = DateTime(
                          date.year, date.month, date.day,
                          time.hour, time.minute,
                        );
                        if (_dateFin.isBefore(_dateDebut)) {
                          _dateFin = _dateDebut.add(const Duration(hours: 2));
                        }
                      });
                    }
                  }
                },
              ),
              
              // Date fin
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
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_dateFin),
                    );
                    if (time != null) {
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
              
              const SizedBox(height: 24),
              
              // Charge
              const Text('Charge (personnes + bagages)', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        setState(() {
                          _charge = value;
                        });
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
}
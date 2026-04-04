import 'package:flutter/material.dart';
import '../../../../data/services/api_service.dart';
import '../../../widgets/buttons/custom_button.dart';

class LocateVehicleScreen extends StatefulWidget {
  const LocateVehicleScreen({super.key});

  @override
  State<LocateVehicleScreen> createState() => _LocateVehicleScreenState();
}

class _LocateVehicleScreenState extends State<LocateVehicleScreen> {
  final _plaqueController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  Future<void> _localiser() async {
    if (_plaqueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une plaque')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final response = await ApiService.get(
        '/api/vehicule/${_plaqueController.text.trim()}/localisation'
      );
      setState(() {
        _result = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localiser mon véhicule'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.location_searching,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Entrez votre plaque d\'immatriculation',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _plaqueController,
              decoration: InputDecoration(
                labelText: 'Plaque',
                prefixIcon: const Icon(Icons.directions_car),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Localiser',
              onPressed: _localiser,
              isLoading: _isLoading,
            ),
            
            if (_result != null) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, size: 50, color: Colors.green),
                    const SizedBox(height: 10),
                    Text(
                      _result!['message'] ?? 'Véhicule trouvé',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_result!['trouve'] == true) ...[
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Niveau ${_result!['niveau']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Place ${_result!['place']}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
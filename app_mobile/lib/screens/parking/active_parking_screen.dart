import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/api_service.dart';

class ActiveParkingScreen extends StatefulWidget {
  final Map<String, dynamic>? stationnement;

  const ActiveParkingScreen({super.key, this.stationnement});

  @override
  State<ActiveParkingScreen> createState() => _ActiveParkingScreenState();
}

class _ActiveParkingScreenState extends State<ActiveParkingScreen> {
  Map<String, dynamic>? _stationnement;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerStationnement();
  }

  Future<void> _chargerStationnement() async {
    if (widget.stationnement != null) {
      setState(() {
        _stationnement = widget.stationnement;
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService.get('/api/stationnement/actif');
      setState(() {
        _stationnement = response['stationnement'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon stationnement'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stationnement == null
              ? const Center(child: Text('Aucun stationnement actif'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // QR Code
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: _stationnement!['qr_code'] ?? 'N/A',
                          version: QrVersions.auto,
                          size: 200,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Informations
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.local_parking,
                                'Emplacement',
                                _stationnement!['emplacement'] ?? 'N/A',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.qr_code,
                                'Code QR',
                                _stationnement!['qr_code'] ?? 'N/A',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.credit_card,
                                'Ticket RFID',
                                _stationnement!['rfid_ticket'] ?? 'N/A',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.directions_car,
                                'Plaque',
                                _stationnement!['plaque'] ?? 'N/A',
                              ),
                              const Divider(),
                              _buildInfoRow(
                                Icons.access_time,
                                'Heure d\'entrée',
                                _stationnement!['date_entree'] ?? 'N/A',
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Note pour la sortie
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Présentez ce QR code ou le ticket RFID à la sortie pour récupérer votre véhicule.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Bouton d'aide
                      OutlinedButton.icon(
                        onPressed: () {
                          _showHelpDialog(context);
                        },
                        icon: const Icon(Icons.help_outline),
                        label: const Text('Besoin d\'aide ?'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600, 
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comment récupérer mon véhicule ?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Présentez ce QR code au terminal de sortie'),
            SizedBox(height: 8),
            Text('2. Ou utilisez votre ticket RFID'),
            SizedBox(height: 8),
            Text('3. Attendez que l\'ascenseur amène votre véhicule'),
            SizedBox(height: 8),
            Text('4. Récupérez votre véhicule à la sortie'),
            SizedBox(height: 16),
            Text(
              '⚠️ N\'oubliez pas votre ticket !',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
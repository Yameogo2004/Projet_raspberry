import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/reservation_history.dart';

class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  State<ReservationHistoryScreen> createState() => _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  List<ReservationHistory> _reservations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get('/api/reservations/historique');
      setState(() {
        _reservations = (response['reservations'] as List)
            .map((json) => ReservationHistory.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _reservations = _getMockReservations();
        _isLoading = false;
      });
    }
  }

  List<ReservationHistory> _getMockReservations() {
    return [
      ReservationHistory(
        id: 1,
        codeConfirmation: 'RES1001',
        dateReservation: DateTime.now().subtract(const Duration(days: 5)),
        dateDebut: DateTime.now().subtract(const Duration(days: 3)),
        dateFin: DateTime.now().subtract(const Duration(days: 3)).add(const Duration(hours: 4)),
        plaque: 'AB-123-CD',
        modele: 'Tesla Model 3',
        charge: 200,
        montant: 12.50,
        statut: 'confirmée',
        emplacement: 'Niveau 1 - Box A2',
      ),
      ReservationHistory(
        id: 2,
        codeConfirmation: 'RES1002',
        dateReservation: DateTime.now().subtract(const Duration(days: 10)),
        dateDebut: DateTime.now().subtract(const Duration(days: 8)),
        dateFin: DateTime.now().subtract(const Duration(days: 8)).add(const Duration(hours: 2)),
        plaque: 'EF-456-GH',
        modele: 'Renault Zoe',
        charge: 100,
        montant: 6.50,
        statut: 'terminée',
        emplacement: 'Niveau 0 - Box B3',
      ),
      ReservationHistory(
        id: 3,
        codeConfirmation: 'RES1003',
        dateReservation: DateTime.now().subtract(const Duration(days: 1)),
        dateDebut: DateTime.now().add(const Duration(hours: 2)),
        dateFin: DateTime.now().add(const Duration(hours: 5)),
        plaque: 'XY-789-ZW',
        modele: 'Peugeot 208',
        charge: 150,
        montant: 7.50,
        statut: 'confirmée',
        emplacement: 'Non assigné',
      ),
    ];
  }

  Future<void> _annulerReservation(ReservationHistory reservation) async {
    // Demander confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Annuler la réservation'),
        content: Text(
          'Voulez-vous vraiment annuler la réservation ${reservation.codeConfirmation} ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NON'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('OUI, ANNULER'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post('/api/reservation/${reservation.id}/annuler', {});
      
      if (response['success'] == true) {
        // Mettre à jour la liste localement
        setState(() {
          final index = _reservations.indexWhere((r) => r.id == reservation.id);
          if (index != -1) {
            _reservations[index] = ReservationHistory(
              id: reservation.id,
              codeConfirmation: reservation.codeConfirmation,
              dateReservation: reservation.dateReservation,
              dateDebut: reservation.dateDebut,
              dateFin: reservation.dateFin,
              plaque: reservation.plaque,
              modele: reservation.modele,
              charge: reservation.charge,
              montant: reservation.montant,
              statut: 'annulée',
              emplacement: reservation.emplacement,
            );
          }
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation annulée avec succès'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Erreur lors de l\'annulation');
      }
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = _reservations[index];
                      return _buildHistoryCard(reservation);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aucune réservation',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos réservations apparaîtront ici',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ReservationHistory reservation) {
    Color statusColor;
    String statusText;
    
    switch (reservation.statut) {
      case 'confirmée':
        statusColor = Colors.green;
        statusText = 'Confirmée';
        break;
      case 'terminée':
        statusColor = Colors.blue;
        statusText = 'Terminée';
        break;
      case 'annulée':
        statusColor = Colors.red;
        statusText = 'Annulée';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'En attente';
    }
    
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showReservationDetails(reservation);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reservation.codeConfirmation,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('${reservation.plaque} - ${reservation.modele}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(DateFormat('dd/MM/yyyy').format(reservation.dateDebut)),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('${reservation.dateDebut.hour}h - ${reservation.dateFin.hour}h'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${reservation.montant.toStringAsFixed(2)} DH',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A5F)),
                    ),
                    if (reservation.statut == 'confirmée')
                      TextButton.icon(
                        onPressed: () => _annulerReservation(reservation),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Annuler'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      )
                    else
                      const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReservationDetails(ReservationHistory reservation) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Détails de la réservation',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Code', reservation.codeConfirmation),
            _buildDetailRow('Date réservation', DateFormat('dd/MM/yyyy à HH:mm').format(reservation.dateReservation)),
            _buildDetailRow('Période', '${DateFormat('dd/MM/yyyy HH:mm').format(reservation.dateDebut)} → ${DateFormat('HH:mm').format(reservation.dateFin)}'),
            _buildDetailRow('Véhicule', '${reservation.plaque} - ${reservation.modele}'),
            _buildDetailRow('Charge', '${reservation.charge} kg'),
            _buildDetailRow('Emplacement', reservation.emplacement),
            const Divider(height: 24),
            _buildDetailRow('Montant total', '${reservation.montant.toStringAsFixed(2)} DH', isBold: true),
            const SizedBox(height: 20),
            if (reservation.statut == 'confirmée')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _annulerReservation(reservation);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('ANNULER LA RÉSERVATION'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('FERMER'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? const Color(0xFF1E3A5F) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

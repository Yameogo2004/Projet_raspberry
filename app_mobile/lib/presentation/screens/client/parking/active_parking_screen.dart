import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import '../../../../data/services/api_service.dart';


class ActiveParkingScreen extends StatefulWidget {
  final Map<String, dynamic>? stationnement;

  const ActiveParkingScreen({super.key, this.stationnement});

  @override
  State<ActiveParkingScreen> createState() => _ActiveParkingScreenState();
}

class _ActiveParkingScreenState extends State<ActiveParkingScreen> {
  Map<String, dynamic>? _stationnement;
  bool _isLoading = true;
  bool _showFullQr = false;
  Timer? _timer;
  Duration _duree = Duration.zero;
  double _prixParHeure = 2.50;

  static const Color primaryColor = Color(0xFF1E3A5F);
  static const Color secondaryColor = Color(0xFF2E5A7F);
  static const Color bgColor = Color(0xFFF2F4F8);
  static const Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _chargerStationnement();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _duree = _duree + const Duration(seconds: 1);
        });
      }
    });
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

  String _formatDuree(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  double _calculerMontant() {
    double heures = _duree.inMinutes / 60;
    return heures * _prixParHeure;
  }

  String _getQrData() {
    final String plaque = _stationnement!['plaque'] ?? 'AB-123-CD';
    final int niveau = (_stationnement!['niveau'] ?? 1) as int;
    final String box = _stationnement!['box'] ?? 'A2';
    return 'PARKING:$plaque:$niveau:$box:${DateTime.now().millisecondsSinceEpoch}';
  }

  void _showExtendDialog() {
    int selectedHours = 0;
    int selectedMinutes = 0;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBottom) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'PROLONGER LE STATIONNEMENT',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Temps actuel', style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        _formatDuree(_duree),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                const Text('Ajouter du temps :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                const Text('Heures', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQuickExtendButton(context, 1, 'h', () {
                      selectedHours += 1;
                      setStateBottom(() {});
                    }),
                    const SizedBox(width: 12),
                    _buildQuickExtendButton(context, 2, 'h', () {
                      selectedHours += 2;
                      setStateBottom(() {});
                    }),
                    const SizedBox(width: 12),
                    _buildQuickExtendButton(context, 3, 'h', () {
                      selectedHours += 3;
                      setStateBottom(() {});
                    }),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Text('Minutes', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildQuickExtendButton(context, 15, 'min', () {
                      selectedMinutes += 15;
                      setStateBottom(() {});
                    }),
                    const SizedBox(width: 12),
                    _buildQuickExtendButton(context, 30, 'min', () {
                      selectedMinutes += 30;
                      setStateBottom(() {});
                    }),
                    const SizedBox(width: 12),
                    _buildQuickExtendButton(context, 45, 'min', () {
                      selectedMinutes += 45;
                      setStateBottom(() {});
                    }),
                  ],
                ),
                
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('Personnalisé :', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedHours,
                          hint: const Text('Heures'),
                          isExpanded: true,
                          items: List.generate(12, (i) => i).map((h) {
                            return DropdownMenuItem(value: h, child: Text('$h h'));
                          }).toList(),
                          onChanged: (value) {
                            setStateBottom(() {
                              selectedHours = value ?? 0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedMinutes,
                          hint: const Text('Minutes'),
                          isExpanded: true,
                          items: [0, 15, 30, 45].map((m) {
                            return DropdownMenuItem(value: m, child: Text('$m min'));
                          }).toList(),
                          onChanged: (value) {
                            setStateBottom(() {
                              selectedMinutes = value ?? 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '+${selectedHours}h${selectedMinutes > 0 ? ' $selectedMinutes min' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '+${((selectedHours * 60 + selectedMinutes) / 60 * _prixParHeure).toStringAsFixed(2)} DH',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedHours > 0 || selectedMinutes > 0) {
                        setState(() {
                          _duree = _duree + Duration(hours: selectedHours, minutes: selectedMinutes);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ +${selectedHours}h${selectedMinutes > 0 ? ' $selectedMinutes min' : ''}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('VALIDER', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickExtendButton(BuildContext context, int value, String unit, VoidCallback onAdd) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onAdd,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          foregroundColor: primaryColor,
        ),
        child: Text('+$value $unit', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showLocationDialog() {
    final int niveau = (_stationnement!['niveau'] ?? 1) as int;
    final String box = _stationnement!['box'] ?? 'A2';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: primaryColor, size: 48),
              const SizedBox(height: 16),
              Text('Niveau ${niveau == 0 ? 'RDC' : niveau}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Box $box', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('FERMER'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month} ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Stationnement', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stationnement == null
              ? const Center(child: Text('Aucun stationnement actif'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildQrCard(),
                      const SizedBox(height: 16),
                      _buildTimerCard(),
                      const SizedBox(height: 16),
                      _buildLocationCard(),
                      const SizedBox(height: 16),
                      _buildParkingMap(),
                      const SizedBox(height: 16),
                      _buildVehicleCard(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                      const SizedBox(height: 16),
                      _buildInfoMessage(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildQrCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
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
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'CODE DE SORTIE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showFullQr = !_showFullQr;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: QrImageView(
                  data: _getQrData(),
                  version: QrVersions.auto,
                  size: _showFullQr ? 200 : 120,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TEMPS STATIONNÉ',
                style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDuree(_duree),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.white30,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'MONTANT ESTIMÉ',
                style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              Text(
                '${_calculerMontant().toStringAsFixed(2)} DH',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_prixParHeure.toStringAsFixed(2)} DH/h',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final int niveau = (_stationnement!['niveau'] ?? 1) as int;
    final String box = _stationnement!['box'] ?? 'A2';
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
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
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'EMPLACEMENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLocationItem('NIVEAU', niveau == 0 ? 'RDC' : '$niveau', Icons.elevator),
                Container(height: 50, width: 1, color: Colors.grey.shade200),
                _buildLocationItem('BOX', box, Icons.location_on),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(String label, String value, IconData icon) {
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

  Widget _buildParkingMap() {
    final String box = _stationnement!['box'] ?? 'A2';
    final int niveau = (_stationnement!['niveau'] ?? 1) as int;
    String boxLetter = box.length > 0 ? box[0] : 'A';
    int boxNumber = box.length > 1 ? int.tryParse(box.substring(1)) ?? 2 : 2;
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
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
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.map, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'PLAN DU PARKING',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(Colors.green.shade100, 'Libre'),
                    const SizedBox(width: 16),
                    _buildLegendItem(Colors.red.shade100, 'Occupé'),
                    const SizedBox(width: 16),
                    _buildLegendItem(primaryColor, 'Votre place'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Niveau ${niveau == 0 ? 'RDC' : niveau}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    _buildParkingRow('A', boxLetter, boxNumber, 1, 4),
                    const SizedBox(height: 8),
                    _buildParkingRow('B', boxLetter, boxNumber, 1, 4),
                    const SizedBox(height: 8),
                    _buildParkingRow('C', boxLetter, boxNumber, 1, 4),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '🚗 Votre place : Box $box',
                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildParkingRow(String rowLetter, String myBoxLetter, int myBoxNumber, int start, int end) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(end - start + 1, (index) {
        int num = start + index;
        String boxId = '$rowLetter$num';
        bool isMyPlace = (rowLetter == myBoxLetter && num == myBoxNumber);
        bool isOccupied = !isMyPlace && (num % 2 == 0);
        
        return Container(
          margin: const EdgeInsets.all(4),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isMyPlace ? primaryColor : (isOccupied ? Colors.red.shade100 : Colors.green.shade100),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isMyPlace ? primaryColor : Colors.grey.shade300,
              width: isMyPlace ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isMyPlace ? Icons.directions_car : Icons.local_parking,
                size: 20,
                color: isMyPlace ? Colors.white : (isOccupied ? Colors.red : Colors.green),
              ),
              Text(
                boxId,
                style: TextStyle(
                  fontSize: 10,
                  color: isMyPlace ? Colors.white : Colors.grey.shade600,
                  fontWeight: isMyPlace ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildVehicleCard() {
    final String plaque = _stationnement!['plaque'] ?? 'AB-123-CD';
    final String rfidTicket = _stationnement!['rfid_ticket'] ?? 'RFID001';
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
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
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.directions_car, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'VÉHICULE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.badge, 'Plaque', plaque),
                const Divider(height: 24, thickness: 0.5),
                _buildInfoRow(Icons.credit_card, 'Ticket RFID', rfidTicket),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showExtendDialog,
            icon: const Icon(Icons.timer_outlined),
            label: const Text('PROLONGER'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: primaryColor, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showLocationDialog,
            icon: const Icon(Icons.navigation),
            label: const Text('LOCALISER'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
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

  Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primaryColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Présentez votre QR code ou ticket RFID au terminal de sortie.',
              style: TextStyle(color: primaryColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
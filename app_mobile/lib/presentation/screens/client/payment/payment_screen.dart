import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/payment_method.dart';
import '../../../data/services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final double montant;
  final int reservationId;
  final String reservationCode;

  const PaymentScreen({
    super.key,
    required this.montant,
    required this.reservationId,
    required this.reservationCode,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethodType _selectedMethod = PaymentMethodType.card;
  bool _isLoading = false;
  bool _paymentSuccess = false;

  // Contrôleurs pour carte bancaire
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // Contrôleurs pour App Money
  String _selectedAppMoneyProvider = 'Orange Money';
  final _phoneNumberController = TextEditingController();

  final List<String> _appMoneyProviders = [
    'Orange Money',
    'Wave',
    'Free Money',
    'Express Union',
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    String cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length > 16) cleaned = cleaned.substring(0, 16);
    List<String> groups = [];
    for (int i = 0; i < cleaned.length; i += 4) {
      if (i + 4 <= cleaned.length) {
        groups.add(cleaned.substring(i, i + 4));
      } else {
        groups.add(cleaned.substring(i));
      }
    }
    return groups.join(' ');
  }

  String _formatExpiry(String value) {
    String cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length > 4) cleaned = cleaned.substring(0, 4);
    if (cleaned.length >= 3) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }
    return cleaned;
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> paymentData = {
        'montant': widget.montant,
        'reservation_id': widget.reservationId,
        'reservation_code': widget.reservationCode,
        'payment_method': _selectedMethod.toString(),
      };

      if (_selectedMethod == PaymentMethodType.card) {
        if (_cardNumberController.text.replaceAll(' ', '').length < 16) {
          throw Exception('Numéro de carte invalide');
        }
        if (_expiryController.text.length < 5) {
          throw Exception('Date d\'expiration invalide');
        }
        if (_cvvController.text.length < 3) {
          throw Exception('CVV invalide');
        }
        if (_cardHolderController.text.isEmpty) {
          throw Exception('Nom du titulaire requis');
        }
        
        paymentData['card_details'] = {
          'card_number': _cardNumberController.text.replaceAll(' ', ''),
          'expiry_date': _expiryController.text,
          'cvv': _cvvController.text,
          'card_holder': _cardHolderController.text,
        };
      } else if (_selectedMethod == PaymentMethodType.appMoney) {
        if (_phoneNumberController.text.length < 9) {
          throw Exception('Numéro de téléphone invalide');
        }
        paymentData['app_money_details'] = {
          'provider': _selectedAppMoneyProvider,
          'phone_number': _phoneNumberController.text,
        };
      } else if (_selectedMethod == PaymentMethodType.cash) {
        paymentData['cash_details'] = {
          'message': 'Paiement à effectuer à la sortie'
        };
      }

      final response = await ApiService.post('/api/payment/process', paymentData);

      if (response['success'] == true) {
        setState(() {
          _paymentSuccess = true;
          _isLoading = false;
        });
        
        _showSuccessDialog();
      } else {
        throw Exception(response['message'] ?? 'Paiement échoué');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text('Paiement réussi !'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Montant payé : ${widget.montant.toStringAsFixed(2)} DH'),
            const SizedBox(height: 8),
            Text('Code réservation : ${widget.reservationCode}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Un reçu vous a été envoyé par email.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Erreur de paiement'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Paiement', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _paymentSuccess
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 20),
                  const Text(
                    'Paiement effectué avec succès !',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Montant : ${widget.montant.toStringAsFixed(2)} DH',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A5F),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text('Terminer'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Montant à payer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1E3A5F), const Color(0xFF2E5A7F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MONTANT À PAYER',
                          style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.montant.toStringAsFixed(2)} DH',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code réservation : ${widget.reservationCode}',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Méthodes de paiement
                  const Text(
                    'Méthode de paiement',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...PaymentMethod.getMethods().map((method) => _buildPaymentMethodTile(method)),
                  const SizedBox(height: 24),

                  // Formulaire selon méthode sélectionnée
                  if (_selectedMethod == PaymentMethodType.card) _buildCardForm(),
                  if (_selectedMethod == PaymentMethodType.appMoney) _buildAppMoneyForm(),
                  if (_selectedMethod == PaymentMethodType.cash) _buildCashForm(),

                  const SizedBox(height: 30),
                  // Bouton payer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processPayment,
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
                              'PAYER',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    bool isSelected = _selectedMethod == method.type;
    Color color = Color(int.parse('0xFF${method.color.substring(1)}'));

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method.type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(method.icon, color: isSelected ? color : Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Numéro de carte
          TextFormField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Numéro de carte',
              hintText: '1234 5678 9012 3456',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
            maxLength: 19,
            onChanged: (value) {
              String formatted = _formatCardNumber(value);
              if (formatted != _cardNumberController.text) {
                _cardNumberController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: InputDecoration(
                    labelText: 'MM/AA',
                    hintText: '12/25',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  onChanged: (value) {
                    String formatted = _formatExpiry(value);
                    if (formatted != _expiryController.text) {
                      _expiryController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardHolderController,
            decoration: InputDecoration(
              labelText: 'Titulaire de la carte',
              hintText: 'Jean DUPONT',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppMoneyForm() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          DropdownButtonFormField<String>(
            value: _selectedAppMoneyProvider,
            decoration: InputDecoration(
              labelText: 'Opérateur',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _appMoneyProviders.map((provider) {
              return DropdownMenuItem(
                value: provider,
                child: Text(provider),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAppMoneyProvider = value!;
              });
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneNumberController,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: '77 123 45 67',
              prefixIcon: const Icon(Icons.phone_android),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vous allez recevoir une notification sur votre téléphone pour confirmer le paiement.',
                    style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashForm() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous pourrez payer en espèces au terminal de sortie.\nUn ticket vous sera remis.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

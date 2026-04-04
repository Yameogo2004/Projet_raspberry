class Payment {
  final int id;
  final double montant;
  final DateTime datePaiement;
  final String mode;
  final String statut;
  final String transactionId;
  final int reservationId;
  final bool factureGeneree;

  Payment({
    required this.id,
    required this.montant,
    required this.datePaiement,
    required this.mode,
    required this.statut,
    required this.transactionId,
    required this.reservationId,
    required this.factureGeneree,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      montant: json['montant'].toDouble(),
      datePaiement: DateTime.parse(json['date_paiement']),
      mode: json['mode'],
      statut: json['statut'],
      transactionId: json['transaction_id'],
      reservationId: json['reservation_id'],
      factureGeneree: json['facture_generee'] ?? false,
    );
  }
}

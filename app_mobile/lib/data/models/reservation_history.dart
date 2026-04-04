class ReservationHistory {
  final int id;
  final String codeConfirmation;
  final DateTime dateReservation;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String plaque;
  final String modele;
  final double charge;
  final double montant;
  final String statut;
  final String emplacement;

  ReservationHistory({
    required this.id,
    required this.codeConfirmation,
    required this.dateReservation,
    required this.dateDebut,
    required this.dateFin,
    required this.plaque,
    required this.modele,
    required this.charge,
    required this.montant,
    required this.statut,
    required this.emplacement,
  });

  factory ReservationHistory.fromJson(Map<String, dynamic> json) {
    return ReservationHistory(
      id: json['id'],
      codeConfirmation: json['code_confirmation'],
      dateReservation: DateTime.parse(json['date_reservation']),
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      plaque: json['plaque'],
      modele: json['modele'],
      charge: json['charge'].toDouble(),
      montant: json['montant'].toDouble(),
      statut: json['statut'],
      emplacement: json['emplacement'] ?? 'Non assigné',
    );
  }
}

class Reservation {
  final int id;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String statut;
  final double poidsEstime;
  final double montantEstime;
  final String? typePlace;
  final int? emplacementId;
  final String codeConfirmation;

  Reservation({
    required this.id,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.poidsEstime,
    required this.montantEstime,
    this.typePlace,
    this.emplacementId,
    required this.codeConfirmation,
  });

  Duration get duree => dateFin.difference(dateDebut);
  int get heures => duree.inHours;
  bool get estActive => dateDebut.isBefore(DateTime.now()) && dateFin.isAfter(DateTime.now());
  bool get estEnAttentePaiement => statut == 'en_attente_paiement';
  bool get estConfirmee => statut == 'confirmée';

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      statut: json['statut'],
      poidsEstime: json['poids_estime'].toDouble(),
      montantEstime: json['montant_estime'].toDouble(),
      typePlace: json['type_place'],
      emplacementId: json['emplacement_id'],
      codeConfirmation: json['code_confirmation'],
    );
  }
}

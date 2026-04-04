class Stationnement {
  final int id;
  final DateTime dateEntree;
  final DateTime? dateSortie;  // ← au lieu de 'sortie'
  final double? poidsReel;
  final bool estActif;
  final double? montantTotal;
  final int? dureeStationnee;
  final int? noteUtilisateur;
  final String? commentaire;
  final int? reservationId;
  final int? vehiculeId;       // ← au lieu de 'vehicleId'
  final int? emplacementId;    // ← au lieu de 'parkingSpotId'

  Stationnement({
    required this.id,
    required this.dateEntree,
    this.dateSortie,
    this.poidsReel,
    required this.estActif,
    this.montantTotal,
    this.dureeStationnee,
    this.noteUtilisateur,
    this.commentaire,
    this.reservationId,
    this.vehiculeId,
    this.emplacementId,
  });

  bool get estTermine => dateSortie != null;
  bool get estEncours => !estTermine && estActif;

  factory Stationnement.fromJson(Map<String, dynamic> json) {
    return Stationnement(
      id: json['id'],
      dateEntree: DateTime.parse(json['date_entree']),
      dateSortie: json['date_sortie'] != null 
          ? DateTime.parse(json['date_sortie']) 
          : null,
      poidsReel: json['poids_reel']?.toDouble(),
      estActif: json['est_actif'] == 1,
      montantTotal: json['montant_total']?.toDouble(),
      dureeStationnee: json['duree_stationnee'],
      noteUtilisateur: json['note_utilisateur'],
      commentaire: json['commentaire'],
      reservationId: json['reservation_id'],
      vehiculeId: json['vehicule_id'],
      emplacementId: json['emplacement_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_entree': dateEntree.toIso8601String(),
      'date_sortie': dateSortie?.toIso8601String(),
      'poids_reel': poidsReel,
      'est_actif': estActif ? 1 : 0,
      'montant_total': montantTotal,
      'duree_stationnee': dureeStationnee,
      'note_utilisateur': noteUtilisateur,
      'commentaire': commentaire,
      'reservation_id': reservationId,
      'vehicule_id': vehiculeId,
      'emplacement_id': emplacementId,
    };
  }
}
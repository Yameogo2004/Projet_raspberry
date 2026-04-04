class Vehicle {
  final int id;
  final String plaque;           // ← au lieu de 'matricule'
  final String modele;
  final String marque;
  final double poidsAVide;
  final double chargeMax;
  final String couleur;
  final int annee;
  final bool estAutorise;
  final bool estSuspect;
  final int proprietaireId;

  Vehicle({
    required this.id,
    required this.plaque,
    required this.modele,
    required this.marque,
    required this.poidsAVide,
    required this.chargeMax,
    required this.couleur,
    required this.annee,
    required this.estAutorise,
    required this.estSuspect,
    required this.proprietaireId,
  });

  double get poidsTotal => poidsAVide + chargeMax;
  bool get peutMonterAscenseur => poidsTotal <= 2000;
  String get type => modele;  // ← Ajouté pour compatibilité

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      plaque: json['plaque'],
      modele: json['modele'],
      marque: json['marque'],
      poidsAVide: (json['poids_a_vide'] ?? 1500).toDouble(),
      chargeMax: (json['charge_max'] ?? 0).toDouble(),
      couleur: json['couleur'] ?? '',
      annee: json['annee'] ?? 2020,
      estAutorise: json['est_autorise'] == 1,
      estSuspect: json['est_suspect'] == 1,
      proprietaireId: json['proprietaire_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plaque': plaque,
      'modele': modele,
      'marque': marque,
      'poids_a_vide': poidsAVide,
      'charge_max': chargeMax,
      'couleur': couleur,
      'annee': annee,
      'est_autorise': estAutorise ? 1 : 0,
      'est_suspect': estSuspect ? 1 : 0,
      'proprietaire_id': proprietaireId,
    };
  }
}
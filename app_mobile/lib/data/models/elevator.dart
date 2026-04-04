class Elevator {
  final int id;
  final int niveauActuel;
  final String etat;  // ← 'statut' devient 'etat'
  final double capaciteMax;
  final double poidsActuel;
  final bool porteOuverte;

  Elevator({
    required this.id,
    required this.niveauActuel,
    required this.etat,
    required this.capaciteMax,
    required this.poidsActuel,
    required this.porteOuverte,
  });

  String get statut => etat;  // ← Ajout d'un getter pour compatibilité
  
  bool get peutMonter => poidsActuel <= capaciteMax;
  bool get estEnMouvement => etat == 'en_mouvement';
  bool get estEnPanne => etat == 'panne';

  factory Elevator.fromJson(Map<String, dynamic> json) {
    return Elevator(
      id: json['id'],
      niveauActuel: json['niveau_actuel'],
      etat: json['etat'],
      capaciteMax: json['capacite_max'].toDouble(),
      poidsActuel: json['poids_actuel'].toDouble(),
      porteOuverte: json['porte_ouverte'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'niveau_actuel': niveauActuel,
      'etat': etat,
      'capacite_max': capaciteMax,
      'poids_actuel': poidsActuel,
      'porte_ouverte': porteOuverte,
    };
  }
}
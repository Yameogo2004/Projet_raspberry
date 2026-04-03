class Elevator {
  final int id;
  final int niveauActuel;
  final String etat;
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
}
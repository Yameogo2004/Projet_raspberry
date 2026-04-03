class Capteur {
  final int id;
  final String nom;
  final String type;
  final String emplacement;
  final String statut;
  final DateTime derniereCommunication;
  final double valeurActuelle;

  Capteur({
    required this.id,
    required this.nom,
    required this.type,
    required this.emplacement,
    required this.statut,
    required this.derniereCommunication,
    required this.valeurActuelle,
  });

  factory Capteur.fromJson(Map<String, dynamic> json) {
    return Capteur(
      id: json['id'],
      nom: json['nom'],
      type: json['type'],
      emplacement: json['emplacement'],
      statut: json['statut'],
      derniereCommunication: DateTime.parse(json['derniere_communication']),
      valeurActuelle: json['valeur_actuelle'].toDouble(),
    );
  }
}
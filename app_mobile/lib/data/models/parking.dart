class ParkingSpot {
  final int id;
  final int niveau;
  final int numero;
  final String type;
  final bool estDisponible;
  final double prixParHeure;
  final bool aPriseElectrique;

  ParkingSpot({
    required this.id,
    required this.niveau,
    required this.numero,
    required this.type,
    required this.estDisponible,
    required this.prixParHeure,
    required this.aPriseElectrique,
  });

  String get libelle => 'Niveau $niveau - Place $numero';
  String get niveauLibelle => niveau == 0 ? 'Rez-de-chaussée' : 'Étage $niveau';
  String get libelleComplet => '$libelle (${prixParHeure} DH/h)';

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      id: json['id'],
      niveau: json['niveau'],
      numero: json['numero'],
      type: json['type'],
      estDisponible: json['est_disponible'] == true,
      prixParHeure: (json['prix_par_heure'] ?? 3.0).toDouble(),
      aPriseElectrique: json['a_prise_electrique'] ?? false,
    );
  }
}

class ParkingStatut {
  final int totalPlaces;
  final int placesLibres;
  final int placesOccupees;
  final double tauxOccupation;
  final int entreesJour;
  final double caJour;

  ParkingStatut({
    required this.totalPlaces,
    required this.placesLibres,
    required this.placesOccupees,
    required this.tauxOccupation,
    required this.entreesJour,
    required this.caJour,
  });

  factory ParkingStatut.fromJson(Map<String, dynamic> json) {
    return ParkingStatut(
      totalPlaces: json['total_places'],
      placesLibres: json['places_libres'],
      placesOccupees: json['places_occupees'],
      tauxOccupation: json['taux_occupation'].toDouble(),
      entreesJour: json['entrees_jour'] ?? 0,
      caJour: (json['ca_jour'] ?? 0).toDouble(),
    );
  }
}

class ParkingStatutParNiveau {
  final int niveau;
  final int placesLibres;
  final int placesOccupees;
  final int totalPlaces;
  
  ParkingStatutParNiveau({
    required this.niveau,
    required this.placesLibres,
    required this.placesOccupees,
    required this.totalPlaces,
  });
  
  String get niveauLibelle => niveau == 0 ? 'Rez-de-chaussée' : 'Étage $niveau';
  double get tauxOccupation => totalPlaces > 0 ? (placesOccupees / totalPlaces * 100) : 0;
  
  factory ParkingStatutParNiveau.fromJson(Map<String, dynamic> json) {
    return ParkingStatutParNiveau(
      niveau: json['niveau'],
      placesLibres: json['places_libres'],
      placesOccupees: json['places_occupees'],
      totalPlaces: json['total_places'],
    );
  }
}

class Vehicle {
  final int id;
  final String plaque;
  final String modele;
  final String marque;
  final double poidsAVide;
  final double chargeMax;
  final String couleur;
  final bool estAutorise;
  final bool estSuspect;

  Vehicle({
    required this.id,
    required this.plaque,
    required this.modele,
    required this.marque,
    required this.poidsAVide,
    required this.chargeMax,
    required this.couleur,
    required this.estAutorise,
    required this.estSuspect,
  });

  double get poidsTotal => poidsAVide + chargeMax;
  bool get peutMonterAscenseur => poidsTotal <= 2000;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      plaque: json['plaque'],
      modele: json['modele'],
      marque: json['marque'],
      poidsAVide: (json['poids_a_vide'] ?? 1500).toDouble(),
      chargeMax: (json['charge_max'] ?? 0).toDouble(),
      couleur: json['couleur'] ?? '',
      estAutorise: json['est_autorise'] ?? true,
      estSuspect: json['est_suspect'] ?? false,
    );
  }
}
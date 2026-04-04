class Stationnement {
  final int id;
  final DateTime dateEntree;
  final DateTime? dateSortie;
  final String plaque;
  final int niveau;
  final int placeNumero;
  final String qrCode;
  final String rfidTicket;
  final double poidsReel;
  final bool estActif;

  Stationnement({
    required this.id,
    required this.dateEntree,
    this.dateSortie,
    required this.plaque,
    required this.niveau,
    required this.placeNumero,
    required this.qrCode,
    required this.rfidTicket,
    required this.poidsReel,
    required this.estActif,
  });

  String get emplacement => 'Niveau $niveau - Place $placeNumero';
  String get niveauLibelle => niveau == 0 ? 'Rez-de-chaussée' : 'Étage $niveau';
  
  factory Stationnement.fromJson(Map<String, dynamic> json) {
    return Stationnement(
      id: json['id'],
      dateEntree: DateTime.parse(json['date_entree']),
      dateSortie: json['date_sortie'] != null 
          ? DateTime.parse(json['date_sortie']) 
          : null,
      plaque: json['plaque'],
      niveau: json['niveau'],
      placeNumero: json['place_numero'],
      qrCode: json['qr_code'],
      rfidTicket: json['rfid_ticket'],
      poidsReel: json['poids_reel'].toDouble(),
      estActif: json['est_actif'] == 1,
    );
  }
}

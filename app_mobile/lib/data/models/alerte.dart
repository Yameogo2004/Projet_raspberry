class Alerte {
  final int id;
  final String type;
  final String niveau;
  final String message;
  final DateTime dateCreation;
  final DateTime? dateResolution;
  final int? resoluePar;
  final String? commentaire;
  final bool estTraitee;

  Alerte({
    required this.id,
    required this.type,
    required this.niveau,
    required this.message,
    required this.dateCreation,
    this.dateResolution,
    this.resoluePar,
    this.commentaire,
    required this.estTraitee,
  });

  factory Alerte.fromJson(Map<String, dynamic> json) {
    return Alerte(
      id: json['id'],
      type: json['type'],
      niveau: json['niveau'],
      message: json['message'],
      dateCreation: DateTime.parse(json['date_creation']),
      dateResolution: json['date_resolution'] != null 
          ? DateTime.parse(json['date_resolution']) 
          : null,
      resoluePar: json['resolue_par'],
      commentaire: json['commentaire'],
      estTraitee: json['est_traitee'] ?? false,
    );
  }
}

import 'user.dart';

class Admin extends User {
  final int niveauAcces;
  final String service;

  Admin({
    required super.id,
    required super.nom,
    required super.prenom,
    required super.email,
    required super.telephone,
    required super.role,
    super.carteBancaireId,
    super.notificationsActives,  // ← Plus besoin de valeur, User a une valeur par défaut
    required this.niveauAcces,
    required this.service,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'],
      role: 'admin',
      carteBancaireId: json['carte_bancaire_id'],
      notificationsActives: json['notifications_actives'] ?? true,
      niveauAcces: json['niveau_acces'],
      service: json['service'],
    );
  }

  @override
  String toString() {
    return 'Admin(nomComplet: $nomComplet, niveauAcces: $niveauAcces, service: $service)';
  }
}

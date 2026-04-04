class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String role;
  final String? carteBancaireId;
  final bool notificationsActives;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.role,
    this.carteBancaireId,
    this.notificationsActives = true,  // ← AJOUTER VALEUR PAR DÉFAUT
  });

  String get nomComplet => '$prenom $nom';
  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'] ?? '',
      role: json['role'] ?? 'proprietaire',
      carteBancaireId: json['carte_bancaire_id'],
      notificationsActives: json['notifications_actives'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'role': role,
      'carte_bancaire_id': carteBancaireId,
      'notifications_actives': notificationsActives,
    };
  }
}

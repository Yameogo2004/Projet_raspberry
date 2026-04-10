class Vehicle {
  final int id;
  final String matricule;
  final String type;

  Vehicle({
    required this.id,
    required this.matricule,
    required this.type,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      matricule: json['matricule'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'matricule': matricule,
        'type': type,
      };
}
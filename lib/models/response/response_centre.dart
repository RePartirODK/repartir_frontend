import 'package:repartir_frontend/models/request/centre_request.dart';

class ResponseCentre {
  final int id;
  final String nom;
  final String adresse;
  final String telephone;
  final String email;
  final String? urlPhoto;
  final String role;
  final bool estActive;
  final String agrement;

  //constructeur de la classe
  ResponseCentre({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.telephone,
    required this.email,
    this.urlPhoto,
    required this.role,
    required this.agrement,
    required this.estActive,
  });
  factory ResponseCentre.fromJson(Map<String, dynamic> json) {
    return ResponseCentre(
      id: json['id'] is int ? json['id'] as int :
      int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nom: json['nom']?.toString() ?? '',
      adresse: json['adresse']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      agrement: json['agrement']?.toString() ?? '',
      urlPhoto: json['urlPhoto']?.toString() ?? '',
      estActive: json['estActive'] == null ? false : 
      (json['estActive'] is bool 
      ? json['estActive'] as bool : json['estActive'].toString() == 'true'),
    );
  }

  CentreRequest copyWith({
    String? nom,
    String? telephone,
    String? email,
    String? adresse,
    String? agrement,
    String? urlPhoto,
  }) {
    return CentreRequest(
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      adresse: adresse ?? this.adresse,
      agrement: agrement ?? this.agrement,
      urlPhoto: urlPhoto ?? this.urlPhoto,
    );
  }
}

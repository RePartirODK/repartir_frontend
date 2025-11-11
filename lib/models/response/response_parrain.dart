

class ResponseParrain {
  int id;
  String nom;
  String prenom;
  String email;
  String telephone;
  String? urlPhoto;
  String? role;
  String? profession;
  DateTime? dateInscription;
  UtilisateurInfoDto utilisateur;

  ResponseParrain({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    this.urlPhoto,
    required this.role,
    this.profession,
    this.dateInscription,
    required this.utilisateur,
  });

  /// --- From JSON (backend response) ---
  factory ResponseParrain.fromJson(Map<String, dynamic> json) {
    return ResponseParrain(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'],
      urlPhoto: json['urlPhoto'],
      role: json['role'],
      profession: json['profession'],
      dateInscription: json['dateInscription'] != null
          ? DateTime.parse(json['dateInscription'])
          : null,
      utilisateur: UtilisateurInfoDto.fromJson(json['utilisateur']),
    );
  }
}

class UtilisateurInfoDto {
  int id;
  String nom;
  String email;
  String telephone;
  String? urlPhoto;
  String etat;
  bool estActive;

  UtilisateurInfoDto({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    this.urlPhoto,
    required this.etat,
    required this.estActive,
  });

  factory UtilisateurInfoDto.fromJson(Map<String, dynamic> json) {
    return UtilisateurInfoDto(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      urlPhoto: json['urlPhoto'],
      etat: json['etat'],
      estActive: json['estActive'] ?? false,
    );
  }
}

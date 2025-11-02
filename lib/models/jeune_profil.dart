class JeuneProfil {
  final int id;
  final String? aPropos;
  final String? genre;
  final int? age;
  final String? prenom;
  final String? niveau;
  final String? urlDiplome;
  final UtilisateurInfo? utilisateur;

  JeuneProfil({
    required this.id,
    this.aPropos,
    this.genre,
    this.age,
    this.prenom,
    this.niveau,
    this.urlDiplome,
    this.utilisateur,
  });

  factory JeuneProfil.fromJson(Map<String, dynamic> json) {
    return JeuneProfil(
      id: json['id'],
      aPropos: json['a_propos'],
      genre: json['genre'],
      age: json['age'],
      prenom: json['prenom'],
      niveau: json['niveau'],
      urlDiplome: json['urlDiplome'],
      utilisateur: json['utilisateur'] != null
          ? UtilisateurInfo.fromJson(json['utilisateur'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'a_propos': aPropos,
      'genre': genre,
      'age': age,
      'prenom': prenom,
      'niveau': niveau,
      'urlDiplome': urlDiplome,
      'utilisateur': utilisateur?.toJson(),
    };
  }

  // Méthodes pour envoyer au backend pour modification
  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = {
      'nom': utilisateur?.nom ?? '',
      'prenom': prenom ?? '',
      'telephone': utilisateur?.telephone ?? '',
    };

    if (aPropos != null) data['a_propos'] = aPropos;
    if (age != null) data['age'] = age;
    if (niveau != null) data['niveau'] = niveau;
    if (urlDiplome != null) data['urlDiplome'] = urlDiplome;
    if (genre != null) data['genre'] = genre;
    if (utilisateur?.urlPhoto != null) data['urlPhoto'] = utilisateur!.urlPhoto;

    return data;
  }
}

class UtilisateurInfo {
  final int id;
  final String nom;
  final String email;
  final String? motDePasse; // Ne pas afficher à l'utilisateur
  final String? telephone;
  final String? urlPhoto;
  final String? role;
  final String? etat;
  final bool? estActive;
  final String? dateCreation;

  UtilisateurInfo({
    required this.id,
    required this.nom,
    required this.email,
    this.motDePasse,
    this.telephone,
    this.urlPhoto,
    this.role,
    this.etat,
    this.estActive,
    this.dateCreation,
  });

  factory UtilisateurInfo.fromJson(Map<String, dynamic> json) {
    return UtilisateurInfo(
      id: json['id'],
      nom: json['nom'],
      email: json['email'] ?? '',
      motDePasse: json['motDePasse'], // Optionnel, peut ne pas être retourné
      telephone: json['telephone'],
      urlPhoto: json['urlPhoto'],
      role: json['role'],
      etat: json['etat'],
      estActive: json['estActive'],
      dateCreation: json['dateCreation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'urlPhoto': urlPhoto,
      'role': role,
      'etat': etat,
      'estActive': estActive,
      'dateCreation': dateCreation,
    };
  }
}


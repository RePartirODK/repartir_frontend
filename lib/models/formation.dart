class Formation {
  final int id;
  final String titre;
  final String? description;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? statut;
  final double? cout;
  final int? nbrePlace;
  final String? format;
  final String? duree;
  final String? urlFormation;
  final String? urlCertificat;
  final int? idCentre;
  final CentreFormation? centreFormation;

  Formation({
    required this.id,
    required this.titre,
    this.description,
    this.dateDebut,
    this.dateFin,
    this.statut,
    this.cout,
    this.nbrePlace,
    this.format,
    this.duree,
    this.urlFormation,
    this.urlCertificat,
    this.idCentre,
    this.centreFormation,
  });

  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      dateDebut: json['date_debut'] != null
          ? DateTime.parse(json['date_debut'])
          : null,
      dateFin:
          json['date_fin'] != null ? DateTime.parse(json['date_fin']) : null,
      statut: json['statut'],
      cout: json['cout']?.toDouble(),
      nbrePlace: json['nbrePlace'],
      format: json['format'],
      duree: json['duree'],
      urlFormation: json['urlFormation'],
      urlCertificat: json['urlCertificat'],
      idCentre: json['idCentre'],
      centreFormation: json['centreFormation'] != null
          ? CentreFormation.fromJson(json['centreFormation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'date_debut': dateDebut?.toIso8601String(),
      'date_fin': dateFin?.toIso8601String(),
      'statut': statut,
      'cout': cout,
      'nbrePlace': nbrePlace,
      'format': format,
      'duree': duree,
      'urlFormation': urlFormation,
      'urlCertificat': urlCertificat,
      'idCentre': idCentre,
      'centreFormation': centreFormation?.toJson(),
    };
  }
}

class CentreFormation {
  final int id;
  final String nom;
  final String? adresse;
  final String? telephone;
  final String? email;
  final String? urlPhoto;
  final String? role;
  final bool? estActive;
  final String? agrement;

  CentreFormation({
    required this.id,
    required this.nom,
    this.adresse,
    this.telephone,
    this.email,
    this.urlPhoto,
    this.role,
    this.estActive,
    this.agrement,
  });

  factory CentreFormation.fromJson(Map<String, dynamic> json) {
    return CentreFormation(
      id: json['id'],
      nom: json['nom'],
      adresse: json['adresse'],
      telephone: json['telephone'],
      email: json['email'],
      urlPhoto: json['urlPhoto'],
      role: json['role'],
      estActive: json['estActive'],
      agrement: json['agrement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      'urlPhoto': urlPhoto,
      'role': role,
      'estActive': estActive,
      'agrement': agrement,
    };
  }
}


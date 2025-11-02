class Notification {
  final int id;
  final String message;
  final bool lue;
  final String? dateCreation;

  Notification({
    required this.id,
    required this.message,
    required this.lue,
    this.dateCreation,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      message: json['message'],
      lue: json['lue'],
      dateCreation: json['dateCreation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'lue': lue,
      'dateCreation': dateCreation,
    };
  }
}

class InscriptionResponse {
  final int id;
  final String nomJeune;
  final String titreFormation;
  final DateTime dateInscription;
  final bool demandeParrainage;
  // Nouveaux champs pour /mes-inscriptions
  final InscriptionFormationDetail? formation;
  final String? statut;

  InscriptionResponse({
    required this.id,
    required this.nomJeune,
    required this.titreFormation,
    required this.dateInscription,
    required this.demandeParrainage,
    this.formation,
    this.statut,
  });

  factory InscriptionResponse.fromJson(Map<String, dynamic> json) {
    return InscriptionResponse(
      id: json['id'],
      nomJeune: json['nomJeune'] ?? '',
      titreFormation: json['titreFormation'] ?? (json['formation']?['titre'] ?? ''),
      dateInscription: DateTime.parse(json['dateInscription']),
      demandeParrainage: json['demandeParrainage'] ?? false,
      formation: json['formation'] != null
          ? InscriptionFormationDetail.fromJson(json['formation'])
          : null,
      statut: json['statut'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomJeune': nomJeune,
      'titreFormation': titreFormation,
      'dateInscription': dateInscription.toIso8601String(),
      'demandeParrainage': demandeParrainage,
      if (formation != null) 'formation': formation!.toJson(),
      if (statut != null) 'statut': statut,
    };
  }
}

// Nouveau modèle pour les détails de formation dans les inscriptions
class InscriptionFormationDetail {
  final int id;
  final String titre;
  final String? description;
  final InscriptionCentreInfo? centre;
  final DateTime? date_debut;
  final DateTime? date_fin;

  InscriptionFormationDetail({
    required this.id,
    required this.titre,
    this.description,
    this.centre,
    this.date_debut,
    this.date_fin,
  });

  factory InscriptionFormationDetail.fromJson(Map<String, dynamic> json) {
    return InscriptionFormationDetail(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      centre: json['centre'] != null
          ? InscriptionCentreInfo.fromJson(json['centre'])
          : null,
      date_debut: json['date_debut'] != null
          ? DateTime.parse(json['date_debut'])
          : null,
      date_fin: json['date_fin'] != null ? DateTime.parse(json['date_fin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      if (description != null) 'description': description,
      if (centre != null) 'centre': centre!.toJson(),
      if (date_debut != null) 'date_debut': date_debut!.toIso8601String(),
      if (date_fin != null) 'date_fin': date_fin!.toIso8601String(),
    };
  }
}

class InscriptionCentreInfo {
  final int id;
  final String nom;
  final String? logo;

  InscriptionCentreInfo({
    required this.id,
    required this.nom,
    this.logo,
  });

  factory InscriptionCentreInfo.fromJson(Map<String, dynamic> json) {
    return InscriptionCentreInfo(
      id: json['id'],
      nom: json['nom'],
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      if (logo != null) 'logo': logo,
    };
  }
}


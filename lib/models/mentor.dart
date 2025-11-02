class Mentor {
  final int id;
  final String nomComplet;
  final String? email;
  final int? anneeExperience;
  final String? aPropos;
  final String? profession;
  final String? urlPhoto;
  final String? prenom;
  final UtilisateurInfo? utilisateur;
  final List<dynamic>? mentorings;

  Mentor({
    required this.id,
    required this.nomComplet,
    this.email,
    this.anneeExperience,
    this.aPropos,
    this.profession,
    this.urlPhoto,
    this.prenom,
    this.utilisateur,
    this.mentorings,
  });

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'],
      nomComplet: json['nomComplet'],
      email: json['email'],
      anneeExperience: json['annee_experience'],
      aPropos: json['a_propos'],
      profession: json['profession'],
      urlPhoto: json['urlPhoto'],
      prenom: json['prenom'],
      utilisateur: json['utilisateur'] != null
          ? UtilisateurInfo.fromJson(json['utilisateur'])
          : null,
      mentorings: json['mentorings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomComplet': nomComplet,
      'email': email,
      'annee_experience': anneeExperience,
      'a_propos': aPropos,
      'profession': profession,
      'urlPhoto': urlPhoto,
      'prenom': prenom,
      'utilisateur': utilisateur?.toJson(),
      'mentorings': mentorings,
    };
  }
}

class Mentoring {
  final int id;
  final String? nomJeune;
  final String? prenomJeune;
  final String? nomMentor;
  final String? prenomMentor;
  final DateTime? dateDebut;
  final String? objectif;
  final String? description;
  final int? noteMentor;
  final int? noteJeune;

  Mentoring({
    required this.id,
    this.nomJeune,
    this.prenomJeune,
    this.nomMentor,
    this.prenomMentor,
    this.dateDebut,
    this.objectif,
    this.description,
    this.noteMentor,
    this.noteJeune,
  });

  factory Mentoring.fromJson(Map<String, dynamic> json) {
    return Mentoring(
      id: json['id'],
      nomJeune: json['nomJeune'],
      prenomJeune: json['prenomJeune'],
      nomMentor: json['nomMentor'],
      prenomMentor: json['prenomMentor'],
      dateDebut: json['dateDebut'] != null
          ? DateTime.parse(json['dateDebut'])
          : null,
      objectif: json['objectif'],
      description: json['description'],
      noteMentor: json['noteMentor'],
      noteJeune: json['noteJeune'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomJeune': nomJeune,
      'prenomJeune': prenomJeune,
      'nomMentor': nomMentor,
      'prenomMentor': prenomMentor,
      'dateDebut': dateDebut?.toIso8601String(),
      'objectif': objectif,
      'description': description,
      'noteMentor': noteMentor,
      'noteJeune': noteJeune,
    };
  }
}

class CreateMentoringRequest {
  final String description;
  final String objectif;

  CreateMentoringRequest({
    required this.description,
    required this.objectif,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'objectif': objectif,
    };
  }
}


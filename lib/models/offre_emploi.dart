enum TypeContrat {
  CDI,
  CDD,
  STAGE;

  String get displayName {
    switch (this) {
      case TypeContrat.CDI:
        return 'CDI';
      case TypeContrat.CDD:
        return 'CDD';
      case TypeContrat.STAGE:
        return 'Stage';
    }
  }
}

class OffreEmploi {
  final int id;
  final String titre;
  final String description;
  final String competence;
  final TypeContrat typeContrat;
  final String lienPostuler;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String nomEntreprise;

  OffreEmploi({
    required this.id,
    required this.titre,
    required this.description,
    required this.competence,
    required this.typeContrat,
    required this.lienPostuler,
    required this.dateDebut,
    required this.dateFin,
    required this.nomEntreprise,
  });

  factory OffreEmploi.fromJson(Map<String, dynamic> json) {
    return OffreEmploi(
      id: json['id'] as int,
      titre: json['titre'] as String,
      description: json['description'] as String,
      competence: json['competence'] as String? ?? '',
      typeContrat: _parseTypeContrat(json['type_contrat'] as String),
      lienPostuler: json['lienPostuler'] as String,
      dateDebut: DateTime.parse(json['dateDebut'] as String),
      dateFin: DateTime.parse(json['dateFin'] as String),
      nomEntreprise: json['nomEntreprise'] as String? ?? 'Non spécifié',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'competence': competence,
      'type_contrat': typeContrat.name,
      'lienPostuler': lienPostuler,
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
    };
  }

  /// Convertit en Map pour la page de détails
  Map<String, dynamic> toDetailMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'competence': competence,
      'type_contrat': typeContrat.displayName,
      'lien_postuler': lienPostuler,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'entreprise': nomEntreprise,
    };
  }

  static TypeContrat _parseTypeContrat(String value) {
    try {
      return TypeContrat.values.firstWhere(
        (e) => e.name.toUpperCase() == value.toUpperCase(),
      );
    } catch (e) {
      return TypeContrat.CDI;
    }
  }

  bool get isActive {
    final now = DateTime.now();
    // Une offre est active tant que la date de fin n'est pas dépassée
    return now.isBefore(dateFin) || now.isAtSameMomentAs(dateFin);
  }

  int get joursRestants {
    final now = DateTime.now();
    return dateFin.difference(now).inDays;
  }
}



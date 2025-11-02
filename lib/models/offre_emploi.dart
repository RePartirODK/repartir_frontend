class OffreEmploi {
  final int id;
  final String titre;
  final String description;
  final String? competence;
  final String? typeContrat;
  final String? lienPostuler;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? nomEntreprise;

  OffreEmploi({
    required this.id,
    required this.titre,
    required this.description,
    this.competence,
    this.typeContrat,
    this.lienPostuler,
    this.dateDebut,
    this.dateFin,
    this.nomEntreprise,
  });

  factory OffreEmploi.fromJson(Map<String, dynamic> json) {
    return OffreEmploi(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      competence: json['competence'],
      typeContrat: json['type_contrat'],
      lienPostuler: json['lienPostuler'],
      dateDebut: json['dateDebut'] != null
          ? DateTime.parse(json['dateDebut'])
          : null,
      dateFin:
          json['dateFin'] != null ? DateTime.parse(json['dateFin']) : null,
      nomEntreprise: json['nomEntreprise'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'competence': competence,
      'type_contrat': typeContrat,
      'lienPostuler': lienPostuler,
      'dateDebut': dateDebut?.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'nomEntreprise': nomEntreprise,
    };
  }
}


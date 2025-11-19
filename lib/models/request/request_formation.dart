class RequestFormation {
  final String titre;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String statut;
  final double? cout;
  final int? nbrePlace;
  final String format;
  final String duree;
  final String? urlFormation;
  final String? urlCertificat;
  final bool? gratuit;

  // 🔹 Constructeur
  RequestFormation({
    required this.titre,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    this.cout,
    this.nbrePlace,
    required this.format,
    required this.duree,
    this.urlFormation,
    this.urlCertificat,
    this.gratuit,
  });

  // Conversion d’un JSON vers un objet Dart
  factory RequestFormation.fromJson(Map<String, dynamic> json) {
    return RequestFormation(
      titre: json['titre'],
      description: json['description'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      statut: json['statut'],
      cout: json['cout']?.toDouble(),
      nbrePlace: json['nbrePlace'],
      format: json['format'],
      duree: json['duree'],
      urlFormation: json['urlFormation'],
      urlCertificat: json['urlCertificat'],
      gratuit: json['gratuit'] as bool?,
    );
  }

  //Conversion d’un objet Dart vers un JSON
  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'statut': statut,
      'cout': cout,
      'nbrePlace': nbrePlace,
      'format': format,
      'duree': duree,
      'urlFormation': urlFormation,
      'urlCertificat': urlCertificat,
      'gratuit': gratuit,
    };
  }
}

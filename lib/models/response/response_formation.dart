class ResponseFormation {
  final int id;
  final String titre;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String statut;
  final double cout;
  final int nbrePlace;
  final String format;
  final String duree;
  final String? urlFormation;
  final String? urlCertificat;
  final int idCentre;
  final bool? gratuit;

  ResponseFormation({
    required this.id,
    required this.titre,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.statut,
    required this.cout,
    required this.nbrePlace,
    required this.format,
    required this.duree,
    this.urlFormation,
    this.urlCertificat,
    required this.idCentre,
    this.gratuit,
  });

  /// Factory constructor pour créer un objet à partir d’un JSON
  factory ResponseFormation.fromJson(Map<String, dynamic> json) {
    return ResponseFormation(
      id: json['id']is int ? json['id'] as int :
      int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      statut: json['statut'] ?? '',
      cout: (json['cout'] as num).toDouble(),
      nbrePlace: json['nbrePlace']is int ? json['nbrePlace'] as int :
      int.tryParse(json['nbrePlace']?.toString() ?? '0') ?? 0,
      format: json['format'] ?? '',
      duree: json['duree'] ?? '',
      urlFormation: json['urlFormation'] ?? '',
      urlCertificat: json['urlCertificat'] ?? '',
      idCentre: json['idCentre']is int ? json['idCentre'] as int :
      int.tryParse(json['idCentre']?.toString() ?? '0') ?? 0,
      gratuit: json['gratuit'] as bool?,
    );
  }
 
}

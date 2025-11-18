class ResponseInscription {
  final int id;
  final String nomJeune;
  final String titreFormation;
  final DateTime dateInscription;
  final bool demandeParrainage;
  final String status;
  final bool certifie;
  // Add: formation ID and formation persisted statut
  final int? idFormation;
  final String? formationStatut;

  ResponseInscription({
    required this.id,
    required this.nomJeune,
    required this.titreFormation,
    required this.dateInscription,
    required this.demandeParrainage,
    required this.certifie,
    required this.status,
    this.idFormation,
    this.formationStatut,
  });

  factory ResponseInscription.fromJson(Map<String, dynamic> json) {
    return ResponseInscription(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nomJeune: json['nomJeune'] ?? '',
      titreFormation: json['titreFormation'] ?? '',
      dateInscription:
          DateTime.tryParse(json['dateInscription']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      demandeParrainage: (json['demandeParrainage'] is bool)
          ? json['demandeParrainage'] as bool
          : (json['demandeParrainage']?.toString() == 'true'),
      certifie: (json['certifie'] is bool)
          ? (json['certifie'] as bool)
          : (json['certifie']?.toString() == 'true'),
      status: (json['status'] ?? '').toString(),
     // New fields
      idFormation: json['idFormation'] is int
          ? json['idFormation'] as int
          : int.tryParse(json['idFormation']?.toString() ?? ''),
      formationStatut: json['formationStatut']?.toString(),
    
    );
  }
}

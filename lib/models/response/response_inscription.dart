class ResponseInscription {
  final int id;
  final String nomJeune;
  final String titreFormation;
  final DateTime dateInscription;
  final bool demandeParrainage;

  ResponseInscription({
    required this.id,
    required this.nomJeune,
    required this.titreFormation,
    required this.dateInscription,
    required this.demandeParrainage,
  });

  factory ResponseInscription.fromJson(Map<String, dynamic> json) {
    return ResponseInscription(
      id: json['id'] is int ? json['id'] as int :
        int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nomJeune: json['nomJeune'] ?? '',
      titreFormation: json['titreFormation'] ?? '',
      dateInscription: DateTime.tryParse(json['dateInscription']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      demandeParrainage: (json['demandeParrainage'] is bool)
          ? json['demandeParrainage'] as bool
          : (json['demandeParrainage']?.toString() == 'true'),
    );
  }
}

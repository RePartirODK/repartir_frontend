class ResponsePaiement {
  final int id;
  final double montant;
  final String reference;
  final DateTime date;
  final String status;
  final int idJeune;
  final int? idParrainage;
  final int idFormation;

  ResponsePaiement({
    required this.id,
    required this.montant,
    required this.reference,
    required this.date,
    required this.status,
    required this.idJeune,
    this.idParrainage,
    required this.idFormation,
  });

  factory ResponsePaiement.fromJson(Map<String, dynamic> json) {
    return ResponsePaiement(
      id: json['id'] as int,
      montant: (json['montant'] as num).toDouble(),
      reference: json['reference'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      idJeune: json['idJeune'] as int,
      idParrainage: json['idParrainage'] as int?,
      idFormation: json['idFormation'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'montant': montant,
      'reference': reference,
      'date': date.toIso8601String(),
      'status': status,
      'idJeune': idJeune,
      'idParrainage': idParrainage,
      'idFormation': idFormation,
    };
  }
}






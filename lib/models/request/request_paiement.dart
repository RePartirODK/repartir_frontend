class RequestPaiement {
  final int idJeune;
  final int idInscription;
  final double montant;
  final int? idParrainage;

  RequestPaiement({
    required this.idJeune,
    required this.idInscription,
    required this.montant,
    this.idParrainage,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'idJeune': idJeune,
      'idInscription': idInscription,
      'montant': montant,
    };
    
    // N'inclure idParrainage que s'il n'est pas null
    if (idParrainage != null) {
      map['idParrainage'] = idParrainage;
    }
    
    return map;
  }

  factory RequestPaiement.fromJson(Map<String, dynamic> json) {
    return RequestPaiement(
      idJeune: json['idJeune'] as int,
      idInscription: json['idInscription'] as int,
      montant: (json['montant'] as num).toDouble(),
      idParrainage: json['idParrainage'] as int?,
    );
  }
}


// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CentreRequest {
  final String nom;
  final String motDePasse;
  final String telephone;
  final String role = "CENTRE";
  final String email;
  final String adresse;
  final String agrement;

  //constructeur
  CentreRequest({required  this.nom, 
  required this.adresse,
  required this.email,
  required  this.agrement,
  required this.telephone,
  required  this.motDePasse});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nom': nom,
      'motDePasse': motDePasse,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'agrement': agrement,
      'role':role
    };
  }

  factory CentreRequest.fromMap(Map<String, dynamic> map) {
    return CentreRequest(
      nom: map['nom'] as String,
      motDePasse: map['motDePasse'] as String,
      telephone: map['telephone'] as String,
      email: map['email'] as String,
      adresse: map['adresse'] as String,
      agrement: map['agrement'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CentreRequest.fromJson(String source) => CentreRequest.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CentreRequest(nom: $nom, motDePasse: $motDePasse, telephone: $telephone, email: $email, adresse: $adresse, agrement: $agrement)';
  }

  @override
  bool operator ==(covariant CentreRequest other) {
    if (identical(this, other)) return true;
  
    return 
      other.nom == nom &&
      other.motDePasse == motDePasse &&
      other.telephone == telephone &&
      other.email == email &&
      other.adresse == adresse &&
      other.agrement == agrement;
  }

  @override
  int get hashCode {
    return nom.hashCode ^
      motDePasse.hashCode ^
      telephone.hashCode ^
      email.hashCode ^
      adresse.hashCode ^
      agrement.hashCode;
  }
}

import 'package:flutter/material.dart';

class EntrepriseRequest {
  final String nom;
  final String email;
  final String telephone;
  final String? urlPhoto;
  final String motDePasse;
  final String role = "ENTREPRISE";
  final bool estActive;

  final String adresse;
  final String agrement;

  //constructeur de la classe EntrepriseRequest
  EntrepriseRequest({
    required this.nom,
    required this.email,
    required this.telephone,
    required this.urlPhoto,
    required this.motDePasse,
    required this.estActive,
    required this.adresse,
    required this.agrement,
  });

  //convertir en json
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "nom": nom,
      "motDePasse": motDePasse,
      "telephone": telephone,
      "email": email,
      "adresse": adresse,
      "agrement": agrement,
    };
    if (urlPhoto !=null) data['urlPhoto'] = urlPhoto;
    return data;
  }
}

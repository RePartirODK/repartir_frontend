class ResponseParrain {
  String id;
  String nom;
  String prenom;
  String email;
  String telephone;
 final String telephone;
  final String email;
  final String? urlPhoto;
  final String role;
  final bool estActive;
  final String agrement;
  String motDePasse = '';
  ResponseParrain({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.ville,
    required this.pays,
    required this.codePostal,
  });

  static fromJson(data) {}
}
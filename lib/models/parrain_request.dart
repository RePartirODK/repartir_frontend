class ParrainRequest {
  final String nom;
  final String email;
  final String telephone;
  final String? urlPhoto;
  final String motDePasse;
  final String role = "PARRAIN";
  final String prenom;
  final String profession;

  //constructeur de la classe
  ParrainRequest({
    required this.nom,
    required this.email,
    required this.telephone,
    this.urlPhoto,
    required this.motDePasse,

    required this.prenom,
    required this.profession,
  });

   Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "nom": nom,
      "motDePasse": motDePasse,
      "telephone": telephone,
      "email": email,
      "prenom": prenom,
      "profession": profession,
      "role": role,
    };
    if (urlPhoto !=null) data['urlPhoto'] = urlPhoto;
    return data;
  }
}

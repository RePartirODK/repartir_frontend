class MentorsRequest {
  final String prenom;
  final int anneeExperience;
  final String aPropos;
  final String profession;
  final String nom;
  final String motDePasse;
  final String telephone;
  final String? urlPhoto;
  final String role = "MENTOR";
  final String email;

  //construteur de la classe;
  MentorsRequest({
    required this.prenom,
    required this.anneeExperience,
    required this.aPropos,
    required this.profession,
    required this.nom,
    required this.motDePasse,
    required this.telephone,
    this.urlPhoto,
    required this.email,
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
      "annee_experience": anneeExperience,
      "a_propos": aPropos,
    };
    if (urlPhoto !=null) data['urlPhoto'] = urlPhoto;
    return data;
  }
}

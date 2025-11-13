class EntrepriseRequest {
  final String nom;
  final String email;
  final String telephone;
  final String? urlPhoto;
  final String motDePasse;
  final String role = "ENTREPRISE";

  final String adresse;
  final String agrement;
  final List<int>? domaineIds;

  //constructeur de la classe EntrepriseRequest
  EntrepriseRequest({
    required this.nom,
    required this.email,
    required this.telephone,
    this.urlPhoto,
    required this.motDePasse,
    required this.adresse,
    required this.agrement,
    this.domaineIds,
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
      "role": role,
    };
    if (urlPhoto !=null) data['urlPhoto'] = urlPhoto;
    return data;
  }
}

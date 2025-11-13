class JeuneRequest {
  final String nom;
  final String email;
  final String telephone;
  final String? urlPhoto;
  final String motDePasse;
  final String role = "JEUNE";
  final List<int>? domaineIds;

  //champs this
  final String aPropos;
  final String genre;
  final int age;
  final String prenom;
  final String? niveau;
  final String? urlDiplome;

  //constructeur de la classe
  JeuneRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    this.urlPhoto,
    required this.motDePasse,
    required this.aPropos,
    required this.genre,
    required this.age,
    this.niveau,
    this.urlDiplome,
    this.domaineIds,
  });

  /// Conversion en JSON (sans champs null)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'motDePasse': motDePasse,
      'role': role,
      'a_propos': aPropos,
      'genre': genre,
      'age': age,
    };

    // Ajouter les champs optionnels uniquement s’ils ne sont pas nuls
    if (urlPhoto != null) data['urlPhoto'] = urlPhoto;
    if (niveau != null) data['niveau'] = niveau;
    if (urlDiplome != null) data['urlDiplome'] = urlDiplome;

    return data;
  }
}

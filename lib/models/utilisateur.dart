class Utilisateur {
  final String email;
  final String role;
  //constructeur de la classe
  Utilisateur({required this.email, required this.role});

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      email:json["email"],
      role: json["role"]
    );
  }
}

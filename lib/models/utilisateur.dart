class Utilisateur {
  final int id;
  final String nom;
  final String motDePasse;
  final String telephone;
  final String? urlPhoto;
  final String role;
  final String email;
  final bool etat;
  final bool estActive;
  //date de creation du compte
  final DateTime dateCreation;
  final List<String> userDomaineList;
  final List<String> notifications;

  //constructeur de la classe
   Utilisateur({
    required this.id,
    required this.nom,
    required this.motDePasse,
    required this.telephone,
    this.urlPhoto,
    required this.role,
    required this.email,
    required this.etat,
    required this.estActive,
    required this.dateCreation,
    required this.userDomaineList,
    required this.notifications,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    final userDomaineJson = (json['userDomaineList'] ?? []) as List;
    final userDomaineList = userDomaineJson
        .map((d) => d is Map ? (d['domaine']?['libelle']?.toString() ?? '') : d?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    final notificationsJson = (json['notifications'] ?? []) as List;
    final notificationsList = notificationsJson
        .map((n) => n is Map ? (n['message']?.toString() ?? '') : n?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return Utilisateur(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nom: json['nom']?.toString() ?? '',
      motDePasse: json['motDePasse']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      urlPhoto: json['urlPhoto']?.toString(), // reste nullable
      role: json['role']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      etat: json['etat'] == null ? false: 
      json['etat'] is bool ? 
      json['etat'] as bool : 
      json['etat'].toString() == 'true'
      ,
      estActive: json['estActive'] == null ? false : 
      (json['estActive'] is bool 
      ? json['estActive'] as bool : json['estActive'].toString() == 'true'),
      dateCreation: DateTime.tryParse(json['dateCreation']?.toString() ?? '') ?? DateTime.now(),
      userDomaineList: userDomaineList,
      notifications: notificationsList,
    );
  }
  }
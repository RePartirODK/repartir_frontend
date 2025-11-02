class ApiConfig {
  static const String baseUrl = 'http://localhost:8183/api';
  
  // Endpoints
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String jeunesProfile = '/jeunes/profile';
  static const String jeunesModifier = '/jeunes/modifier';
  static const String jeunesSupprimer = '/jeunes/supprimer';
  static const String uploadPhotoProfil = '/utilisateurs/photoprofil';
  static const String offresLister = '/offres/lister';
  static const String offresParId = '/offres'; // /{id}
  static const String formations = '/formations';
  static const String formationsParId = '/formations'; // /{id}
  static const String formationsParCentre = '/formations/centre'; // /{centreId}
  static const String inscriptions = '/inscriptions/s-inscrire'; // /{formationId}
  static const String mesInscriptions = '/inscriptions/mes-inscriptions';
  static const String mentors = '/mentors';
  static const String mentorsParId = '/mentors'; // /{id}
  static const String mentoringsCreate = '/mentorings/create'; // /{idMentor}/{idJeune}
  static const String mentoringsParJeune = '/mentorings/jeune'; // /{idJeune}
  static const String mentoringsNoteMentor = '/mentorings/note/mentor'; // /{idMentoring}
  static const String mentoringsNoteJeune = '/mentorings/note/jeune'; // /{idMentoring}
  static const String mentoringsSupprimer = '/mentorings'; // /{idMentoring}
  static const String centres = '/centres';
  static const String centresActifs = '/centres/actifs';
  static const String centresParId = '/centres'; // /{id}
  static const String centresParEmail = '/centres/email'; // /{email}
  static const String centresFormations = '/centres'; // /{id}/formations
  static const String notificationsNonLues = '/notifications/non-lues';
  static const String notificationsMarquerLue = '/notifications'; // /{id}/marquer-comme-lue
}


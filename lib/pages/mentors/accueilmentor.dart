import 'dart:async';
import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/pages/mentors/formentoringdetails.dart';
import 'package:repartir_frontend/pages/mentors/formentoring.dart';
import 'package:repartir_frontend/services/mentor_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';


// --- Constantes de Style ---
const Color kPrimaryColor = Color(0xFF3EB2FF); // Bleu foncé
const Color kAccentColor = Color(0xFFB3E5FC); // Bleu clair
const Color kBackgroundColor = Color(0xFFF5F5F5); // Fond légèrement gris

// --- Widget Principal ---

// Fichier: models.dart

class MentorStat {
  final int mentoring;
  final int demande;
  final int dejaMentores;

  MentorStat({
    required this.mentoring,
    required this.demande,
    required this.dejaMentores,
  });
}

class Mentore {
  final String nom;
  final String imagePath; // Simule un chemin d'image

  Mentore({required this.nom, required this.imagePath});
}

// Données statiques pour simuler le backend
final mentorStats = MentorStat(
  mentoring: 4,
  demande: 5,
  dejaMentores: 5,
);

final mentoringsEnCours = [
  Mentore(nom: 'Amadou Diallo', imagePath: 'assets/mentore_1.png'),
  Mentore(nom: 'Aissata Diakité', imagePath: 'assets/mentore_2.png'),
  Mentore(nom: 'Ismael Touré', imagePath: 'assets/mentore_3.png'),
  // Ajoutez plus d'éléments pour tester le défilement horizontal
  Mentore(nom: 'Fatou Ndiaye', imagePath: 'assets/mentore_4.png'),
  Mentore(nom: 'Moussa Cissokho', imagePath: 'assets/mentore_5.png'),
];

final requeteEnAttente = Mentore(
  nom: 'Abdou Abarchi Ibrahim',
  imagePath: 'assets/mentore_req.png',
);
class MentorHomePage extends StatefulWidget {
  const MentorHomePage({super.key});

  @override
  State<MentorHomePage> createState() => _MentorHomePageState();
}

class _MentorHomePageState extends State<MentorHomePage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  final MentorService _mentorService = MentorService();
  final ProfileService _profileService = ProfileService();

  bool _loading = true;
  List<Map<String, dynamic>> _mentorings = [];
  MentorStat _stats = MentorStat(mentoring: 0, demande: 0, dejaMentores: 0);
  List<Map<String, dynamic>> _mentoringsEnCours = [];
  Map<String, dynamic>? _requeteEnAttente;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _loadData();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // Récupérer l'ID du mentor connecté
      final me = await _profileService.getMe();
      final mentorId = me['id'] as int;

      // Récupérer tous les mentorings du mentor
      final mentorings = await _mentorService.getMentorMentorings(mentorId);
      
      // Calculer les stats
      final enAttente = mentorings.where((m) => m['statut'] == 'EN_ATTENTE').length;
      final valides = mentorings.where((m) => m['statut'] == 'VALIDE').toList();
      final total = mentorings.length;

      // Filtrer les mentorings en cours (VALIDE)
      final enCours = valides;

      // Récupérer la première demande en attente
      final demandesEnAttente = mentorings.where((m) => m['statut'] == 'EN_ATTENTE').toList();

      setState(() {
        _mentorings = mentorings;
        _stats = MentorStat(
          mentoring: valides.length,
          demande: enAttente,
          dejaMentores: total,
        );
        _mentoringsEnCours = enCours;
        _requeteEnAttente = demandesEnAttente.isNotEmpty ? demandesEnAttente.first : null;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur chargement données mentor: $e');
      setState(() => _loading = false);
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        final delta = 120.0; // Distance de défilement (largeur d'une carte)

        if (currentScroll >= maxScroll) {
          // Revenir au début
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          // Défiler vers la droite
          _scrollController.animateTo(
            currentScroll + delta,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Contenu principal avec bordure arrondie
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 30, 16, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // Slogan inspirant pour mentor
                            _buildSloganCard(),
                            const SizedBox(height: 20),

                            // 2. Aperçu des Statistiques
                            _buildStatsApercu(_stats),
                            const SizedBox(height: 30),

                            // 3. Mentoring en Cours (Scrollable Horizontal avec auto-scroll)
                            if (_mentoringsEnCours.isNotEmpty)
                              _buildMentoringEnCoursAPI(_mentoringsEnCours, _scrollController),
                            if (_mentoringsEnCours.isNotEmpty) const SizedBox(height: 30),

                            // 4. Requête en Attente
                            if (_requeteEnAttente != null)
                              _buildRequeteEnAttenteAPI(_requeteEnAttente!, context),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // Header avec logo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                CustomHeader(title: 'Accueil', height: 150),
                Positioned(
                  height: 80,
                  width: 80,
                  top: 30,
                  left: 20,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'assets/images/logo_repartir.png',
                      height: 300,
                      width: 300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets de Construction de Sections ---

  // Slogan inspirant pour les mentors
  Widget _buildSloganCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.people_outline, color: kPrimaryColor, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "Guidez les talents de demain, partagez votre expertise.",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLogo() {
    return Transform.translate(
      offset: const Offset(0, -10), // Remonte le logo de 10px
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo_repartir.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }


  Widget _buildStatsApercu(MentorStat stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aperçu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        // Ligne 1: Mentoring et Demande
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Mentoring', stats.mentoring),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard('Demande', stats.demande),
            ),
          ],
        ),
        const SizedBox(height: 15),
        // Ligne 2: Déjà mentorés
        _buildStatCard('Déjà mentorés', stats.dejaMentores, isLarge: true),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isLarge
          ? Center(
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

 Widget _buildMentoringEnCours(List<Mentore> mentorings, ScrollController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'Mentoring en cours',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      const SizedBox(height: 15),
      
      // ✅ Scroll horizontal avec auto-scroll
      SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: mentorings.map((mentore) {
            return Container(
              width: 120,
              height: 140, // ✅ Hauteur fixe pour uniformiser
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: kAccentColor.withOpacity(0.4),
                    child: const Icon(Icons.person, size: 40, color: kPrimaryColor),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      mentore.nom,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 15),
    ],
  );
}

  Widget _buildRequeteEnAttente(Mentore requete, BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Requête en attente',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha:0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: kAccentColor.withValues(alpha:0.3),
                backgroundImage: (requete.imagePath.isNotEmpty && requete.imagePath.startsWith('http'))
                    ? NetworkImage(requete.imagePath)
                    : null,
                child: (requete.imagePath.isEmpty || !requete.imagePath.startsWith('http'))
                    ? const Icon(Icons.person, size: 30, color: kPrimaryColor)
                    : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  requete.nom,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Action pour voir la requête
                  /**
                   * Navigation vers la page
                   */
                    final detail = DetailDemande(
                    nom: "test",
                    objectif: "Devenir expert en leadership et mentorat",
                    formations: [
                      "Communication",
                      "Coaching",
                      "Développement personnel",
                    ],
                  );

                 
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DemandeDetailsPage(demande: detail),
                    ),
                  );
                
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Voir', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =================== WIDGETS API ===================

  /// Affiche les mentorings en cours depuis l'API
  Widget _buildMentoringEnCoursAPI(List<Map<String, dynamic>> mentorings, ScrollController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Mentoring en cours',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 15),
        
        // Scroll horizontal avec auto-scroll
        SingleChildScrollView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: mentorings.map((mentoring) {
              final prenom = (mentoring['prenomJeune'] ?? '').toString().trim();
              final nom = (mentoring['nomJeune'] ?? '').toString().trim();
              final nomComplet = '$prenom $nom'.trim();

              final urlPhoto = (mentoring['urlPhotoJeune'] ?? '').toString().trim();
              
              // Debug: Voir toutes les clés disponibles
              if (mentorings.indexOf(mentoring) == 0) {
                print('🔍 Clés mentoring pour photo jeune: ${mentoring.keys.toList()}');
                print('📸 urlPhotoJeune: $urlPhoto');
              }
              
              return Container(
                width: 120,
                height: 140, // ✅ Hauteur fixe
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProfileAvatar(
                      photoUrl: urlPhoto,
                      radius: 35,
                      isPerson: true,
                      backgroundColor: kAccentColor.withOpacity(0.4),
                      iconColor: kPrimaryColor,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        nomComplet.isNotEmpty ? nomComplet : 'Jeune',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  /// Affiche une requête en attente depuis l'API
  Widget _buildRequeteEnAttenteAPI(Map<String, dynamic> requete, BuildContext context) {
    final prenom = (requete['prenomJeune'] ?? '').toString().trim();
    final nom = (requete['nomJeune'] ?? '').toString().trim();
    final nomComplet = '$prenom $nom'.trim();
    final urlPhoto = (requete['urlPhotoJeune'] ?? '').toString().trim();
    
    // Debug
    print('🔍 Clés requête: ${requete.keys.toList()}');
    print('📸 Photo jeune dans requête: $urlPhoto');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Requête en attente',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            onTap: () async {
              // ✅ Naviguer vers la page de détails avec l'API
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DemandeDetailsPageAPI(
                    demande: requete,
                    onUpdate: _loadData, // ✅ Callback pour auto-refresh
                  ),
                ),
              );
              // ✅ Recharger automatiquement après retour si une action a été faite
              if (result == true) {
                print('✅ Action effectuée, rechargement de la page d\'accueil...');
                await _loadData();
              }
            },
            child: Row(
              children: [
                ProfileAvatar(
                  photoUrl: urlPhoto,
                  radius: 25,
                  isPerson: true,
                  backgroundColor: kAccentColor.withOpacity(0.3),
                  iconColor: kPrimaryColor,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    nomComplet.isNotEmpty ? nomComplet : 'Jeune',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
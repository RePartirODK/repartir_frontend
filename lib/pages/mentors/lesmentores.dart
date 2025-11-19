// mentores_page.dart

import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/mentor_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/pages/mentors/mentore_detail_page.dart';

Color primaryBlue = Color(0xFF3EB2FF);

// Modèle de données statique pour un mentoré
class Mentore {
  final String nom;
  final int dureeMois;
  final int scoreActuel;
  final int scoreTotal;

  Mentore(this.nom, this.dureeMois, this.scoreActuel, this.scoreTotal);
}

class MentoresPage extends StatefulWidget {
  const MentoresPage({super.key});

  @override
  State<MentoresPage> createState() => _MentoresPageState();
}

class _MentoresPageState extends State<MentoresPage> {
  final MentorService _mentorService = MentorService();
  final ProfileService _profileService = ProfileService();

  bool _loading = true;
  List<Map<String, dynamic>> _mentoresValides = [];

  @override
  void initState() {
    super.initState();
    _loadMentores();
  }

  Future<void> _loadMentores() async {
    setState(() => _loading = true);
    try {
      final me = await _profileService.getMe();
      final mentorId = me['id'] as int;

      final mentorings = await _mentorService.getMentorMentorings(mentorId);

      // Filtrer uniquement les mentorings VALIDE
      final valides = mentorings.where((m) => m['statut'] == 'VALIDE').toList();

      setState(() {
        _mentoresValides = valides;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ Erreur chargement mentorés: $e');
      setState(() => _loading = false);
    }
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
                      onRefresh: _loadMentores,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 30, 16, 100),
                        child: Column(
                          children: [
                            // Message si aucun mentoré
                            if (_mentoresValides.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Aucun jeune mentoré',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),

                            // Liste des mentorés
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _mentoresValides.length,
                              itemBuilder: (context, index) {
                                final mentoring = _mentoresValides[index];
                                return MentoreTileAPI(
                                  mentoring: mentoring,
                                  onUpdate: (updatedMentoring) async {
                                    // ✅ Recharger toutes les données depuis le backend
                                    print('✅ Rechargement des mentorés après notation...');
                                    await _loadMentores();
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              title: "Mentorés",
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ WIDGETS API ============

/// Widget pour afficher un mentoré depuis l'API
class MentoreTileAPI extends StatelessWidget {
  final Map<String, dynamic> mentoring;
  final Function(Map<String, dynamic>) onUpdate;

  const MentoreTileAPI({
    super.key,
    required this.mentoring,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final prenom = (mentoring['prenomJeune'] ?? '').toString().trim();
    final nom = (mentoring['nomJeune'] ?? '').toString().trim();
    final nomComplet = '$prenom $nom'.trim();
    
    // Calculer la durée (si dateDebut disponible)
    int dureeMois = 0;
    final dateDebutStr = mentoring['dateDebut']?.toString();
    if (dateDebutStr != null && dateDebutStr.isNotEmpty) {
      try {
        final dateDebut = DateTime.parse(dateDebutStr);
        final maintenant = DateTime.now();
        dureeMois = ((maintenant.difference(dateDebut).inDays) / 30).round();
      } catch (e) {
        debugPrint('Erreur parsing date: $e');
      }
    }

    final noteJeune = mentoring['noteJeune'] ?? 0;
    final noteMentor = mentoring['noteMentor'] ?? 0;
    final scoreTotal = 20; // Score max par défaut
    final urlPhotoJeune = (mentoring['urlPhotoJeune'] ?? '').toString().trim();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        // Avatar avec photo
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: primaryBlue.withValues(alpha: 0.1),
          backgroundImage: (urlPhotoJeune.isNotEmpty && urlPhotoJeune.startsWith('http'))
              ? NetworkImage(urlPhotoJeune)
              : null,
          child: (urlPhotoJeune.isEmpty || !urlPhotoJeune.startsWith('http'))
              ? const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.blueGrey,
                )
              : null,
        ),
        // Nom et infos
        title: Text(
          nomComplet.isNotEmpty ? nomComplet : 'Jeune',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text('Durée: $dureeMois mois'),
            const SizedBox(height: 3),
            Text('Ma note attribuée: $noteMentor/20'),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MentoreDetailPage(mentoring: mentoring),
            ),
          );
          
          // ✅ Rafraîchir la liste si changement
          if (result == true) {
            print('✅ Retour avec changement, rechargement liste mentorés...');
            onUpdate(mentoring); // Signaler le changement au parent
          }
        },
      ),
    );
  }
}

// Widget réutilisable pour chaque élément de la liste
class MentoreTile extends StatelessWidget {
  final Mentore mentore;

  const MentoreTile({super.key, required this.mentore});

  @override
  Widget build(BuildContext context) {
    // Déterminer la couleur du score (rouge/orange si 0, sinon gris)
    final scoreColor = mentore.scoreActuel == 0
        ? Colors.red.shade700
        : Colors.blueGrey;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Avatar et Score/Progression
            SizedBox(
              width: 90,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryBlue.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.blueGrey,
                    ), // Placeholder
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${mentore.scoreActuel}/${mentore.scoreTotal}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
            ),

            // Nom et Statut
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mentore.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mentoré depuis ${mentore.dureeMois} mois',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bouton "Noter le mentoré" et Indicateur de statut
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Bouton Noter
                ElevatedButton(
                  onPressed: () {
                    // Logique pour naviguer vers la page de notation
                    print('Noter ${mentore.nom}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Noter le mentoré',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),
                // Indicateur de statut (cercle bleu)
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

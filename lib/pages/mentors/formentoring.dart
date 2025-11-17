// mentoring_page.dart

import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/pages/mentors/formentoringdetails.dart';
import 'package:repartir_frontend/services/mentor_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';

// --- Constantes de Style ---
const Color primaryBlue = Color(0xFF3EB2FF); // Bleu foncé
const Color kAccentColor = Color(0xFFB3E5FC); // Bleu clair
const Color kBackgroundColor = Color(0xFFF5F5F5); // Fond légèrement gris

// Modèle de données statique pour une demande de mentoring
class DemandeMentoring {
  final String nom;
  // On pourrait ajouter d'autres champs ici, ex: final String formation;

  DemandeMentoring(this.nom);
}

class MentoringPage extends StatefulWidget {
  const MentoringPage({super.key});

  @override
  State<MentoringPage> createState() => _MentoringPageState();
}

class _MentoringPageState extends State<MentoringPage> {
  final MentorService _mentorService = MentorService();
  final ProfileService _profileService = ProfileService();

  bool _loading = true;
  List<Map<String, dynamic>> _demandesEnAttente = [];

  @override
  void initState() {
    super.initState();
    _loadDemandes();
  }

  Future<void> _loadDemandes() async {
    setState(() => _loading = true);
    try {
      // Récupérer l'ID du mentor connecté
      final me = await _profileService.getMe();
      final mentorId = me['id'] as int;

      // Récupérer tous les mentorings du mentor
      final mentorings = await _mentorService.getMentorMentorings(mentorId);

      // Filtrer les demandes EN_ATTENTE uniquement
      final enAttente = mentorings.where((m) => m['statut'] == 'EN_ATTENTE').toList();

      setState(() {
        _demandesEnAttente = enAttente;
        _loading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement demandes: $e');
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
                      onRefresh: _loadDemandes,
                      child: _demandesEnAttente.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Aucune demande en attente',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(16, 30, 16, 100),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _demandesEnAttente.length,
                                itemBuilder: (context, index) {
                                  final demande = _demandesEnAttente[index];
                                  return DemandeTileAPI(
                                    demande: demande,
                                    onTap: () async {
                                      // ✅ Attendre le résultat de la page de détails
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DemandeDetailsPageAPI(
                                            demande: demande,
                                            onUpdate: _loadDemandes,
                                          ),
                                        ),
                                      );
                                      // ✅ Rafraîchir si changement
                                      if (result == true) {
                                        print('✅ Retour avec changement, rechargement...');
                                        await _loadDemandes();
                                      }
                                    },
                                  );
                                },
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
              title: "Mentoring",
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget réutilisable pour chaque élément de la liste
class DemandeTile extends StatelessWidget {
  final DemandeMentoring demande;

  const DemandeTile({super.key, required this.demande});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2, // Légère ombre pour soulever la carte
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
        child: Row(
          children: <Widget>[
            // Avatar (Style pour imiter l'image)
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 15),
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

            // Nom de l'utilisateur
            Expanded(
              child: Text(
                demande.nom,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),

            // Bouton "Voir"
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: ElevatedButton(
                onPressed: () {
                  // Logique de navigation vers la page de détail de la demande
                  /**
                   * On navigue vers la page qui affiche les détals de la démande
                   */
                  final detail = DetailDemande(
                    nom: demande.nom,
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
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  elevation: 0,
                ),
                child: const Text('Voir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ WIDGETS API ============

/// Widget pour afficher une demande depuis l'API
class DemandeTileAPI extends StatelessWidget {
  final Map<String, dynamic> demande;
  final VoidCallback onTap;

  const DemandeTileAPI({super.key, required this.demande, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prenom = (demande['prenomJeune'] ?? '').toString().trim();
    final nom = (demande['nomJeune'] ?? '').toString().trim();
    final nomComplet = '$prenom $nom'.trim();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: <Widget>[
              // Avatar
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryBlue.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.blueGrey,
                ),
              ),

              // Nom du jeune
              Expanded(
                child: Text(
                  nomComplet.isNotEmpty ? nomComplet : 'Jeune',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Icône flèche
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page de détails d'une demande depuis l'API
class DemandeDetailsPageAPI extends StatefulWidget {
  final Map<String, dynamic> demande;
  final VoidCallback onUpdate;

  const DemandeDetailsPageAPI({
    super.key,
    required this.demande,
    required this.onUpdate,
  });

  @override
  State<DemandeDetailsPageAPI> createState() => _DemandeDetailsPageAPIState();
}

class _DemandeDetailsPageAPIState extends State<DemandeDetailsPageAPI> {
  final MentorService _mentorService = MentorService();
  bool _loading = false;

  Future<void> _accepterDemande() async {
    setState(() => _loading = true);
    try {
      final mentoringId = widget.demande['id'] as int;
      await _mentorService.accepterMentoring(mentoringId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande acceptée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        // ✅ Retourner true pour signaler un changement
        Navigator.pop(context, true);
        // ✅ Rafraîchir après le pop
        Future.delayed(const Duration(milliseconds: 100), () {
          widget.onUpdate();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refuserDemande() async {
    setState(() => _loading = true);
    try {
      final mentoringId = widget.demande['id'] as int;
      await _mentorService.refuserMentoring(mentoringId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande refusée.'),
            backgroundColor: Colors.orange,
          ),
        );
        // ✅ Retourner true pour signaler un changement
        Navigator.pop(context, true);
        // ✅ Rafraîchir après le pop
        Future.delayed(const Duration(milliseconds: 100), () {
          widget.onUpdate();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prenom = (widget.demande['prenomJeune'] ?? '').toString().trim();
    final nom = (widget.demande['nomJeune'] ?? '').toString().trim();
    final nomComplet = '$prenom $nom'.trim();
    final objectif = (widget.demande['objectif'] ?? 'Objectif non spécifié').toString();
    final description = (widget.demande['description'] ?? '').toString().trim();
    
    // Debug: afficher les clés disponibles
    print('🔍 Clés demande de mentorat: ${widget.demande.keys.toList()}');
    print('📸 urlPhotoJeune: ${widget.demande['urlPhotoJeune']}');
    
    final screenWidth = MediaQuery.of(context).size.width;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Grande Carte des Détails
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Infos Nom et Avatar
                          Row(
                            children: [
                              // Avatar avec photo
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.white,
                                backgroundImage: (widget.demande['urlPhotoJeune'] != null && 
                                                 (widget.demande['urlPhotoJeune'] as String).isNotEmpty)
                                    ? NetworkImage(widget.demande['urlPhotoJeune'])
                                    : null,
                                child: (widget.demande['urlPhotoJeune'] == null || 
                                       (widget.demande['urlPhotoJeune'] as String).isEmpty)
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: primaryBlue, width: 3),
                                        ),
                                        child: const Icon(Icons.person, size: 35, color: Colors.blueGrey),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 15),
                              // Nom
                              Expanded(
                                child: Text(
                                  nomComplet.isNotEmpty ? nomComplet : 'Jeune',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Objectif
                          const Text(
                            'Objectif',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              objectif,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Description
                          if (description.isNotEmpty) ...[
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Bouton Accepter
                    ElevatedButton(
                      onPressed: _loading ? null : _accepterDemande,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Accepter la demande',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 15),

                    // Bouton Refuser
                    ElevatedButton(
                      onPressed: _loading ? null : _refuserDemande,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF9A9A).withValues(alpha: 0.5),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Refuser la demande',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
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
              title: "Mentoring",
              showBackButton: true,
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}

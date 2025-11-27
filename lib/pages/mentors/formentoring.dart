// mentoring_page.dart

import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
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
      debugPrint('❌ Erreur chargement demandes: $e');
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
                                        debugPrint('✅ Retour avec changement, rechargement...');
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
              height: 150,
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
    debugPrint('🔍 Clés demande de mentorat: ${widget.demande.keys.toList()}');
    debugPrint('📸 urlPhotoJeune: ${widget.demande['urlPhotoJeune']}');
    
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
                        gradient: LinearGradient(
                          colors: [
                            primaryBlue.withOpacity(0.08),
                            primaryBlue.withOpacity(0.16),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Infos Nom et Avatar
                          Row(
                            children: [
                              // Avatar avec photo
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryBlue, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ProfileAvatar(
                                  photoUrl: widget.demande['urlPhotoJeune']?.toString(),
                                  radius: 35,
                                  isPerson: true,
                                  backgroundColor: Colors.white,
                                  iconColor: Colors.blueGrey,
                                ),
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
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Objectif',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.flag, color: Color(0xFF0D47A1), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    objectif,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Description
                          if (description.isNotEmpty) ...[
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: primaryBlue,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                              ],
                            ),
                             const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.description, color: Color(0xFF0D47A1), size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Bouton Accepter
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF66BB6A).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _accepterDemande,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Accepter la demande',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Bouton Refuser
                    OutlinedButton(
                      onPressed: _loading ? null : _refuserDemande,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade400, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel, color: Colors.red.shade400),
                          const SizedBox(width: 8),
                          Text(
                            'Refuser la demande',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade400,
                            ),
                          ),
                        ],
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
              height: 150,
            ),
          ),
        ],
      ),
    );
  }

}

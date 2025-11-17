import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/mentors_service.dart';
import 'package:repartir_frontend/services/mentorings_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/services/api_service.dart';

// --- MODÈLE DE DONNÉES POUR UN MENTOR ---
// Utilisé pour passer les informations entre la page de liste et la page de détail.
class Mentor {
  final String name;
  final String specialty;
  final String experience;
  final String imageUrl;
  final String about;
  final int? id; // Ajout de l'ID pour récupérer les détails depuis l'API

  const Mentor({
    required this.name,
    required this.specialty,
    required this.experience,
    required this.imageUrl,
    required this.about,
    this.id,
  });
}

// --- PAGE DE DÉTAIL D'UN MENTOR ---
class MentorDetailPage extends StatefulWidget {
  final Mentor mentor;

  const MentorDetailPage({super.key, required this.mentor});

  @override
  State<MentorDetailPage> createState() => _MentorDetailPageState();
}

class _MentorDetailPageState extends State<MentorDetailPage> {
  final MentorsService _mentors = MentorsService();
  final MentoringsService _mentorings = MentoringsService();
  final ProfileService _profile = ProfileService();
  final ApiService _api = ApiService();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _mentorDetails;

  @override
  void initState() {
    super.initState();
    if (widget.mentor.id != null) {
      _fetchMentorDetails();
    } else {
      // Si pas d'ID, utiliser les données du mentor passé
      _mentorDetails = null;
    }
  }

  Future<void> _fetchMentorDetails() async {
    if (widget.mentor.id == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _mentorDetails = await _mentors.getById(widget.mentor.id!);
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Mentor _getMentorToDisplay() {
    // Si on a des détails depuis l'API, les utiliser
    if (_mentorDetails != null) {
      final u = _mentorDetails!['utilisateur'] ?? {};
      final prenom = (u['prenom'] ?? '').toString().trim();
      final nom = (u['nom'] ?? '').toString().trim();
      final name = prenom.isNotEmpty || nom.isNotEmpty
          ? '$prenom $nom'.trim()
          : widget.mentor.name;

      // Récupérer l'expérience - essayer plusieurs variantes
      dynamic anneesExp =
          _mentorDetails!['anneesExperience'] ??
          _mentorDetails!['anneeExperience'] ??
          _mentorDetails!['annees_experience'] ??
          _mentorDetails!['annee_experience'] ??
          _mentorDetails!['yearsOfExperience'] ??
          _mentorDetails!['years_of_experience'] ??
          _mentorDetails!['experience'] ??
          u['anneesExperience'] ??
          u['anneeExperience'];

      String experience = widget.mentor.experience;
      if (anneesExp != null) {
        if (anneesExp is int || anneesExp is double) {
          experience =
              '${anneesExp.toString().split('.').first} ans d\'expérience';
        } else if (anneesExp is String) {
          final expNum = int.tryParse(anneesExp);
          if (expNum != null) {
            experience = '$expNum ans d\'expérience';
          } else if (anneesExp.isNotEmpty) {
            experience = anneesExp;
          }
        }
      }

      return Mentor(
        name: name,
        specialty:
            (_mentorDetails!['specialite'] ??
                    _mentorDetails!['domaine'] ??
                    _mentorDetails!['profession'] ??
                    widget.mentor.specialty)
                .toString(),
        experience: experience,
        imageUrl:
            (u['urlPhoto'] ??
                    _mentorDetails!['urlPhoto'] ??
                    widget.mentor.imageUrl)
                .toString(),
        about:
            (_mentorDetails!['description'] ??
                    _mentorDetails!['a_propos'] ??
                    _mentorDetails!['aPropos'] ??
                    widget.mentor.about)
                .toString(),
        id: widget.mentor.id,
      );
    }
    // Sinon, utiliser les données du mentor passé
    return widget.mentor;
  }

  // Afficher le dialogue pour saisir description et objectif
  Future<void> _demanderMentorat() async {
    if (widget.mentor.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d\'envoyer la demande. Une erreur est survenue.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      
      debugPrint("Impossible d'envoyer la demande. Id du mentor manquant.");
      return;}
    

    // Afficher le dialogue de saisie
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _buildDemandeMentoratDialog(),
    );

    if (result == null) return; // Annulé

    // Envoyer la demande avec les données saisies
    setState(() => _loading = true);

    try {
      // Récupérer l'ID du jeune connecté
      final me = await _profile.getMe();
      final jeuneId = me['id'] as int;

      print(
        '📨 Création du mentoring: Mentor ${widget.mentor.id}, Jeune $jeuneId',
      );
      print('📨 Description: ${result['description']}');
      print('📨 Objectif: ${result['objectif']}');

      // Créer le mentoring avec les données saisies
      final mentoringResult = await _mentorings.createMentoring(
        widget.mentor.id!,
        jeuneId,
        result['description'],
        objectif: result['objectif'],
      );

      print('✅ Mentoring créé: $mentoringResult');

      // Afficher le dialogue de succès
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      print('❌ Erreur création mentoring: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Dialogue pour saisir description et objectif
  Widget _buildDemandeMentoratDialog() {
    final descriptionController = TextEditingController();
    final objectifController = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Demande de mentorat',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Color(0xFF3EB2FF),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Décrivez votre demande',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Exemple: Bonjour, je souhaiterais bénéficier de votre accompagnement pour...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Votre objectif',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: objectifController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Exemple: Développer mes compétences en...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final description = descriptionController.text.trim();
            final objectif = objectifController.text.trim();

            if (description.isEmpty || objectif.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Veuillez remplir tous les champs'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            Navigator.pop(context, {
              'description': description,
              'objectif': objectif,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3EB2FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Envoyer'),
        ),
      ],
    );
  }

  // Affiche un modal de confirmation stylisé
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Demande envoyée',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Votre demande a bien été envoyée au mentor. Vous recevrez une notification dès qu\'il ou elle aura répondu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(fontSize: 16)),
              onPressed: () {
                // Ferme le dialogue
                Navigator.of(context).pop();
                // Revient à la page précédente (liste des mentors)
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryBlue = Color(0xFF3EB2FF);
    final mentorToDisplay = _getMentorToDisplay();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Contenu principal
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- CARTE D'INFORMATION DU MENTOR ---
                        _buildMentorInfoCard(kPrimaryBlue, mentorToDisplay),
                        const SizedBox(height: 24),

                        // --- SECTION "À PROPOS" ---
                        const Text(
                          'À propos du mentor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mentorToDisplay.about,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- CHAMP "OBJECTIF" ---
                        const Text(
                          'Objectif',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Décrivez votre objectif principal...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),

                        // --- CHAMP "DESCRIPTION" ---
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText:
                                'Donnez plus de détails sur votre projet ou vos attentes...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 32),

                        // --- BOUTON DE DEMANDE ---
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: _loading ? null : _demanderMentorat,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Demander à être mentoré par ce mentor',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      
                      
                      
                      ],
                    ),
                  ),
          ),

          // Header avec bouton retour et titre
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              title: 'Détail Mentor',
              height: 120,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour la carte bleue d'information du mentor
  Widget _buildMentorInfoCard(Color color, Mentor mentor) {
    return Container(
      width: double.infinity, // Occupe toute la largeur
      padding: const EdgeInsets.symmetric(
        vertical: 24,
      ), // Ajustement du padding
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.9),
            backgroundImage:
                mentor.imageUrl.isNotEmpty &&
                    mentor.imageUrl !=
                        'https://placehold.co/150/EFEFEF/333333?text=M' &&
                    !mentor.imageUrl.contains('placeholder')
                ? NetworkImage(mentor.imageUrl)
                : null,
            onBackgroundImageError:
                mentor.imageUrl.isNotEmpty &&
                    mentor.imageUrl !=
                        'https://placehold.co/150/EFEFEF/333333?text=M' &&
                    !mentor.imageUrl.contains('placeholder')
                ? (_, __) {}
                : null,
            child:
                mentor.imageUrl.isEmpty ||
                    mentor.imageUrl ==
                        'https://placehold.co/150/EFEFEF/333333?text=M' ||
                    mentor.imageUrl.contains('placeholder')
                ? CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.blue[100]!,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            mentor.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (mentor.specialty.isNotEmpty && mentor.specialty != '—')
            Text(
              mentor.specialty,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          if (mentor.experience.isNotEmpty && mentor.experience != '—') ...[
            const SizedBox(height: 4),
            Text(
              mentor.experience,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

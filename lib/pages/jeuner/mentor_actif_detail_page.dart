import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/services/mentorings_service.dart';

const Color primaryBlue = Color(0xFF3EB2FF);
const Color primaryGreen = Color(0xFF4CAF50);

/// Page de détails d'un mentor actif avec possibilité de noter
class MentorActifDetailPage extends StatefulWidget {
  final Map<String, dynamic> mentoring;

  const MentorActifDetailPage({super.key, required this.mentoring});

  @override
  State<MentorActifDetailPage> createState() => _MentorActifDetailPageState();
}

class _MentorActifDetailPageState extends State<MentorActifDetailPage> {
  final MentoringsService _mentoringsService = MentoringsService();
  int _selectedNote = 0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Note actuelle du jeune sur ce mentor
    _selectedNote = widget.mentoring['noteJeune'] ?? 0;
  }

  Future<void> _attribuerNote() async {
    if (_selectedNote == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une note'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final mentoringId = widget.mentoring['id'] as int;
      await _mentoringsService.noterMentor(mentoringId, _selectedNote);

      // Mettre à jour immédiatement la note dans le widget
      setState(() {
        widget.mentoring['noteJeune'] = _selectedNote;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note attribuée avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Informer la page parent que les données ont changé
        // On attend 800ms pour laisser l'utilisateur voir le message
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            Navigator.pop(context, true); // ✅ Signaler un changement
          }
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
    final prenom = (widget.mentoring['prenomMentor'] ?? '').toString().trim();
    final nom = (widget.mentoring['nomMentor'] ?? '').toString().trim();
    final nomComplet = '$prenom $nom'.trim();
    final specialite = (widget.mentoring['specialiteMentor'] ?? '').toString().trim();
    final experience = widget.mentoring['anneesExperienceMentor'] ?? 0;
    final objectif = (widget.mentoring['objectif'] ?? '').toString().trim();
    final description = (widget.mentoring['description'] ?? '').toString().trim();
    final urlPhoto = (widget.mentoring['urlPhotoMentor'] ?? '').toString().trim();
    
    // Debug: Vérifier l'URL de la photo
    debugPrint('📸 Page note mentor - Photo URL: $urlPhoto');

    // Calculer la durée
    int dureeMois = 0;
    final dateDebutStr = widget.mentoring['dateDebut']?.toString();
    if (dateDebutStr != null && dateDebutStr.isNotEmpty) {
      try {
        final dateDebut = DateTime.parse(dateDebutStr);
        final maintenant = DateTime.now();
        dureeMois = ((maintenant.difference(dateDebut).inDays) / 30).round();
      } catch (e) {
        print('Erreur parsing date: $e');
      }
    }

    final noteJeune = widget.mentoring['noteJeune'] ?? 0;
    final noteMentor = widget.mentoring['noteMentor'] ?? 0;

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
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Avatar et informations
                    Center(
                      child: Column(
                        children: [
                          ProfileAvatar(
                            photoUrl: urlPhoto,
                            radius: 60,
                            isPerson: true,
                            backgroundColor: primaryBlue.withOpacity(0.1),
                            iconColor: primaryBlue,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            nomComplet.isNotEmpty ? nomComplet : 'Mentor',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (specialite.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              specialite,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                          if (experience > 0) ...[
                            const SizedBox(height: 5),
                            Text(
                              '$experience ans d\'expérience',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 5),
                          Text(
                            'Mentorat depuis $dureeMois mois',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Section Objectif
                    if (objectif.isNotEmpty) ...[
                      _buildSectionTitle('Mon Objectif', Icons.flag),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryBlue.withOpacity(0.2)),
                        ),
                        child: Text(
                          objectif,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Section Description
                    if (description.isNotEmpty) ...[
                      _buildSectionTitle('Description', Icons.description),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Section Progression
                    _buildSectionTitle('Progression', Icons.star),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildScoreCard(
                            'Ma Note',
                            noteJeune,
                            20,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildScoreCard(
                            'Note du Mentor',
                            noteMentor,
                            20,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Section Attribution de note
                    _buildSectionTitle('Noter mon mentor', Icons.grade),
                    const SizedBox(height: 15),
                    
                    // Sélecteur de note (0-20)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: primaryBlue.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (_selectedNote > 0) {
                                    setState(() => _selectedNote--);
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                iconSize: 36,
                                color: primaryBlue,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: primaryBlue, width: 2),
                                  ),
                                  child: Text(
                                    '$_selectedNote / 20',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () {
                                  if (_selectedNote < 20) {
                                    setState(() => _selectedNote++);
                                  }
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                iconSize: 36,
                                color: primaryBlue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Slider pour note rapide
                          Slider(
                            value: _selectedNote.toDouble(),
                            min: 0,
                            max: 20,
                            divisions: 20,
                            label: _selectedNote.toString(),
                            activeColor: primaryBlue,
                            onChanged: (value) {
                              setState(() => _selectedNote = value.toInt());
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Bouton valider la note
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _attribuerNote,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Attribuer la note',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
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
            child: const CustomHeader(
              title: 'Mon Mentor',
              showBackButton: true,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(String label, int score, int maxScore, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score / $maxScore',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}


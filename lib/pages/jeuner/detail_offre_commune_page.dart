import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/custom_header.dart';
import 'package:repartir_frontend/services/offre_service.dart';
import 'package:repartir_frontend/models/offre_emploi.dart';

class DetailOffreCommunePage extends StatefulWidget {
  final Map<String, dynamic>? offre;
  final int? offreId;

  const DetailOffreCommunePage({
    super.key,
    this.offre,
    this.offreId,
  });

  @override
  State<DetailOffreCommunePage> createState() => _DetailOffreCommunePageState();
}

class _DetailOffreCommunePageState extends State<DetailOffreCommunePage> {
  final OffreService _offreService = OffreService();
  OffreEmploi? _offre;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.offreId != null) {
      _loadOffre();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadOffre() async {
    if (widget.offreId == null) return;
    
    try {
      final offre = await _offreService.getOffreById(widget.offreId!);
      setState(() {
        _offre = offre;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $_errorMessage')),
        );
      }
    }
  }

  Map<String, dynamic> get _offreData {
    if (_offre != null) {
      return {
        'titre': _offre!.titre,
        'type_contrat': _offre!.typeContrat ?? '',
        'entreprise': _offre!.nomEntreprise ?? '',
        'lieu': '',
        'datePublication': _offre!.dateDebut?.toString() ?? '',
        'description': _offre!.description,
        'competence': _offre!.competence ?? '',
        'date_debut': _offre!.dateDebut?.toIso8601String() ?? '',
        'date_fin': _offre!.dateFin?.toIso8601String() ?? '',
        'lien_postuler': _offre!.lienPostuler ?? '',
        'logo': 'https://via.placeholder.com/150',
      };
    }
    
    // Fallback sur widget.offre si fourni
    return widget.offre ?? {
      'titre': 'Offre non disponible',
      'type_contrat': '',
      'entreprise': '',
      'lieu': '',
      'datePublication': '',
      'description': '',
      'competence': '',
      'date_debut': '',
      'date_fin': '',
      'lien_postuler': '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final offreData = _offreData;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Contenu principal
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: _isLoading && widget.offreId != null
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage ?? 'Erreur inconnue'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadOffre,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  _buildSection(
                    'Titre',
                    offreData['titre'] ?? 'Titre non disponible',
                  ),
                  const SizedBox(height: 16),

                  // Description du poste
                  _buildSection(
                    'Description',
                    offreData['description'] ?? 'Aucune description disponible.',
                  ),
                  const SizedBox(height: 16),

                  // Date de début
                  _buildSection(
                    'Date de début',
                    _formatDate(offreData['date_debut']) ?? 'Non spécifiée',
                  ),
                  const SizedBox(height: 16),

                  // Date de fin
                  _buildSection(
                    'Date de fin',
                    _formatDate(offreData['date_fin']) ?? 'Non spécifiée',
                  ),
                  const SizedBox(height: 16),

                  // Type de contrat
                  _buildSection(
                    'Type de contrat',
                    offreData['type_contrat'] ?? 'Non spécifié',
                  ),
                  const SizedBox(height: 16),

                  // Compétences recherchées
                  _buildSection(
                    'Compétences',
                    offreData['competence'] ?? 'Aucune compétence spécifiée.',
                  ),
                  const SizedBox(height: 16),

                  // Section candidature
                  _buildApplySection(offreData),
                  const SizedBox(height: 20),
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
              title: 'Détail de l\'offre',
              height: 120,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3EB2FF),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplySection(Map<String, dynamic> offreData) {
    final lienCandidature = offreData['lien_postuler'] ?? 
        'https://www.youtube.com/watch?v=e9J6sI5YBOo&list=RDHGBek8t3x5I&index=5';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link,
                color: const Color(0xFF3EB2FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Lien pour postuler',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3EB2FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          InkWell(
            onTap: () => _ouvrirLien(lienCandidature),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF3EB2FF),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.open_in_new,
                    color: const Color(0xFF3EB2FF),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lienCandidature,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3EB2FF),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.touch_app,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Cliquez sur le lien pour l\'ouvrir dans votre navigateur',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    
    try {
      // Parse la date au format "2025-12-01 21:00:00.000000"
      final DateTime date = DateTime.parse(dateString);
      // Formate en français
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString; // Retourne la chaîne originale si le parsing échoue
    }
  }

  Future<void> _ouvrirLien(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Impossible d\'ouvrir le lien'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ouverture du lien: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}

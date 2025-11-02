import 'package:flutter/material.dart';
import 'package:repartir_frontend/services/formation_service.dart';
import 'package:repartir_frontend/models/notification.dart';

// Constantes de couleurs pour un style cohérent
const Color kPrimaryBlue = Color(0xFF007BFF);
const Color kLightGrey = Color(0xFFF0F0F0);
const Color kDarkText = Color(0xFF333333);
const Color kLightText = Color(0xFF757575);

class MesFormationsPage extends StatefulWidget {
  const MesFormationsPage({super.key});

  @override
  State<MesFormationsPage> createState() => _MesFormationsPageState();
}

class _MesFormationsPageState extends State<MesFormationsPage> {
  final FormationService _formationService = FormationService();
  List<InscriptionResponse> _inscriptions = [];
  bool _isLoading = true;
  String? _errorMessage;
  // Booléen pour gérer l'état du toggle : true = En cours, false = Terminées
  bool _showEnCours = true;

  @override
  void initState() {
    super.initState();
    _loadInscriptions();
  }

  Future<void> _loadInscriptions() async {
    try {
      final inscriptions = await _formationService.getMesInscriptions();
      setState(() {
        _inscriptions = inscriptions;
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

  List<InscriptionResponse> get _inscriptionsEnCours {
    return _inscriptions.where((inscription) {
      final statut = inscription.statut?.toUpperCase() ?? '';
      return statut == 'EN_ATTENTE' || statut == 'ACCEPTEE' || statut == 'EN_COURS' || statut == 'VALIDE';
    }).toList();
  }

  List<InscriptionResponse> get _inscriptionsTerminees {
    return _inscriptions.where((inscription) {
      final statut = inscription.statut?.toUpperCase() ?? '';
      return statut == 'TERMINEE';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightGrey,
      appBar: AppBar(
        backgroundColor: kLightGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kDarkText),
          onPressed: () {
            // Le bouton retour renvoie à la page d'accueil
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Mes formations',
          style: TextStyle(
            color: kDarkText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // --- Toggle Buttons ---
            _buildToggleButtons(),
            const SizedBox(height: 30),
            // --- Titre de la section ---
            Text(
              _showEnCours ? 'Formations en cours' : 'Formations Terminées',
              style: const TextStyle(
                color: kDarkText,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            // --- Contenu conditionnel ---
            Expanded(
              child: _isLoading
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
                                onPressed: _loadInscriptions,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : _showEnCours ? _buildFormationsEnCours() : _buildFormationsTerminees(),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pour les boutons toggle "En cours" et "Terminées"
  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showEnCours = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showEnCours ? kPrimaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    'En cours',
                    style: TextStyle(
                      color: _showEnCours ? Colors.white : kDarkText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showEnCours = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showEnCours ? kPrimaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    'Terminées',
                    style: TextStyle(
                      color: !_showEnCours ? Colors.white : kDarkText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la liste des formations "En cours"
  Widget _buildFormationsEnCours() {
    final inscriptions = _inscriptionsEnCours;
    
    if (inscriptions.isEmpty) {
      return const Center(child: Text('Aucune formation en cours'));
    }

    return ListView.builder(
      itemCount: inscriptions.length,
      itemBuilder: (context, index) {
        final inscription = inscriptions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildCoursEnCoursCard(
            inscription: inscription,
          ),
        );
      },
    );
  }

  /// Construit la liste des formations "Terminées"
  Widget _buildFormationsTerminees() {
    final inscriptions = _inscriptionsTerminees;
    
    if (inscriptions.isEmpty) {
      return const Center(child: Text('Aucune formation terminée'));
    }

    return ListView.builder(
      itemCount: inscriptions.length,
      itemBuilder: (context, index) {
        final inscription = inscriptions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildCoursTermineCard(
            inscription: inscription,
          ),
        );
      },
    );
  }

  /// Widget pour une carte de formation en cours
  Widget _buildCoursEnCoursCard({required InscriptionResponse inscription}) {
    final title = inscription.formation?.titre ?? inscription.titreFormation;
    final logoUrl = inscription.formation?.centre?.logo;
    
    // Calculer le pourcentage de progression (simplifié - peut être amélioré avec les dates)
    double progress = 0.5; // Par défaut 50%
    if (inscription.formation?.date_debut != null && inscription.formation?.date_fin != null) {
      final now = DateTime.now();
      final debut = inscription.formation!.date_debut!;
      final fin = inscription.formation!.date_fin!;
      final total = fin.difference(debut).inDays;
      final passed = now.difference(debut).inDays;
      if (total > 0) {
        progress = (passed / total).clamp(0.0, 1.0);
      }
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image de la formation
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: logoUrl != null
                ? Image.network(
                    logoUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.school),
                      );
                    },
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.school),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: kDarkText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade300,
                        color: progress > 0.5 ? kPrimaryBlue : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kLightText,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Progression',
                  style: TextStyle(color: kLightText, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget pour une carte de formation terminée
  Widget _buildCoursTermineCard({required InscriptionResponse inscription}) {
    final title = inscription.formation?.titre ?? inscription.titreFormation;
    final logoUrl = inscription.formation?.centre?.logo;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image de la formation
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: logoUrl != null
                ? Image.network(
                    logoUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.school),
                      );
                    },
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.school),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: kDarkText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.workspace_premium_outlined, color: Colors.orange.shade600, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Certificat obtenu',
                      style: TextStyle(
                        color: kLightText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



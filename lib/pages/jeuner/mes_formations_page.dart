import 'package:flutter/material.dart';
import 'package:repartir_frontend/services/inscriptions_service.dart';
import 'package:repartir_frontend/services/api_service.dart';
import 'package:repartir_frontend/pages/jeuner/formation_detail_page.dart';

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
  // Booléen pour gérer l'état du toggle : true = En cours, false = Terminées
  bool _showEnCours = true;
  final InscriptionsService _inscriptions = InscriptionsService();
  final ApiService _api = ApiService();
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _formations = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final isConnected = await _api.hasToken();
      if (!isConnected) {
        throw Exception('Vous devez être connecté pour voir vos formations.');
      }
      _formations = await _inscriptions.mesInscriptions();
    
      //cacher les formation annulées
       _formations = _formations.where((f) {
        final statut = (f['formation']?['statut'] ?? '').toString().toUpperCase();
        return statut != 'ANNULER';
      }).toList();
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _formationsEnCours {
    final now = DateTime.now();
    return _formations.where((f) {
      final dateFin = f['formation']?['date_fin']?.toString();
      if (dateFin == null || dateFin.isEmpty) return true; // En cours si pas de date de fin
      try {
        final fin = DateTime.parse(dateFin);
        return fin.isAfter(now);
      } catch (_) {
        return true;
      }
    }).toList();
  }

  List<Map<String, dynamic>> get _formationsTerminees {
    final now = DateTime.now();
    return _formations.where((f) {
      final dateFin = f['formation']?['date_fin']?.toString();
      if (dateFin == null || dateFin.isEmpty) return false;
      try {
        final fin = DateTime.parse(dateFin);
        return fin.isBefore(now) || fin.isAtSameMomentAs(now);
      } catch (_) {
        return false;
      }
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : RefreshIndicator(
                          onRefresh: _fetch,
                          child: _showEnCours ? _buildFormationsEnCours() : _buildFormationsTerminees(),
                        ),
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
    final formations = _formationsEnCours;
    if (formations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Aucune formation en cours',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: formations.length,
      itemBuilder: (context, index) {
        final inscription = formations[index];
        final formation = inscription['formation'] ?? {};
        final titre = (formation['titre'] ?? '—').toString();
        final progress = inscription['progression'] ?? 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCoursEnCoursCard(
            title: titre,
            progress: progress is double ? progress : (progress is int ? progress / 100.0 : 0.0),
            formationId: formation['id'],
          ),
        );
      },
    );
  }

  /// Construit la liste des formations "Terminées"
  Widget _buildFormationsTerminees() {
    final formations = _formationsTerminees;
    if (formations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Aucune formation terminée',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: formations.length,
      itemBuilder: (context, index) {
        final inscription = formations[index];
        final formation = inscription['formation'] ?? {};
        final titre = (formation['titre'] ?? '—').toString();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCoursTermineCard(
            title: titre,
            formationId: formation['id'],
          ),
        );
      },
    );
  }

  /// Widget pour une carte de formation en cours
  Widget _buildCoursEnCoursCard({required String title, required double progress, int? formationId}) {
    return GestureDetector(
      onTap: formationId != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormationDetailPage(formationId: formationId),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha:0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Placeholder pour l'image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, color: Colors.grey),
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
      ),
    );
  }

  /// Widget pour une carte de formation terminée
  Widget _buildCoursTermineCard({required String title, int? formationId}) {
    return GestureDetector(
      onTap: formationId != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormationDetailPage(formationId: formationId),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha:0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Placeholder pour l'image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, color: Colors.grey),
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
      ),
    );
  }
}



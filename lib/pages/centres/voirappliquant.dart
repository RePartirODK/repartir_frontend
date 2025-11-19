import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/models/response/response_inscription.dart';
import 'package:repartir_frontend/services/centre_service.dart';
import 'package:repartir_frontend/services/jeune_service.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

// Définition des constantes
const Color kPrimaryColor = Color(0xFF3EB2FF);
const double kHeaderHeight = 200.0;

// **************************************************
// 1. MODÈLES DE DONNÉES
// **************************************************

class Applicant {
  final String name;
  final Color avatarColor;
  final IconData icon;
  final List<OngoingFormation> ongoingFormations;
  final List<CompletedFormation> completedFormations;

  Applicant({
    required this.name,
    required this.avatarColor,
    required this.icon,
    required this.ongoingFormations,
    required this.completedFormations,
  });
}

class OngoingFormation {
  final String title;
  final int progressPercent;

  OngoingFormation({required this.title, required this.progressPercent});
}

class CompletedFormation {
  final String title;

  CompletedFormation({required this.title});
}

// Données statiques simulées pour Moussa Touré
final Applicant moussaToure = Applicant(
  name: 'Moussa Touré',
  avatarColor: Colors.cyan[600]!,
  icon: Icons.person_4_sharp,
  ongoingFormations: [
    OngoingFormation(title: 'Initiation au design UX/UI', progressPercent: 65),
    OngoingFormation(
      title: 'Communication professionnelle',
      progressPercent: 30,
    ),
  ],
  completedFormations: [
    CompletedFormation(title: 'Mecanique'),
    CompletedFormation(title: 'Secretariat'),
  ],
);

// **************************************************
// 2. WIDGET STATEFUL DE LA PAGE PROFIL
// **************************************************

class ApplicantProfilePage extends StatefulWidget {
  const ApplicantProfilePage({super.key, this.inscription});
  final ResponseInscription? inscription;

  @override
  // ignore: library_private_types_in_public_api
  _ApplicantProfilePageState createState() => _ApplicantProfilePageState();
}

class _ApplicantProfilePageState extends State<ApplicantProfilePage> {
  // Index 2 pour "Formations" dans la BottomNavigationBar (comme dans vos images)
  int _selectedIndex = 2;

  // État pour basculer entre les onglets : 'En cours' ou 'Terminés'
  String _currentTab = 'Terminés';
  final CentreService _centreService = CentreService();
  final SecureStorageService _storage = SecureStorageService();
  final JeuneService _jeuneService = JeuneService();
  bool _loading = true;
  String? _error;
  List<ResponseInscription> _inscriptionsJeune = [];
  Map<String, ResponseFormation> _formationsByTitle = {};
  String? _avatarUrl;

  // Fonction de mise à jour pour la BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      debugPrint("Navigating to index: $_selectedIndex");
    });
  }

  // Fonction de mise à jour pour le Toggle Button
  void _setTab(String tabName) {
    setState(() {
      _currentTab = tabName;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadApplicantData();
  }

  Future<void> _loadApplicantData() async {
    try {
      final centreId = int.tryParse(await _storage.getUserId() ?? '0') ?? 0;
      final all = await _centreService.getCentreInscriptions(centreId);
      final targetName = widget.inscription?.nomJeune ?? '';
      final filtered = all.where((e) => e.nomJeune == targetName).toList();

      final formations = await _centreService.getAllFormations(centreId);
      final map = <String, ResponseFormation>{};
      for (final f in formations) {
        // Exclude canceled formations
        final s = (f.statut).toString().toUpperCase();
        if (s == 'ANNULER') continue;
        map[f.titre] = f;
      }

      // Avatar du jeune (via liste des jeunes)
      final jeunes = await _jeuneService.listAll();
      String? urlPhoto;
      for (final j in jeunes) {
        final u = j['utilisateur'] as Map<String, dynamic>? ?? {};
        final prenom = (j['prenom'] ?? '').toString();
        final nom = (u['nom'] ?? '').toString();
        final full = (prenom.isNotEmpty || nom.isNotEmpty)
            ? '$prenom $nom'.trim()
            : '';
        if (full == targetName) {
          urlPhoto = (u['urlPhoto'] ?? '').toString();
          break;
        }
      }

      setState(() {
        _inscriptionsJeune = filtered;
        _formationsByTitle = map;
        _avatarUrl = (urlPhoto != null && urlPhoto.isNotEmpty)
            ? urlPhoto
            : null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : _error != null
          ? Center(child: Text('Erreur: $_error'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // 1. Header Incurvé
                CustomHeader(title: "Formations", showBackButton: true),

                // 2. Contenu scrollable (y compris le titre, l'avatar et les listes)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        // 2.1. Titre et Flèche de Retour
                        _buildHeaderFromInscription(widget.inscription),

                        // 2.2. Toggle Button (En cours / Terminés)
                        _buildToggleButtons(),

                        const SizedBox(height: 20),

                        // 2.3. Contenu Dynamique (Liste des formations)
                        _buildFormationListFromInscription(widget.inscription),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // --- Widgets de construction des sections ---

  Widget _buildHeaderFromInscription(ResponseInscription? inscription) {
    final String name = inscription?.nomJeune.isNotEmpty == true
        ? inscription!.nomJeune
        : 'Appliquant';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 15.0,
            bottom: 20.0,
            left: 20,
            right: 20,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [SizedBox(width: 48)],
          ),
        ),
        CircleAvatar(
          radius: 50,
          backgroundColor: kPrimaryColor.withValues(alpha: 0.8),
          backgroundImage: _avatarUrl != null
              ? NetworkImage(_avatarUrl!)
              : null,
          child: _avatarUrl == null
              ? const Icon(Icons.person, color: Colors.white, size: 60)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: <Widget>[
            _buildToggleItem('En cours'),
            _buildToggleItem('Terminés'),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title) {
    final bool isSelected = _currentTab == title;
    return Expanded(
      child: InkWell(
        onTap: () => _setTab(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.3),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormationListFromInscription(ResponseInscription? inscription) {
    final now = DateTime.now();
    final ongoing = <String>[];
    final completed = <String>[];

    for (final insc in _inscriptionsJeune) {
      final f = _formationsByTitle[insc.titreFormation];
      if (f == null) continue;
      final start = f.dateDebut;
      final end = f.dateFin;
      if (now.isAfter(end)) {
        completed.add(f.titre);
      } else if (now.isAfter(start) && now.isBefore(end)) {
        ongoing.add(f.titre);
      }
    }
    if (_currentTab == 'En cours') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Formations en cours",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            if (ongoing.isEmpty)
              const Text(
                "Aucune formation en cours",
                style: TextStyle(color: Colors.black54),
              )
            else
              ...ongoing.map(_buildOngoingFormationCardFromInscription),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Formations terminées",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            if (completed.isEmpty)
              const Text(
                "Aucune formation terminée",
                style: TextStyle(color: Colors.black54),
              )
            else
              ...completed.map(
                (t) => _buildCompletedFormationCardFromInscription(
                  t,
                  isCertified: _isCertifiedForTitle(t),
                ),
              ),
          ],
        ),
      );
    }
  }

  Widget _buildOngoingFormationCardFromInscription(String titreFormation) {
      final f = _formationsByTitle[titreFormation];
    double progress = 0.0;
    if (f != null) {
      final start = f.dateDebut;
      final end = f.dateFin;
      final now = DateTime.now();
      if (now.isBefore(start)) {
        progress = 0.0;
      } else if (now.isAfter(end)) {
        progress = 1.0;
      } else {
        final total = end.difference(start).inSeconds;
        final elapsed = now.difference(start).inSeconds;
        progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;
      }
   }
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.groups, color: kPrimaryColor, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titreFormation,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
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

  Widget _buildCompletedFormationCardFromInscription(
    String titreFormation, {
    required bool isCertified,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.black54,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Row(
                children: [
                  Text(
                    titreFormation,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (isCertified) ...[
                    const Icon(
                      Icons.workspace_premium,
                      color: Colors.amber,
                      size: 30,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Certificié',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isCertifiedForTitle(String titre) {
    for (final insc in _inscriptionsJeune) {
      if (insc.titreFormation == titre && insc.certifie == true) {
        return true;
      }
    }
    return false;
  }
}

import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/pages/parrains/pagepaiement.dart';
import 'package:repartir_frontend/services/centre_service.dart';
import 'package:repartir_frontend/services/centres_service.dart';
import 'package:repartir_frontend/services/formations_service.dart';
import 'package:repartir_frontend/services/jeune_service.dart';

// Assurez-vous d'avoir CustomBottomNavBar, CustomShapeClipper, primaryBlue, et primaryGreen définis
// Si vous utilisez des fichiers séparés, n'oubliez pas d'importer :
// import 'custom_bottom_nav_bar.dart';
// import 'custom_shape_clipper.dart';

// Définition des couleurs
const Color primaryBlue = Color(0xFF3EB2FF);
const Color primaryGreen = Color(0xFF4CAF50);
const Color lightRed = Color(0xFFFDD8D8); // Couleur pour le badge "En attente"

// --- DÉBUT DE LA CLASSE DE NAVIGATION (Copie pour référence si vous l'avez perdue) ---

// --- PAGE PRINCIPALE ---
class DetailPage extends StatefulWidget {
  const DetailPage({
    super.key,
    required this.idJeune,
    required this.idFormation,
    required this.idParrainage,
  });
  final int idJeune;
  final int idFormation;
  final int idParrainage;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // Données factices pour l'exemple

  //pour les données réelles
  final _jeuneService = JeuneService();
  final _formationsService = FormationsService();
  final _centresService = CentresService();

  bool _loading = true;
  String? _error;

  // Fetched data
  String _jeuneName = '—';
  String? _jeunePhotoUrl;
  String _centreSituation = '—';
  String _centreName = '—';
  String _email = '—';
  String _telephone = '—';
  ResponseFormation? _formation;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      // Fetch all jeunes and find the one with the given id
      final jeunes = await _jeuneService.listAll();
      final jeune = jeunes.firstWhere(
        (j) =>
            (j['id'] is int
                ? j['id'] as int
                : int.tryParse(j['id']?.toString() ?? '') ?? 0) ==
            widget.idJeune,
        orElse: () => {},
      );
      final utilisateur = jeune['utilisateur'] as Map<String, dynamic>? ?? {};
      final prenom = (jeune['prenom'] ?? '').toString();
      final nom = (utilisateur['nom'] ?? '').toString();
      _jeuneName = (prenom.isNotEmpty || nom.isNotEmpty)
          ? '$prenom $nom'.trim()
          : 'Jeune #${widget.idJeune}';
      _jeunePhotoUrl = utilisateur['urlPhoto'] as String?;

      // Fetch formation details by id
      final f = await _formationsService.details(widget.idFormation);
      _formation = ResponseFormation.fromJson(f);
      // If canceled, do not display
      if (_formation?.statut.toUpperCase() == 'ANNULER') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cette formation a été annulée.')),
          );
          Navigator.pop(context);
        }
        return;
      }
      final centreId = _formation?.idCentre ?? 0;
      if (centreId != 0) {
        final centreJson = await _centresService.getById(centreId);
        final nomCentre =
            (centreJson['nom'] ?? (centreJson['utilisateur']?['nom'] ?? ''))
                .toString();
        final adresseCentre = (centreJson['adresse'] ?? '').toString();
        _centreName = nomCentre.isNotEmpty ? nomCentre : 'Centre #$centreId';
        _centreSituation = adresseCentre.isNotEmpty ? adresseCentre : '—';
        final emailCentre =
            (centreJson['email'] ?? (centreJson['utilisateur']?['email'] ?? ''))
                .toString();
        final telCentre =
            (centreJson['telephone'] ??
                    (centreJson['utilisateur']?['telephone'] ?? ''))
                .toString();
        _email = emailCentre.isNotEmpty ? emailCentre : '—';
        _telephone = telCentre.isNotEmpty ? telCentre : '—';
      }
      setState(() {
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
    final double contentStartOffset =
        200.0; // Où le SingleChildScrollView doit commencer

    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Erreur: $_error'))
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // --- 1. Header (Fond bleu 'blob') ---
                  CustomHeader(title: "Détails", showBackButton: true),
                  // --- 4. Contenu Principal Scrollable ---
                  Padding(
                    padding: EdgeInsets.only(
                      top: 4.0,
                    ), // Démarre le contenu sous le header visible
                    child: SingleChildScrollView(
                      padding: EdgeInsets
                          .zero, // Padding géré par les éléments internes
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // --- Avatar et Nom du Jeune ---
                          _buildProfileSection(_jeuneName),
                          const SizedBox(height: 30),

                          // --- Bloc de Détails de la Formation ---
                          _buildFormationDetailsBlock(
                            formationType:
                                _formation?.titre ??
                                'Formation #${widget.idFormation}',
                            startDate: _formatDate(_formation?.dateDebut),
                            endDate: _formatDate(_formation?.dateFin),
                            certification:
                                _formation != null &&
                                    (_formation!.duree.isNotEmpty)
                                ? 'Oui'
                                : '—',
                          ),

                          const SizedBox(height: 30),

                          // --- Bloc d'Inscription et Situation ---
                          _buildInscriptionBlock(
                            status: _formation?.statut ?? '—',
                            centre: _centreName,
                            situation: _centreSituation,
                            email: _email,
                            telephone: _telephone,
                          ),
                          const SizedBox(height: 40),

                          // --- Bouton d'Action ---
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: _buildGradientButton(
                              text: 'Procéder au payement',
                              onPressed: () {
                                //navigation vers la page de paiement
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                      idJeune: widget.idJeune,
                                      idFormation: widget.idFormation,
                                      idParrainage: widget.idParrainage,
                                      jeuneName: _jeuneName,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 80), // Espace pour la NavBar
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// -------------------------------------------
  /// WIDGETS DE COMPOSANTS DÉTAILLÉS
  /// -------------------------------------------

  /// Section Profil (Avatar + Nom)
  Widget _buildProfileSection(String name) {
    return Center(
      child: Column(
        children: <Widget>[
          ProfileAvatar(
            photoUrl: _jeunePhotoUrl,
            radius: 50,
            isPerson: true,
            backgroundColor: primaryBlue,
            iconColor: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.day}/${d.month}/${d.year}';
  }

  /// Bloc de Détails de la Formation
  Widget _buildFormationDetailsBlock({
    required String formationType,
    required String startDate,
    required String endDate,
    required String certification,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Formations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: primaryBlue.withValues(
                          alpha: 0.8,
                        ), // Bleu un peu plus clair
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      formationType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  _buildDetailRow('Date début', startDate),
                  _buildDetailRow('Date Fin', endDate),
                  _buildDetailRow('Certification', certification),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bloc d'Inscription et Situation
  Widget _buildInscriptionBlock({
    required String status,
    required String centre,
    required String situation,
    required String email,
    required String telephone,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Inscription',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Centre de formation",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(child: Text(centre)),
                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: const Text(
                          "Email",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: const Text(
                          "Téléphone",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          telephone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: const Text(
                          "Situation",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          situation,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ligne de détail (pour Date début, Date Fin, Certification)
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge de statut (ex: "En attente")
  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xFFF82020).withValues(alpha: 0.35), // Couleur rose pâle
        borderRadius: BorderRadius.circular(20),
      ),
      width: 150,
      child: Center(
        child: Text(
          status,
          style: const TextStyle(
            color: Colors.white, // Rouge foncé
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  /// Bouton avec dégradé
  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [primaryBlue, primaryGreen], // Dégradé bleu vers vert
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

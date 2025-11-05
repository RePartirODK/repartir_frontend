import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/response/response_centre.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/pages/centres/formation.dart';
import 'package:repartir_frontend/services/centre_service.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

// Définition de la couleur principale
const Color kPrimaryColor = Color(0xFF3EB2FF);
const Color kSecondaryColor = Color(0xFF4CAF50);
const double kHeaderHeight = 200.0;

class EnhanceHome extends StatefulWidget {
  const EnhanceHome({super.key});

  @override
  State<EnhanceHome> createState() => _EnhanceHomeState();
}

class _EnhanceHomeState extends State<EnhanceHome> {
  final stockage = SecureStorageService();
  final centreService = CentreService();

  List<ResponseFormation> _formations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormations();
  }

  Future<void> _loadFormations() async {
    try {
      //recupération des données du centre connecté
      ResponseCentre? centre = await centreService.getCurrentCentre();
      if (centre == null) {
        throw Exception("Impossible de récupérer les informations du centre.");
      }

      //on met son id dans le local storage
      await stockage.saveId(centre.id);
      debugPrint(centre.id.toString());
      // Appel du backend
      final formations = await centreService.getAllFormations(centre.id);

      // Mise à jour de l’état
      setState(() {
        _formations = formations;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des formations: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  VoidCallback? get onPressed => null;
  int get nombreTotalFormations => _formations.length;

  int get nombreFormationsEnCours =>
      _formations.where((f) => f.statut.toLowerCase() == 'en_cours').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .grey[50], // Fond très légèrement gris pour faire ressortir les cards

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Le Header Incurvé avec le logo (importé de l'autre page)
            CustomHeader(),

            // 2. Titre de bienvenue (placé sous le header)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: _buildWelcomeTitle(),
            ),

            // Cartes de statistiques améliorées
            _buildStatCards(context),

            const SizedBox(height: 40),

            // Titre "Actions Rapides"
            _buildQuickActionsTitle(),

            const SizedBox(height: 15),

            // Boutons d'actions rapides
            _buildQuickActionButtons(context),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Widgets du Header ---

  Widget _buildWelcomeTitle() {
    return const Center(
      child: Text(
        "Bienvenu dans votre\nespace",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          // Carte 1: Formation en cours
          _buildStatCard(
            context,
            title: "Formation en cours",
            value: nombreFormationsEnCours.toString(),
            icon: Icons.school_outlined,
            cardColor: kPrimaryColor.withValues(alpha: 0.34),
            valueColor: Colors.black,
          ),
          const SizedBox(height: 40),

          // Carte 2: Nombre de formations
          _buildStatCard(
            context,
            title: "Nombre de formations",
            value: nombreTotalFormations.toString(),
            icon: Icons.school_outlined,
            cardColor: kSecondaryColor.withValues(
              alpha: 0.34,
            ), // Vert très doux
            valueColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color cardColor,
    required Color valueColor,
  }) {
    // Utilisation de Material pour une élévation et une ombre propres
    return Material(
      color: cardColor,
      elevation: 4.0, // Ajoute une belle ombre
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    color: valueColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Text(
                    value,

                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: valueColor,
                    ),
                  ),
                ),
              ],
            ),
            Icon(icon, size: 80, color: Colors.black.withValues(alpha: 0.80)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        "Actions Rapides",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _buildActionButton(
              context,
              text: "Demande",
              onPressed: () {
                //navigation vers la page demande
                //print("click");
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildActionButton(
              context,
              text: "Formations",

              //navigation vers la page formation
              onPressed: () {
                // Action spécifique pour Demande
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FormationsPageCentre(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String text,
    required Null Function() onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

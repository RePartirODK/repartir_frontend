import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';
import 'package:repartir_frontend/pages/centres/demandes_en_attente_page.dart';
import 'package:repartir_frontend/pages/centres/formation.dart';
import 'package:repartir_frontend/provider/centre_provider.dart';
import 'package:repartir_frontend/provider/formation_provider.dart';
import 'package:repartir_frontend/services/centre_service.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

// Définition de la couleur principale
const Color kPrimaryColor = Color(0xFF3EB2FF);
const Color kSecondaryColor = Color(0xFF4CAF50);
const double kHeaderHeight = 200.0;

class EnhanceHome extends ConsumerStatefulWidget {
  const EnhanceHome({super.key});

  @override
  ConsumerState<EnhanceHome> createState() => _EnhanceHomeState();
}


class _EnhanceHomeState extends ConsumerState<EnhanceHome> {
  final stockage = SecureStorageService();
  final centreService = CentreService();

  VoidCallback? get onPressed => null;
  int getNombreTotalFormations(List<ResponseFormation> formations) => formations.length;

int getNombreFormationsEnCours(List<ResponseFormation> formations) =>
    formations.where((f) => f.statut.toLowerCase() == 'en_cours').length;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormations();
  }

  Future<void> _loadFormations() async {
    try {
      //recupération des données du centre connecté
       await ref.read(centreNotifierProvider.notifier).loadCurrentCentre();
      final centre = ref.read(centreNotifierProvider);

      if (centre == null) throw Exception("Centre non trouvé");

      //on met son id dans le local storage
      await stockage.saveId(centre.id);
      debugPrint(centre.id.toString());
     
     // Utilisation du provider pour charger les formations
    await ref.read(formationProvider.notifier).loadFormations(centre.id);


      // Mise à jour de l’état
      setState(() {

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des formations: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //il va être en écoute des changements du provider
    final formations = ref.watch(formationProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: [
                      CustomHeader(title: 'Accueil'),
                      Positioned(
                        height: 80,
                        width: 80,
                        top: 30,
                        left: 20,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            'assets/images/logo_repartir.png',
                            height: 300,
                            width: 300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 20.0,
                    ),
                    child: _buildWelcomeTitle(),
                  ),
                  _buildStatCards(context, formations),
                  const SizedBox(height: 40),
                  _buildQuickActionsTitle(),
                  const SizedBox(height: 15),
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

  Widget _buildStatCards(BuildContext context,
  List<ResponseFormation> formations) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          // Carte 1: Formation en cours
          _buildStatCard(
            context,
            title: "Formation en cours",
            value: getNombreFormationsEnCours(formations).toString(),
            icon: Icons.school_outlined,
            cardColor: kPrimaryColor.withValues(alpha: 0.34),
            valueColor: Colors.black,
          ),
          const SizedBox(height: 40),

          // Carte 2: Nombre de formations
          _buildStatCard(
            context,
            title: "Nombre de formations",
            value: getNombreTotalFormations(formations).toString(),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DemandesEnAttentePage(),
                  ),
                );
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

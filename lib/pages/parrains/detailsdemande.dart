import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/pages/parrains/pagepaiement.dart';

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
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // Données factices pour l'exemple
  final String jeuneName = "Kadiatou Tall";
  final String formationType = "Couture";
  final String startDate = "12/03/2025";
  final String endDate = "12/05/2025";
  final String certification = "Oui";
  final String inscriptionStatus = "En attente";
  final String trainingCenter = "Centre de formations Sabatiso";
  final String situation = "Attbougou 1008 logements en face de la boulangerie";

  @override
  Widget build(BuildContext context) {
    final double contentStartOffset =
        200.0; // Où le SingleChildScrollView doit commencer

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // --- 1. Header (Fond bleu 'blob') ---
            CustomHeader(title: "Détails",
            showBackButton: true,),
            // --- 4. Contenu Principal Scrollable ---
            Padding(
              padding: EdgeInsets.only(
               top: 4.0
              ), // Démarre le contenu sous le header visible
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.zero, // Padding géré par les éléments internes
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // --- Avatar et Nom du Jeune ---
                    _buildProfileSection(jeuneName),
                    const SizedBox(height: 30),
        
                    // --- Bloc de Détails de la Formation ---
                    _buildFormationDetailsBlock(
                      formationType: formationType,
                      startDate: startDate,
                      endDate: endDate,
                      certification: certification,
                    ),
                    const SizedBox(height: 30),
        
                    // --- Bloc d'Inscription et Situation ---
                    _buildInscriptionBlock(
                      status: inscriptionStatus,
                      centre: trainingCenter,
                      situation: situation,
                    ),
                    const SizedBox(height: 40),
        
                    // --- Bouton d'Action ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildGradientButton(
                        text: 'Procéder au payement',
                        onPressed: () {
                          //navigation vers la page de paiement
                          Navigator.push(context,
                          MaterialPageRoute(builder: 
                          (context)=> PaymentPage()));
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
          const CircleAvatar(
            radius: 50,
            backgroundColor: primaryBlue, // Couleur d'arrière-plan de l'avatar
            child: Icon(Icons.person, size: 70, color: Colors.white),
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
        color: Color(0xFFF82020).withOpacity(0.35), // Couleur rose pâle
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
            color: Colors.grey.withOpacity(0.3),
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

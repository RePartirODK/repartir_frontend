import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/models/response/response_centre.dart';
import 'package:repartir_frontend/models/response/response_formation.dart';

// --- COULEURS ET CONSTANTES GLOBALES ---
const Color primaryBlue = Color(0xFF3EB2FF); // Couleur principale bleue
const Color primaryOrange = Color(0xFFFF9800); // Couleur Orange pour le logo ODC


// --- 2. WIDGET PRINCIPAL : FormationDetailsPage ---
class FormationDetailsPage extends StatelessWidget {
  const FormationDetailsPage({super.key, required this.formation, this.centre, this.centrePhotoUrl});
  final ResponseFormation formation;
  final ResponseCentre? centre;
  final String? centrePhotoUrl; // URL de la photo du centre
  @override
  Widget build(BuildContext context) {
    // Utilisation de SafeArea pour éviter le chevauchement avec la barre de statut
    return Scaffold(
      body: Stack(
        children: [
          // 1. Arrière-plan bleu avec le clipper
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child:CustomHeader(
              title: "Formations Details",
              showBackButton: true,
            )
          ),
          
          // 2. Contenu principal (scrollable)
          Positioned.fill(
            top: 150, // Démarre le contenu sous le titre
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 2.1 Carte Centre de Formation et Titre ---
                    _buildCenterHeaderCard(),
                    const SizedBox(height: 20),
                    
                    // --- 2.2 Titre de la Formation ---
                    Text(
                      formation.titre,
                      style: const TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // --- 2.3 Description et Programme ---
                    _buildDescriptionSection(),
                    const SizedBox(height: 20),

                    // --- 2.4 Section Dates ---
                    _buildDateSection(),
                    const SizedBox(height: 25),

                    // --- 2.5 Carte des Détails Pratiques ---
                    _buildPracticalDetailsCard(),
                    const SizedBox(height: 40),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  // Carte du centre de formation et localisation
  Widget _buildCenterHeaderCard() {
    final centreName = centre?.nom ?? 'Centre';
    final centreLocation = centre?.adresse ?? 'Adresse indisponible';
    
    // Récupérer l'URL de la photo du centre avec gestion améliorée
    // Priorité à centrePhotoUrl passé en paramètre, sinon depuis centre?.urlPhoto
    String? photoUrl = centrePhotoUrl;
    if ((photoUrl == null || photoUrl.isEmpty) && 
        centre?.urlPhoto != null && 
        (centre!.urlPhoto ?? '').toString().trim().isNotEmpty) {
      photoUrl = (centre!.urlPhoto ?? '').toString().trim();
    }
    
    // Nettoyer l'URL si elle existe
    if (photoUrl != null) {
      photoUrl = photoUrl.trim();
      if (photoUrl.isEmpty) photoUrl = null;
    }
    
    // Debug: Vérifier l'URL de la photo
    debugPrint('📸 Parrain formation détails - Centre: $centreName, Photo URL: $photoUrl');
    if (centre != null) {
      debugPrint('📸 Parrain formation détails - centre.urlPhoto: ${centre!.urlPhoto}');
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileAvatar(
          photoUrl: photoUrl,
          radius: 40,
          isPerson: false,
          backgroundColor: Colors.grey[200],
          iconColor: primaryOrange,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                centreName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    centreLocation,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
 
  // Section Description et Programme
   Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          formation.description,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 15),
        const Text(
          'Au programme:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        _buildProgramItem('Format: ${formation.format}'),
        _buildProgramItem('Durée: ${formation.duree}'),
        if (formation.urlFormation != null && formation.urlFormation!.isNotEmpty)
          _buildProgramItem('Lien: ${formation.urlFormation}'),
      ],
    );
  }
   // Section Dates
   Widget _buildDateSection() {
    final start = formation.dateDebut;
    final end = formation.dateFin;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.calendar_today, color: primaryBlue, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Du ${start.day}/${start.month}/${start.year} au ${end.day}/${end.month}/${end.year}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
  // Item du programme avec tiret
  Widget _buildProgramItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 4.0),
      child: Text(
        '- $text',
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

 
  
  // Carte des détails pratiques (Places, Sommes, Type)

Widget _buildPracticalDetailsCard() {
    final places = formation.nbrePlace;
    final cout = formation.cout;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildDetailRow(Icons.people, 'Places disponibles', '$places'),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.attach_money, 'Sommes', cout > 0 ? 'Oui' : 'Non'),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.business, 'Type de formation', formation.format),
        ],
      ),
    );
  }

  // Ligne de détail dans la carte pratique
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue),
        ),
      ],
    );
  }
}


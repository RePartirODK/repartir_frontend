// edit_profil_mentor_page.dart

import 'package:flutter/material.dart';
// NOTE: Assurez-vous que le chemin d'importation vers vos composants est correct
// import 'custom_widgets.dart'; 
import 'package:repartir_frontend/components/custom_header.dart'; // Exemple de chemin Header

// Définition de la couleur (assurez-vous que primaryBlue est accessible)
const Color primaryBlue = Color(0xFF3EB2FF); 

class EditProfilMentorPage extends StatefulWidget {
  const EditProfilMentorPage({super.key});

  @override
  State<EditProfilMentorPage> createState() => _EditProfilMentorPageState();
}

class _EditProfilMentorPageState extends State<EditProfilMentorPage> {
  // Champs pour simuler les données du formulaire
  String prenom = 'Ousmane';
  String nom = 'Diallo';
  String email = 'adiallo7485@gmail.com';
  String telephone = '+22376412209';
  String domaine = 'Menuiserie';
  String aPropos = 'Ceci est une description à propos de moi';
  String anneeExperience = '5'; // Exemple d'année

  void _saveProfile() {
    // Logique de sauvegarde : Appel API
    print('Profil sauvegardé: $prenom $nom');
    // Afficher un SnackBar de succès ou naviguer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour avec succès!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. HEADER (L'AppBar bleu incurvé)
      
      
      // 2. CORPS DE LA PAGE (Formulaire)
      body: SingleChildScrollView(
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Avatar modifiable (implémentation du petit icône caméra)
            CustomHeader(
              title: "Editier profile",
              showBackButton: true,
            ),
            const Center(
              child: ProfileEditableAvatar(),
            ),
            const SizedBox(height: 30),
            Padding(padding: 
              EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: <Widget>[
                       // Champs du formulaire
            _buildTextField(label: 'Prenom', initialValue: prenom, onChanged: (v) => prenom = v),
            _buildTextField(label: 'Nom', initialValue: nom, onChanged: (v) => nom = v),
            _buildTextField(label: 'Email', initialValue: email, keyboardType: TextInputType.emailAddress, onChanged: (v) => email = v),
            _buildTextField(label: 'Telephone', initialValue: telephone, keyboardType: TextInputType.phone, onChanged: (v) => telephone = v),
            _buildTextField(label: 'Domaine', initialValue: domaine, onChanged: (v) => domaine = v),
            
            _buildTextField(
              label: 'A propos',
              initialValue: aPropos,
              maxLines: 5,
              onChanged: (v) => aPropos = v,
              minHeight: 100, // Hauteur pour la zone de description
            ),

            _buildTextField(
              label: 'Année d\'expérience',
              initialValue: anneeExperience,
              keyboardType: TextInputType.number,
              onChanged: (v) => anneeExperience = v,
            ),
                ],
              ),
            ),
       
              // Bouton Enregistrer
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 2,
                ),
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          
           
          ],
        ),
      ),
    );
  }
  
  // Fonction utilitaire pour construire les champs de texte
  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    double minHeight = 50,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: BoxConstraints(minHeight: minHeight),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextFormField(
              initialValue: initialValue,
              onChanged: onChanged,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                border: InputBorder.none, // Supprime la bordure interne par défaut
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Widget pour l'avatar modifiable (avec l'icône caméra)
class ProfileEditableAvatar extends StatelessWidget {
  const ProfileEditableAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    // Taille de l'avatar
    const double avatarRadius = 60;

    return SizedBox(
      width: avatarRadius * 2,
      height: avatarRadius * 2,
      child: Stack(
        children: <Widget>[
          // L'avatar principal (le grand cercle)
          Container(
            width: avatarRadius * 2,
            height: avatarRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryBlue.withOpacity(0.2), // Fond de l'avatar
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: const Icon(Icons.person, size: 80, color: Colors.blueGrey), // Placeholder
          ),

          // Le petit cercle de modification (Positionné en bas à droite)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // Logique pour ouvrir la galerie/caméra
                print('Modifier la photo de profil');
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: primaryBlue, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: primaryBlue,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
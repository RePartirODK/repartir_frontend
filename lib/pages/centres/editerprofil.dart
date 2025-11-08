import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/request/centre_request.dart';
import 'package:repartir_frontend/provider/centre_provider.dart';
import 'package:repartir_frontend/services/centre_service.dart';
import 'package:repartir_frontend/services/utilisateur_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

const Color primaryBlue = Color(0xFF3EB2FF);

class EditProfilCentrePage extends ConsumerStatefulWidget {
  const EditProfilCentrePage({super.key});

  @override
  ConsumerState<EditProfilCentrePage> createState() =>
      _EditProfilCentrePageState();
}

class _EditProfilCentrePageState extends ConsumerState<EditProfilCentrePage> {
  late TextEditingController nomController;
  late TextEditingController emailController;
  late TextEditingController telephoneController;
  late TextEditingController adresseController;
  late TextEditingController agrementController;
  final utilisateurService = UtilisateurService();
  final centreService = CentreService();

  @override
  void initState() {
    super.initState();
    final centre = ref.read(centreNotifierProvider)!;
    nomController = TextEditingController(text: centre.nom);
    emailController = TextEditingController(text: centre.email);
    telephoneController = TextEditingController(text: centre.telephone);
    adresseController = TextEditingController(text: centre.adresse);
    agrementController = TextEditingController(text: centre.agrement);
  }

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    adresseController.dispose();
    agrementController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    try {
      final updatedCentre = CentreRequest(
        nom: nomController.text,
        motDePasse: '',
        telephone: telephoneController.text,
        email: emailController.text,
        adresse: adresseController.text,
        agrement: agrementController.text,
      );

      // Appel au service pour mise à jour
      await centreService.updateCentre(updatedCentre);

      // Mettre à jour le provider pour que toutes les pages voient les modifications
      ref.read(centreNotifierProvider.notifier).updateCentre(updatedCentre);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
      );
    }
  }

  // Gestion de l'upload de photo
 Future<void> _updatePhoto() async {
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return; // aucun fichier choisi

    final centre = ref.read(centreNotifierProvider)!;

    // Upload la photo au backend
    final urlPhoto = await utilisateurService.uploadPhotoProfil(
      centre.email,
      picked.path,
    );

    // Mettre à jour le provider global
    ref.read(centreNotifierProvider.notifier).updateCentre(
          CentreRequest(
            nom: centre.nom,
            motDePasse: '',
            telephone: centre.telephone,
            email: centre.email,
            adresse: centre.adresse,
            agrement: centre.agrement,
          ).copyWith(urlPhoto: urlPhoto),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Photo mise à jour avec succès ✅")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur lors de la mise à jour de la photo : $e")),
    );
  }
}

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
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
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fillColor: Colors.grey.shade100,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final centre = ref.watch(centreNotifierProvider);

    if (centre == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomHeader(title: "Éditer profil", showBackButton: true),
            const SizedBox(height: 20),

            // Avatar modifiable
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        centre.urlPhoto != null && centre.urlPhoto!.isNotEmpty
                        ? NetworkImage(centre.urlPhoto!)
                        : null,
                    backgroundColor: Colors.grey.shade200,
                    child: centre.urlPhoto == null || centre.urlPhoto!.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.blueGrey,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _updatePhoto,
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
            ),

            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField(label: 'Nom', controller: nomController),
                  _buildTextField(
                    label: 'Email',
                    controller: emailController,
                    readOnly: true,
                  ),
                  _buildTextField(
                    label: 'Téléphone',
                    controller: telephoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    label: 'Adresse',
                    controller: adresseController,
                  ),
                  _buildTextField(
                    label: 'Numéro d’agrément',
                    controller: agrementController,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/request/parrain_request.dart';
import 'package:repartir_frontend/provider/parrain_provider.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';
import 'package:repartir_frontend/services/utilisateur_service.dart';

const Color primaryBlue = Color(0xFF3EB2FF);

class EditProfilParrainPage extends ConsumerStatefulWidget {
  const EditProfilParrainPage({super.key});

  @override
  ConsumerState<EditProfilParrainPage> createState() =>
      _EditProfilParrainPageState();
}

class _EditProfilParrainPageState extends ConsumerState<EditProfilParrainPage> {
  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController emailController;
  late TextEditingController telephoneController;
  late TextEditingController professionController;

  final utilisateurService = UtilisateurService();
  bool _saving = false;
  bool _uploadingPhoto = false;
  final storage = SecureStorageService();
   String? _photoUrl;

  @override
  void initState() {
    super.initState();
    final parrain = ref.read(parrainNotifierProvider);
    nomController = TextEditingController(text: parrain?.nom ?? '');
    prenomController = TextEditingController(text: parrain?.prenom ?? '');
    emailController = TextEditingController(text: parrain?.email ?? '');
    telephoneController = TextEditingController(text: parrain?.telephone ?? '');
    professionController = TextEditingController(text: parrain?.profession ?? '');
    
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    professionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      final updated = ParrainRequest(
        nom: nomController.text,
        prenom: prenomController.text,
        email: emailController.text,
        telephone: telephoneController.text,
        motDePasse: '',
        profession: professionController.text,
        urlPhoto: null,
      );
      await ref.read(parrainNotifierProvider.notifier).updateParrain(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      setState(() => _uploadingPhoto = true);
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) {
        setState(() => _uploadingPhoto = false);
        return;
      }
      final email = await storage.getUserEmail();
      if (email == null || email.isEmpty) {
        setState(() => _uploadingPhoto = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email utilisateur introuvable.')),
          );
        }
        return;
      }
      final url = await utilisateurService.uploadPhotoProfil(email, picked.path);
      setState(() {
        _photoUrl = url ?? _photoUrl;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo mise à jour.')),
        );
      }    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la mise à jour: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }}
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
    final parrain = ref.watch(parrainNotifierProvider);

    if (parrain == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final photoUrl = (() {
      final top = parrain.urlPhoto;
      final nested = parrain.utilisateur.urlPhoto;
      if (top != null && top.isNotEmpty) return top;
      if (nested != null && nested.isNotEmpty) return nested;
      return null;
    })();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CustomHeader(title: "Éditer profil", showBackButton: true),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                    backgroundColor: Colors.grey.shade200,
                    child: photoUrl == null
                        ? const Icon(Icons.person, size: 80, color: Colors.blueGrey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: primaryBlue, width: 2),
                        ),
                        child: _uploadingPhoto
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: primaryBlue),
                              )
                            : const Icon(Icons.camera_alt, color: primaryBlue, size: 20),
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
                  _buildTextField(label: 'Prénom', controller: prenomController),
                  _buildTextField(label: 'Email', controller: emailController, readOnly: true),
                  _buildTextField(
                    label: 'Téléphone',
                    controller: telephoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(label: 'Profession', controller: professionController),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Enregistrer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
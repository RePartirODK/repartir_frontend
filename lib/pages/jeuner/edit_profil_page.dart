import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/jeune_service.dart';
import 'package:repartir_frontend/models/jeune_profil.dart';

class EditProfilePage extends StatefulWidget {
  final JeuneProfil? profil;

  const EditProfilePage({Key? key, this.profil}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final JeuneService _jeuneService = JeuneService();
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _aboutController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _niveauController;
  late String? _selectedGenre;
  
  File? _selectedImage;
  bool _isLoading = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.profil?.utilisateur?.nom ?? '');
    _prenomController = TextEditingController(text: widget.profil?.prenom ?? '');
    _aboutController = TextEditingController(text: widget.profil?.aPropos ?? '');
    _emailController = TextEditingController(text: widget.profil?.utilisateur?.email ?? '');
    _phoneController = TextEditingController(text: widget.profil?.utilisateur?.telephone ?? '');
    _ageController = TextEditingController(text: widget.profil?.age?.toString() ?? '');
    _niveauController = TextEditingController(text: widget.profil?.niveau ?? '');
    _selectedGenre = widget.profil?.genre;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _aboutController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _niveauController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Sur le web, image_picker a des limitations
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('L\'upload de photo n\'est pas disponible sur le web. Veuillez utiliser l\'application mobile.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      // Afficher un dialogue pour choisir la source
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir dans la galerie'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await _picker.pickImage(source: source);
        
        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImage == null || widget.profil?.utilisateur?.email == null) {
      return;
    }

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final fileBytes = await _selectedImage!.readAsBytes();
      final fileName = _selectedImage!.path.split('/').last;
      
      await _jeuneService.uploadPhotoProfil(
        widget.profil!.utilisateur!.email,
        fileBytes,
        fileName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploadée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
          _selectedImage = null; // Réinitialiser après upload
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (widget.profil == null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload de la photo si une nouvelle image a été sélectionnée
      if (_selectedImage != null) {
        await _uploadPhoto();
        // Recharger le profil pour avoir la nouvelle URL de photo
        final newProfil = await _jeuneService.getProfile();
        if (newProfil != null) {
          // Utiliser la nouvelle URL de photo dans la mise à jour
          final updatedProfil = JeuneProfil(
            id: newProfil.id,
            aPropos: _aboutController.text.isEmpty ? null : _aboutController.text,
            genre: _selectedGenre,
            age: _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
            prenom: _prenomController.text.isEmpty ? null : _prenomController.text,
            niveau: _niveauController.text.isEmpty ? null : _niveauController.text,
            urlDiplome: newProfil.urlDiplome,
            utilisateur: newProfil.utilisateur != null
                ? UtilisateurInfo(
                    id: newProfil.utilisateur!.id,
                    nom: _nomController.text,
                    email: _emailController.text,
                    telephone: _phoneController.text,
                    urlPhoto: newProfil.utilisateur!.urlPhoto,
                    role: newProfil.utilisateur!.role,
                    etat: newProfil.utilisateur!.etat,
                    estActive: newProfil.utilisateur!.estActive,
                    dateCreation: newProfil.utilisateur!.dateCreation,
                  )
                : null,
          );
          await _jeuneService.modifierProfil(updatedProfil);
        }
      } else {
        // Pas de nouvelle photo, mise à jour normale
        final updatedProfil = JeuneProfil(
          id: widget.profil!.id,
          aPropos: _aboutController.text.isEmpty ? null : _aboutController.text,
          genre: _selectedGenre,
          age: _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
          prenom: _prenomController.text.isEmpty ? null : _prenomController.text,
          niveau: _niveauController.text.isEmpty ? null : _niveauController.text,
          urlDiplome: widget.profil!.urlDiplome,
          utilisateur: widget.profil!.utilisateur != null
              ? UtilisateurInfo(
                  id: widget.profil!.utilisateur!.id,
                  nom: _nomController.text,
                  email: _emailController.text,
                  telephone: _phoneController.text,
                  urlPhoto: widget.profil!.utilisateur!.urlPhoto,
                  role: widget.profil!.utilisateur!.role,
                  etat: widget.profil!.utilisateur!.etat,
                  estActive: widget.profil!.utilisateur!.estActive,
                  dateCreation: widget.profil!.utilisateur!.dateCreation,
                )
              : null,
        );

        // Envoyer à l'API
        await _jeuneService.modifierProfil(updatedProfil);
      }

      if (mounted) {
        Navigator.pop(context, true); // Retourner true pour indiquer succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Contenu principal
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar avec bouton caméra
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 48,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!) as ImageProvider
                                : widget.profil?.utilisateur?.urlPhoto != null
                                    ? NetworkImage(widget.profil!.utilisateur!.urlPhoto!)
                                    : null,
                            child: widget.profil?.utilisateur?.urlPhoto == null && _selectedImage == null
                                ? const Icon(Icons.person, size: 48)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isUploadingPhoto ? null : _pickImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _isUploadingPhoto ? Colors.grey : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.blue, width: 2),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: _isUploadingPhoto
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      size: 20.0,
                                      color: Colors.blue,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildTextField(_nomController, "Nom*"),
                  const SizedBox(height: 20),
                  _buildTextField(_prenomController, "Prénom*"),
                  const SizedBox(height: 20),
                  _buildTextField(_aboutController, "À propos", maxLines: 4),
                  const SizedBox(height: 20),
                  _buildTextField(_emailController, "Email*"),
                  const SizedBox(height: 20),
                  _buildTextField(_phoneController, "Téléphone*"),
                  const SizedBox(height: 20),
                  _buildTextField(_ageController, "Âge", keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  _buildTextField(_niveauController, "Niveau d'étude"),
                  const SizedBox(height: 20),
                  _buildGenreDropdown(),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveProfile,
                          icon: _isLoading 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.check, color: Colors.white),
                          label: Text(
                            _isLoading ? 'Enregistrement...' : 'Enregistrer',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3EB2FF),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      TextButton.icon(
                        onPressed: _isLoading ? null : () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close, color: Colors.grey),
                        label: const Text('Retour',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Header avec bouton retour et titre
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              title: 'Modifier Profil',
              height: 120,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildGenreDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGenre,
      decoration: InputDecoration(
        labelText: 'Genre',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: const [
        DropdownMenuItem(value: 'HOMME', child: Text('Homme')),
        DropdownMenuItem(value: 'FEMME', child: Text('Femme')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGenre = value;
        });
      },
    );
  }
}

class ProfilePageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

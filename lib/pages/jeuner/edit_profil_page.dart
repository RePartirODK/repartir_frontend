import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, String> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileService _profile = ProfileService();
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _saving = false;
  String? _error;
  String? _photoUrl;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _aboutController = TextEditingController(text: widget.userData['about']);
    _addressController =
        TextEditingController(text: widget.userData['address']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _loadCurrentPhoto();
  }

  Future<void> _loadCurrentPhoto() async {
    try {
      final me = await _profile.getMe();
      final utilisateur = (me['utilisateur'] ?? {}) as Map<String, dynamic>;
      final newPhotoUrl = utilisateur['urlPhoto'] as String?;
      
      print('🖼️ URL photo récupérée: $newPhotoUrl');
      
      if (mounted) {
        setState(() {
          _photoUrl = newPhotoUrl;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement de la photo: $e');
      // Ignorer l'erreur, on continuera sans photo
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 48,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _selectedImageBytes != null
                                  ? MemoryImage(_selectedImageBytes!)
                                  : (_selectedImage != null && !kIsWeb
                                      ? FileImage(_selectedImage!)
                                      : (_photoUrl != null && _photoUrl!.isNotEmpty
                                          ? NetworkImage(_photoUrl!)
                                          : null)),
                              onBackgroundImageError: _selectedImageBytes != null || 
                                                      (_selectedImage != null && !kIsWeb) ||
                                                      (_photoUrl != null && _photoUrl!.isNotEmpty)
                                  ? (_, __) {}
                                  : null,
                              child: _selectedImageBytes == null && 
                                     _selectedImage == null &&
                                     (_photoUrl == null || _photoUrl!.isEmpty)
                                  ? const Icon(Icons.person, size: 48, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                          child: CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 18,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20.0,
                                color: Colors.white,
                              ),
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildTextField(_nameController, "Nom ET Prenom*"),
                  const SizedBox(height: 20),
                  _buildTextField(_aboutController, "A propos", maxLines: 4),
                  const SizedBox(height: 20),
                  _buildTextField(_addressController, "Adresse*"),
                  const SizedBox(height: 20),
                  _buildTextField(_emailController, "Email professionnel*"),
                  const SizedBox(height: 20),
                  _buildTextField(_phoneController, "Téléphone*"),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _onSave,
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Enregistrer',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3EB2FF),
                            padding:
                                const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      TextButton.icon(
                        onPressed: () {
                          // Just return
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
              height: 150,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
}

extension on _EditProfilePageState {
  Future<void> _pickImage() async {
    // Afficher un dialogue pour choisir entre caméra et galerie
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
        );
      }
    }
  }

  Future<List<int>> _getImageBytes() async {
    if (_selectedImageBytes != null) {
      debugPrint('📷 Image depuis bytes (taille: ${_selectedImageBytes!.length} bytes)');
      return _selectedImageBytes!;
    } else if (_selectedImage != null && !kIsWeb) {
      final bytes = await _selectedImage!.readAsBytes();
      debugPrint('📷 Image depuis fichier (taille: ${bytes.length} bytes)');
      return bytes;
    } else {
      throw Exception('Aucune image sélectionnée');
    }
  }

  Future<void> _onSave() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      // Fetch current profile to merge fields not edited here
      final me = await _profile.getMe();
      final utilisateur = (me['utilisateur'] ?? {}) as Map<String, dynamic>;

      final parts = _nameController.text.trim().split(RegExp(r'\s+'));
      final String prenom = parts.isNotEmpty ? parts.first : (me['prenom'] ?? '');
      final String nom = parts.length > 1 ? parts.sublist(1).join(' ') : (utilisateur['nom'] ?? '');

      final payload = <String, dynamic>{
        'prenom': prenom.isEmpty ? (me['prenom'] ?? '') : prenom,
        'a_propos': _aboutController.text.isEmpty ? (me['a_propos'] ?? '') : _aboutController.text,
        'age': me['age'],
        'niveau': me['niveau'],
        'genre': me['genre'],
        'urlDiplome': me['urlDiplome'],
        'nom': nom.isEmpty ? (utilisateur['nom'] ?? '') : nom,
        'telephone': _phoneController.text.isEmpty ? (utilisateur['telephone'] ?? '') : _phoneController.text,
        'urlPhoto': utilisateur['urlPhoto'],
      };
      
      // Si une nouvelle photo a été sélectionnée, l'uploader séparément
      if (_selectedImageBytes != null || (_selectedImage != null && !kIsWeb)) {
        try {
          final imageBytes = await _getImageBytes();
          final email = _emailController.text.isNotEmpty 
              ? _emailController.text 
              : (utilisateur['email'] ?? '');
          
          debugPrint('📷 Upload de la photo...');
          final uploadResult = await _profile.updatePhoto(imageBytes, email);
          debugPrint('✅ Photo uploadée avec succès: $uploadResult');
          
          // Recharger pour avoir la nouvelle URL
          debugPrint('🔄 Rechargement du profil pour obtenir la nouvelle URL...');
          await _loadCurrentPhoto();
          debugPrint('🔄 Profil rechargé');
          
          setState(() {
            _selectedImage = null;
            _selectedImageBytes = null;
          });
        } catch (e) {
          debugPrint('❌ ERREUR lors de l\'upload de la photo: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de l\'upload de la photo: ${e.toString().replaceAll('Exception: ', '')}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          setState(() {
            _saving = false;
          });
          return;
        }
      }

      debugPrint('📤 Envoi du profil au backend...');
      await _profile.updateMe(payload);
      debugPrint('✅ Profil mis à jour avec succès');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, {
          'name': _nameController.text,
          'about': _aboutController.text,
          'address': _addressController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
        });
      }
    } catch (e) {
      _error = '$e';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde: $_error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
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

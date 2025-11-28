import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/password_change_dialog.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/models/request/parrain_request.dart';
import 'package:repartir_frontend/models/response/response_parrain.dart';
import 'package:repartir_frontend/pages/parrains/editerprofiparrain.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';
import 'package:repartir_frontend/provider/parrain_provider.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';
import 'package:repartir_frontend/services/utilisateur_service.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'dart:convert';

const Color primaryBlue = Color(0xFF3EB2FF);
const Color primaryRed = Color(0xFFF44336);

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final utilisateurService = UtilisateurService();
  final _profile = ProfileService();
  final storage = SecureStorageService();
  bool _loading = true;
  bool _uploadingPhoto = false;
  String? _error;
  int _photoRefreshKey = 0; // Pour forcer le rafraîchissement de l'image

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await ref.read(parrainNotifierProvider.notifier).loadCurrentParrain();
      setState(() {
        _photoRefreshKey++; // Incrémenter pour forcer le rafraîchissement
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// --- LOGIQUE DE DÉCONNEXION ---
  void _showLogoutDialog(BuildContext context) {
    // Stocker le contexte de la page principale
    final mainContext = context;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône de déconnexion
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 40,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Titre
                const Text(
                  'Se déconnecter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Message
                Text(
                  'Êtes-vous sûr de vouloir vous déconnecter ?\n\nVous devrez vous reconnecter pour accéder à votre compte.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await _handleLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Déconnexion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// --- UPLOAD PHOTO DE PROFIL ---
  Future<void> _updatePhoto() async {
    try {
      setState(() => _uploadingPhoto = true);
      final picker = ImagePicker();
      
      // Compatible Web et Mobile
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) {
        setState(() => _uploadingPhoto = false);
        return;
      }

      final parrain = ref.read(parrainNotifierProvider);
      final email = parrain?.email ?? '';
      if (email.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Email utilisateur introuvable.')));
        }
        setState(() => _uploadingPhoto = false);
        return;
      }

      // Lire les bytes de l'image (compatible Web et Mobile)
      final imageBytes = await picked.readAsBytes();
      
      debugPrint('📷 Upload de la photo pour le parrain...');
      debugPrint('📷 Taille fichier: ${imageBytes.length} bytes');
      debugPrint('📷 Email: $email');

      // Upload la photo au backend en utilisant ProfileService (compatible Web)
      final uploadResult = await _profile.updatePhoto(imageBytes, email);
      debugPrint('✅ Photo uploadée avec succès: $uploadResult');

      // Extraire la nouvelle URL de la réponse
      String? newPhotoUrl;
      try {
        final message = uploadResult['message'];
        
        if (message is Map) {
          newPhotoUrl = message['urlPhoto'] as String?;
        } else if (message is String) {
          final decoded = jsonDecode(message);
          if (decoded is Map<String, dynamic> && decoded['urlPhoto'] != null) {
            newPhotoUrl = decoded['urlPhoto'] as String;
          }
        }
        
        if (newPhotoUrl == null && uploadResult['urlPhoto'] != null) {
          newPhotoUrl = uploadResult['urlPhoto'] as String;
        }
        
        debugPrint('🖼️ Nouvelle URL photo extraite: $newPhotoUrl');
      } catch (e) {
        debugPrint('⚠️ Erreur lors de l\'extraction de l\'URL: $e');
      }

      if (newPhotoUrl != null && parrain != null) {
        final updated = ParrainRequest(
          nom: parrain.nom,
          prenom: parrain.prenom,
          email: parrain.email,
          telephone: parrain.telephone,
          motDePasse: '',
          profession: parrain.profession ?? '',
          urlPhoto: newPhotoUrl,
        );
        
        // Mettre à jour le provider localement pour éviter l'appel API problématique
        ref.read(parrainNotifierProvider.notifier).updateParrainLocally(updated);
        
        // Forcer le rafraîchissement
        _photoRefreshKey++;
        
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Photo mise à jour avec succès ✅"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Recharger les données si l'extraction a échoué
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Photo mise à jour avec succès ✅")),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ ERREUR lors de l\'upload de la photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la mise à jour de la photo : ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  /// --- SUPPRESSION DE COMPTE ---
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer le compte", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          "Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteAccount();
            },
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final email = await storage.getUserEmail();
      if (email == null) throw Exception("Email non trouvé dans le stockage sécurisé.");

      await utilisateurService.suppressionCompte({'email': email});
      await _handleLogout();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la suppression : $e")),
      );
    }
  }

  /// --- DÉCONNEXION RÉELLE ---
  Future<void> _handleLogout() async {
    try {
      final email = await storage.getUserEmail();
      if (email != null) await utilisateurService.logout({'email': email});
      await storage.clearTokens();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthenticationPage()),
          (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Déconnexion effectuée'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erreur de déconnexion : $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final parrain = ref.watch(parrainNotifierProvider);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text('Erreur : $_error')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(child: _buildProfileHeader(context, parrain)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations personnelles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildInfoCard(Icons.email, 'Email', parrain?.email ?? '—'),
                  const SizedBox(height: 10),
                  _buildInfoCard(Icons.phone, 'Téléphone', parrain?.telephone ?? '—'),
                  const SizedBox(height: 40),
                  const Text(
                    'Paramètres du compte',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildSettingItem(context, 'Changer le mot de passe', () {
                    showPasswordChangeDialog(context);
                  }),
                  _buildSettingItem(
                    context,
                    'Supprimer mon compte',
                    _showDeleteConfirmationDialog,
                    isDestructive: true,
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Se déconnecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- WIDGET HEADER DU PROFIL ---
  Widget _buildProfileHeader(BuildContext context, ResponseParrain? parrain) {
    final fullName = parrain != null ? '${parrain.prenom} ${parrain.nom}' : '—';
    final roleLabel = parrain?.profession ?? (parrain?.role ?? '');
    final photoUrl = parrain?.urlPhoto ?? parrain?.utilisateur.urlPhoto;

    return Stack(
      children: [
        const CustomHeader(title: "Profil"),
        Align(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ProfileAvatar(
                    photoUrl: photoUrl,
                    radius: 60,
                    isPerson: true,
                    cacheKey: _photoRefreshKey.toString(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _uploadingPhoto ? null : _updatePhoto,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryBlue, width: 2),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: _uploadingPhoto
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryBlue,
                                ),
                              )
                            : const Icon(Icons.camera_alt, color: primaryBlue, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                fullName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (roleLabel.isNotEmpty)
                Text(roleLabel, style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilParrainPage()),
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Modifier le profil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(10),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              '$title : $value',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive ? primaryRed : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: isDestructive ? primaryRed : Colors.grey),
          ],
        ),
      ),
    );
  }
}

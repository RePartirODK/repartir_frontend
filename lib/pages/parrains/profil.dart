import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/pages/mentors/editerprofil.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

// --- COULEURS ET CONSTANTES GLOBALES ---
const Color primaryBlue = Color(0xFF3EB2FF); // Couleur principale bleue
const Color primaryRed = Color(
  0xFFF44336,
); // Couleur pour les actions destructives

// --- WIDGET PRINCIPAL : ProfilePage ---
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final SecureStorageService _storage = SecureStorageService();

  bool _loading = true;
  String userName = 'Chargement...';
  String? userRole;
  String? userEmail;
  String? userPhone;
  String? userPhoto;
  String? aPropos;
  int _imageRefreshKey = 0; // ✅ Clé pour forcer refresh image

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final profile = await _profileService.getMe();
      print('📋 Profil chargé: $profile');

      final prenom = (profile['prenom'] ?? '').toString().trim();
      final utilisateur = profile['utilisateur'] ?? <String, dynamic>{};
      final nom = (utilisateur['nom'] ?? profile['nom'] ?? '').toString().trim();
      final profession = (profile['profession'] ?? profile['domaine'] ?? '').toString().trim();
      final email = (utilisateur['email'] ?? profile['email'] ?? '').toString().trim();
      final telephone = (utilisateur['telephone'] ?? profile['telephone'] ?? '').toString().trim();
      
      // Debug photo
      print('🖼️ utilisateur[urlPhoto]: ${utilisateur['urlPhoto']}');
      print('🖼️ profile[urlPhoto]: ${profile['urlPhoto']}');
      
      final photoUrl = utilisateur['urlPhoto'] ?? profile['urlPhoto'];
      final photo = photoUrl?.toString().trim();
      
      print('🖼️ Photo finale: $photo');
      
      final about = (profile['a_propos'] ?? profile['aPropos'] ?? '').toString().trim();

      setState(() {
        final fullName = '$prenom $nom'.trim();
        userName = fullName.isNotEmpty ? fullName : 'Utilisateur';
        userRole = profession ?? '';
        userEmail = email ?? '';
        userPhone = telephone ?? '';
        userPhoto = (photo != null && photo.isNotEmpty) ? photo : null;
        aPropos = about ?? '';
        _loading = false;
      });
      
      print('🖼️ userPhoto défini: $userPhoto');
    } catch (e) {
      print('❌ Erreur chargement profil: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilMentorPage(),
      ),
    );

    // Recharger le profil si des modifications ont été faites
    if (result == true) {
      print('✅ Retour de l\'édition, rechargement du profil...');
      await _loadProfile();
      setState(() {
        _imageRefreshKey++; // ✅ Changer la clé pour forcer le rechargement de l'image
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Ferme le dialog
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Ferme la boîte de dialogue
                // 🧹 Logique de déconnexion ici (ex: suppression token, retour à login)
                print('Utilisateur déconnecté');
                Navigator.pushReplacementNamed(context, '/login'); // Exemple
              },
              child: const Text(
                'Se déconnecter',
                style: TextStyle(color: primaryRed),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Contenu principal avec bordure arrondie
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadProfile,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 30, 16, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar + Nom + Bouton Edit (scrollable)
                            Center(
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        key: ValueKey('avatar_$_imageRefreshKey'), // ✅ Clé unique pour forcer refresh
                                        radius: 60,
                                        backgroundColor: Colors.grey[200],
                                        backgroundImage: userPhoto != null && userPhoto!.isNotEmpty
                                            ? NetworkImage(userPhoto!)
                                            : null,
                                        onBackgroundImageError: userPhoto != null && userPhoto!.isNotEmpty
                                            ? (exception, stackTrace) {
                                                print('❌ Erreur chargement image: $exception');
                                                print('🖼️ URL qui pose problème: $userPhoto');
                                              }
                                            : null,
                                        child: userPhoto == null || userPhoto!.isEmpty
                                            ? const Icon(Icons.person, size: 80, color: Colors.blueGrey)
                                            : null,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: _navigateToEdit,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: primaryBlue, width: 2),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(
                                                Icons.camera_alt,
                                                color: primaryBlue,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (userRole?.isNotEmpty ?? false)
                                    Text(
                                      userRole!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    width: 200,
                                    height: 45,
                                    child: ElevatedButton.icon(
                                      onPressed: _navigateToEdit,
                                      icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                                      label: const Text(
                                        'Éditer le profil',
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryBlue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),

                            // À propos (si disponible)
                            if (aPropos?.isNotEmpty ?? false) ...[
                              const Text(
                                'À propos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  aPropos!,
                                  style: const TextStyle(fontSize: 14, height: 1.5),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                            const Text(
                              'Information Personnelle',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 15),
                            if (userEmail?.isNotEmpty ?? false)
                              _buildInfoCard(Icons.email, 'Email', userEmail!),
                            if (userEmail?.isNotEmpty ?? false)
                              const SizedBox(height: 10),
                            if (userPhone?.isNotEmpty ?? false)
                              _buildInfoCard(Icons.phone, 'Téléphone', userPhone!),
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
                      print('Action: Changer mot de passe');
                    }),
                    _buildSettingItem(context, 'Supprimer mon compte', () {
                      print('Action: Supprimer mon compte');
                    }, isDestructive: true),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showLogoutDialog(context);
                        },
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
                          elevation: 2,
                        ),
                      ),
                    ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // Header simple (sans avatar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              title: "Profil",
              height: 120,
            ),
          ),
        ],
      ),
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
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? primaryRed : Colors.black87,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDestructive ? primaryRed : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// --- NOTE ---
// N'oublie pas d'importer ton CustomBottomNavBar si elle est dans un fichier séparé :

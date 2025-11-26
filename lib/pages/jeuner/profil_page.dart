import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/password_change_dialog.dart';
import 'package:repartir_frontend/components/custom_alert_dialog.dart';
import 'package:repartir_frontend/services/utilisateur_service.dart';
import 'edit_profil_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/profile_avatar.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/services/auth_service.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';

// Style colors similar to mentors/profile_mentor.dart
const Color primaryBlue = Color(0xFF3EB2FF);
const Color primaryRed = Color(0xFFF44336);

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profile = ProfileService();
  final AuthService _auth = AuthService();
  final utilisateurService = UtilisateurService();
  final storage = SecureStorageService();
  bool _loading = true;
  String? _error;
  String name = "";
  String about = "";
  String email = "";
  String phone = "";
  String address = "";
  String? photoUrl;
  int _photoRefreshKey = 0; // Pour forcer le rafraîchissement de l'image

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final me = await _profile.getMe();
      // Backend Jeune entity structure
      final utilisateur = (me['utilisateur'] ?? {}) as Map<String, dynamic>;
      name = ('${me['prenom'] ?? ''} ${utilisateur['nom'] ?? ''}').trim();
      about = (me['a_propos'] ?? '') as String;
      email = (utilisateur['email'] ?? '') as String;
      phone = (utilisateur['telephone'] ?? '') as String;
      address = '';
      photoUrl = utilisateur['urlPhoto'] as String?;
      _photoRefreshKey++; // Incrémenter pour forcer le rafraîchissement
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _navigateToEditProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          userData: {
            'name': name,
            'about': about,
            'email': email,
            'phone': phone,
            'address': address,
          },
        ),
      ),
    );

    // Recharger les données du profil après modification (y compris la photo)
    if (result != null || result == null) {
      await _fetch(); // Recharger toutes les données y compris la photo
    }
  }

  

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Erreur: $_error')));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(child: _buildProfileHeader(context)),
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
                  _buildInfoCard(Icons.email, 'Email', email),
                  const SizedBox(height: 10),
                  _buildInfoCard(Icons.phone, 'Téléphone', phone),
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
                  _buildSettingItem(
                    context,
                    'Changer le mot de passe',
                    () => showPasswordChangeDialog(context),
                  ),
                  const SizedBox(height: 8),
                   _buildSettingItem(
                    context,
                    'Supprimer mon compte',
                    _showDeleteConfirmationDialog,
                    isDestructive: true,
                  ),
                  const SizedBox(height: 8),
                  _buildSettingItem(
                    context,
                    'Se déconnecter',
                    _handleLogout,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Stack(
      children: [
        const CustomHeader(title: "Profil"),
        Align(
          child: Column(
            children: [
              const SizedBox(height: 100),
              ProfileAvatar(
                photoUrl: photoUrl,
                radius: 60,
                isPerson: true,
                cacheKey: _photoRefreshKey.toString(),
              ),
              const SizedBox(height: 15),
              Text(
                name.isEmpty ? 'Jeune' : name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _navigateToEditProfile(context),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Modifier le profile'),
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
    final v = value.isEmpty ? '—' : value;
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
              '$title : $v',
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

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Supprimer le compte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await utilisateurService.suppressionCompte({'email': email});
                if (email.isNotEmpty) {
                  await utilisateurService.logout({'email': email});
                }
                await storage.clearTokens();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthenticationPage()),
                    (Route<dynamic> route) => false,
                  );
                  if (mounted) {
                    CustomAlertDialog.showSuccess(
                      context: context,
                      message: 'Votre compte a été supprimé avec succès.',
                      title: 'Compte supprimé',
                      onConfirm: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const AuthenticationPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  if (mounted) {
                    final errorMessage = e.toString()
                        .replaceAll('Exception: ', '')
                        .replaceAll('HTTP 500: ', '')
                        .replaceAll('HTTP 400: ', '');
                    
                    CustomAlertDialog.showError(
                      context: context,
                      message: errorMessage.isNotEmpty 
                          ? 'Erreur lors de la suppression: $errorMessage'
                          : 'Une erreur est survenue lors de la suppression du compte.',
                      title: 'Erreur',
                    );
                  }
                }
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // Dialog de confirmation de déconnexion
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                          Navigator.of(context).pop();
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
                          // Fermer le dialog de confirmation d'abord
                          Navigator.of(context).pop();
                          
                          try {
                            if (email.isNotEmpty) {
                              await utilisateurService.logout({'email': email});
                            }
                            await storage.clearTokens();
                            
                            // Naviguer vers la page d'authentification
                            // On ne peut pas afficher de message après pushAndRemoveUntil
                            // car on est déjà sur une nouvelle page
                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const AuthenticationPage()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          } catch (e) {
                            // Afficher l'erreur seulement si le widget est toujours monté
                            if (mounted) {
                              final errorMessage = e.toString()
                                  .replaceAll('Exception: ', '')
                                  .replaceAll('HTTP 401: ', '')
                                  .replaceAll('HTTP 500: ', '');
                              
                              CustomAlertDialog.showError(
                                context: context,
                                message: errorMessage.isNotEmpty 
                                    ? 'Erreur lors de la déconnexion: $errorMessage'
                                    : 'Une erreur est survenue lors de la déconnexion.',
                                title: 'Erreur de déconnexion',
                              );
                            }
                          }
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

  Future<void> _handleLogout() async {
    _showLogoutDialog();
  }
}

class ProfilePageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(
      size.width - (size.width / 3.25),
      size.height - 65,
    );
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

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

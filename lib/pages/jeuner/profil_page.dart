import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/password_change_dialog.dart';
import 'package:repartir_frontend/services/utilisateur_service.dart';
import 'edit_profil_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/services/auth_service.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profile = ProfileService();
  final AuthService _auth = AuthService();
  final utilisateurService = UtilisateurService();
  bool _loading = true;
  String? _error;
  String name = "";
  String about = "";
  String email = "";
  String phone = "";
  String address = "";
  String? photoUrl;

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
      name = ((me['prenom'] ?? '') + ' ' + (utilisateur['nom'] ?? '')).trim();
      about = (me['a_propos'] ?? '') as String;
      email = (utilisateur['email'] ?? '') as String;
      phone = (utilisateur['telephone'] ?? '') as String;
      address = '';
      photoUrl = utilisateur['urlPhoto'] as String?;
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

    if (result != null) {
      setState(() {
        name = result['name'];
        about = result['about'];
        email = result['email'];
        phone = result['phone'];
        address = result['address'];
      });
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar avec bouton caméra pour éditer
                        GestureDetector(
                          onTap: () => _navigateToEditProfile(context),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage:
                                      photoUrl != null && photoUrl!.isNotEmpty
                                      ? NetworkImage(photoUrl!)
                                      : null,
                                  onBackgroundImageError:
                                      photoUrl != null && photoUrl!.isNotEmpty
                                      ? (_, __) {}
                                      : null,
                                  child: photoUrl == null || photoUrl!.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          size: 48,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor: const Color(0xFF3EB2FF),
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
                        const SizedBox(height: 20),

                        // Nom
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // À propos de moi
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "À propos de moi",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  about.isEmpty ? '—' : about,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Informations de contact
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Contact Information",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ListTile(
                                  leading: const Icon(
                                    Icons.email,
                                    color: Color(0xFF3EB2FF),
                                  ),
                                  title: Text(email.isEmpty ? '—' : email),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(
                                    Icons.phone,
                                    color: Color(0xFF3EB2FF),
                                  ),
                                  title: Text(phone.isEmpty ? '—' : phone),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        //Changer son mot de passe de passe
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              debugPrint('Naviguer vers changer mot de passe');
                              showPasswordChangeDialog(context);
                            },
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              'Changer mot de passe',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white60,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Bouton de déconnexion
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _handleLogout,
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              'Déconnexion',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Header avec titre et bouton d'édition
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              title: 'Mon Profil',
              height: 120,
              rightWidget: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 24),
                onPressed: () => _navigateToEditProfile(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    // Afficher un dialogue de confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await utilisateurService.logout({'email': email});
        if (mounted) {
          // Rediriger vers la page d'authentification
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthenticationPage()),
            (Route<dynamic> route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Déconnexion effectuée'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la déconnexion: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
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

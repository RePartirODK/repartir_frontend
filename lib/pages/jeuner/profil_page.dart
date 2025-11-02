import 'package:flutter/material.dart';
import 'edit_profil_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/jeune_service.dart';
import 'package:repartir_frontend/models/jeune_profil.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final JeuneService _jeuneService = JeuneService();
  JeuneProfil? _profil;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profil = await _jeuneService.getProfile();
      setState(() {
        _profil = profil;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $_errorMessage')),
        );
      }
    }
  }

  void _navigateToEditProfile(BuildContext context) async {
    if (_profil == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          profil: _profil,
        ),
      ),
    );

    if (result == true) {
      // Recharger le profil après modification
      await _loadProfile();
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage ?? 'Erreur inconnue'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadProfile,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : _profil == null
                        ? const Center(child: Text('Aucun profil trouvé'))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 48,
                                    backgroundImage: _profil!.utilisateur?.urlPhoto != null
                                        ? NetworkImage(_profil!.utilisateur!.urlPhoto!)
                                        : null,
                                    child: _profil!.utilisateur?.urlPhoto == null
                                        ? const Icon(Icons.person, size: 48)
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // Nom
                                Text(
                                  '${_profil!.utilisateur?.nom ?? ''} ${_profil!.prenom ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                
                                // Bouton Edit Profile
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _navigateToEditProfile(context);
                                  },
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  label: const Text('Modifier le profil', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3EB2FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // À propos de moi
                                if (_profil!.aPropos != null && _profil!.aPropos!.isNotEmpty)
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
                                            _profil!.aPropos!,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (_profil!.aPropos != null && _profil!.aPropos!.isNotEmpty) const SizedBox(height: 20),
                                
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
                                          "Informations de contact",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        if (_profil!.utilisateur?.email != null)
                                          ListTile(
                                            leading: const Icon(Icons.email, color: Color(0xFF3EB2FF)),
                                            title: Text(_profil!.utilisateur!.email),
                                          ),
                                        if (_profil!.utilisateur?.email != null && _profil!.utilisateur?.telephone != null)
                                          const Divider(),
                                        if (_profil!.utilisateur?.telephone != null)
                                          ListTile(
                                            leading: const Icon(Icons.phone, color: Color(0xFF3EB2FF)),
                                            title: Text(_profil!.utilisateur!.telephone!),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
          
          // Header avec titre (sans bouton retour)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              title: 'Mon Profil',
              height: 120,
            ),
          ),
        ],
      ),
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

import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/entreprise/accueil_entreprise_page.dart';
import 'package:repartir_frontend/pages/entreprise/modifier_profil_page.dart';
import 'package:repartir_frontend/pages/entreprise/mes_offres_page.dart';
import 'package:repartir_frontend/pages/entreprise/nouvelle_offre_page.dart';
import 'package:repartir_frontend/pages/auth/authentication_page.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

class ProfilEntreprisePage extends StatefulWidget {
  const ProfilEntreprisePage({super.key});

  @override
  State<ProfilEntreprisePage> createState() => _ProfilEntreprisePageState();
}

class _ProfilEntreprisePageState extends State<ProfilEntreprisePage> {
  final ProfileService _profileService = ProfileService();
  final SecureStorageService _storage = SecureStorageService();
  
  bool _isLoading = true;
  String _companyName = "Entreprise";
  String _companyCategory = "";
  String _companyDescription = "";
  String _location = "";
  String _email = "";
  String _phone = "";
  String _companyImageUrl = '';
  int _imageRefreshKey = 0; // Pour forcer le rafraîchissement de l'image
  int _selectedIndex = 2; // Index pour la barre de navigation (Profil sélectionné)

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileService.getMe();
      
      setState(() {
        _companyName = profile['nom'] ?? 'Entreprise';
        _companyCategory = profile['secteurActivite'] ?? '';
        _companyDescription = profile['description'] ?? '';
        _location = profile['adresse'] ?? '';
        _email = profile['email'] ?? '';
        _phone = profile['telephone'] ?? '';
        _companyImageUrl = profile['urlPhotoEntreprise'] ?? '';
        _imageRefreshKey++; // Incrémenter pour forcer le rafraîchissement de l'image
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement profil: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNavigation(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Contenu principal
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Espace pour l'en-tête
                      const SizedBox(height: 130),
                
                // En-tête avec image de profil
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 20, bottom: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // Image de profil
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _companyImageUrl.isEmpty
                          ? Container(
                              color: Colors.blue.shade50,
                              child: Icon(
                                Icons.business,
                                size: 60,
                                color: Colors.blue.shade400,
                              ),
                            )
                          : Image.network(
                              '$_companyImageUrl?v=$_imageRefreshKey', // Cache-busting
                              key: ValueKey('company_avatar_$_imageRefreshKey'), // Force rebuild
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.blue.shade50,
                                  child: Icon(
                                    Icons.business,
                                    size: 60,
                                    color: Colors.blue.shade400,
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Nom de l'entreprise
                  Text(
                    _companyName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Catégorie
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _companyCategory,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _companyDescription,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            
            // Section informations de contact
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha:0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_location.isNotEmpty) ...[
                    _buildContactInfo(Icons.location_on, _location),
                    const SizedBox(height: 15),
                  ],
                  if (_email.isNotEmpty) ...[
                    _buildContactInfo(Icons.email, _email),
                    const SizedBox(height: 15),
                  ],
                  if (_phone.isNotEmpty)
                    _buildContactInfo(Icons.phone, _phone),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Section boutons d'action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Boutons principaux
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          Icons.edit,
                          'Modifier le profil',
                          Colors.blue,
                          () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ModifierProfilPage()),
                            );
                            if (result == true) {
                              _loadProfile(); // Recharger le profil après modification
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildActionButton(
                          Icons.add_circle_outline,
                          'Ajouter une offre',
                          Colors.green,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NouvelleOffrePage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Bouton de déconnexion
                  _buildActionButton(
                    Icons.logout,
                    'Se déconnecter',
                    Colors.red,
                    () {
                      _showLogoutDialog();
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
              ],
            ),
          ),
          
          // En-tête bleu avec forme ondulée (au-dessus du contenu)
          CustomHeader(
            title: 'Profil Entreprise',
          ),
        ],
      ),
    );
  }

  // Widget pour les informations de contact
  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey.shade600,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // Widget pour les boutons d'action
  Widget _buildActionButton(IconData icon, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
                          Navigator.of(context).pop();
                          
                          // Nettoyer les tokens
                          await _storage.clearTokens();
                          
                          // Déconnexion et retour à la page d'authentification
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

  // Barre de navigation inférieure
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 5,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey.shade600,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        
        if (index == 0) {
          // Retour à l'accueil entreprise
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AccueilEntreprisePage()),
          );
         } else if (index == 1) {
           // Naviguer vers la page des offres
           Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (context) => const MesOffresPage()),
           );
         }
        // Index 2 = Profil (page actuelle)
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          label: 'Offres',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}

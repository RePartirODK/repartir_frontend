import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/components/password_change_dialog.dart';
import 'package:repartir_frontend/pages/mentors/editerprofil.dart';
import 'package:repartir_frontend/services/profile_service.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';
import 'package:repartir_frontend/services/utilisateur_service.dart';

const Color primaryBlue = Color(0xFF3EB2FF);
const Color primaryRed = Color(0xFFF44336);

class ProfileMentorPage extends StatefulWidget {
  const ProfileMentorPage({super.key});

  @override
  State<ProfileMentorPage> createState() => _ProfileMentorPageState();
}

class _ProfileMentorPageState extends State<ProfileMentorPage> {
  final utilisateurService = UtilisateurService();
  final storage = SecureStorageService();
  final profileService = ProfileService();

  bool _loading = true;
  bool _uploadingPhoto = false;
  String? _error;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await profileService.getMe(); // /mentors/profile via role
      setState(() {
        _profile = p;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleLogout();
            },
            child: const Text('Se déconnecter', style: TextStyle(color: primaryRed)),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePhoto() async {
    try {
      setState(() => _uploadingPhoto = true);
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

      if (picked == null) {
        setState(() => _uploadingPhoto = false);
        return;
      }

      final utilisateur = (_profile?['utilisateur'] ?? {}) as Map<String, dynamic>;
      final email = (utilisateur['email'] ?? '').toString();
      if (email.isEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email utilisateur introuvable.')),
        );
        setState(() => _uploadingPhoto = false);
        return;
      }

      await utilisateurService.uploadPhotoProfil(email, picked.path);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo mise à jour avec succès ✅")),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la mise à jour de la photo : $e")),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

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

  Future<void> _handleLogout() async {
    try {
      final email = await storage.getUserEmail();
      if (email != null) await utilisateurService.logout({'email': email});
      await storage.clearTokens();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur de déconnexion : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildInfoCard(Icons.email, 'Email',
                      (_profile?['utilisateur']?['email'] ?? _profile?['email'] ?? '—').toString()),
                  const SizedBox(height: 10),
                  _buildInfoCard(Icons.phone, 'Téléphone',
                      (_profile?['utilisateur']?['telephone'] ?? _profile?['telephone'] ?? '—')
                          .toString()),
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

  Widget _buildProfileHeader(BuildContext context) {
    final u = (_profile?['utilisateur'] ?? {}) as Map<String, dynamic>;
    final fullName = (_profile?['nomComplet'] ??
            '${(_profile?['prenom'] ?? '')} ${(u['nom'] ?? _profile?['nom'] ?? '')}')
        .toString()
        .trim();
    final roleLabel = (_profile?['profession'] ?? _profile?['domaine'] ?? '').toString();
    final photoUrl = (u['urlPhoto'] ?? _profile?['urlPhoto'])?.toString();

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
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? const Icon(Icons.person, size: 80, color: Colors.blueGrey)
                        : null,
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
                fullName.isEmpty ? 'Mentor' : fullName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (roleLabel.isNotEmpty)
                Text(roleLabel, style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilMentorPage()),
                  );
                  if (updated == true) _loadData();
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
              '$title : ${value.isEmpty ? '—' : value}',
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
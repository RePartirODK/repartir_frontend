import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, String> userData;

  const EditProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _aboutController = TextEditingController(text: widget.userData['about']);
    _addressController =
        TextEditingController(text: widget.userData['address']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: ProfilePageClipper(),
                  child: Container(
                    height: 200,
                    color: Colors.blue,
                  ),
                ),
                Positioned(
                  top: 150, // Adjust this value to position the avatar
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150'), // Placeholder image
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 15,
                          child: Icon(Icons.camera_alt,
                              size: 20.0, color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: BackButton(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0), // Add top padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                          onPressed: () {
                            // Save data and return
                            Navigator.pop(context, {
                              'name': _nameController.text,
                              'about': _aboutController.text,
                              'address': _addressController.text,
                              'email': _emailController.text,
                              'phone': _phoneController.text,
                            });
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text('Enregistrer',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
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
            )
          ],
        ),
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

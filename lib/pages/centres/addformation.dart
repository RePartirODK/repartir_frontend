import 'package:flutter/material.dart';

// Définition de la couleur principale
const Color kPrimaryColor = Color(0xFF3EB2FF);

// Cette page est un formulaire, donc pas de BottomNavigationBar

class AddFormationPage extends StatefulWidget {
  const AddFormationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddFormationPageState createState() => _AddFormationPageState();
}

class _AddFormationPageState extends State<AddFormationPage> {
  // Contrôleurs pour les champs de texte
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _placesController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  // Pour le Dropdown (Format)
  String? _selectedFormat;
  final List<String> _formats = ['Présentiel', 'En ligne', 'Hybride'];

  // Pour la sélection de date
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor, // Couleur du header
              onPrimary: Colors.white, // Couleur du texte sur le header
              onSurface: Colors.black, // Couleur du texte du calendrier
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryColor, // Couleur des boutons Annuler/OK
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _costController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _placesController.dispose();
    _domainController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc pour le formulaire lui-même
      appBar: AppBar(
        backgroundColor: Colors.white, // Barre d'appli blanche
        elevation: 0, // Pas d'ombre sous l'AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Formations', // Le titre de la page parente
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Intitulé de la formation
            _buildLabeledTextField(
              label: 'Intitulé de la formation',
              hintText: 'Entrez le nom de la formation',
              controller: _titleController,
              icon: Icons.title,
            ),
            const SizedBox(height: 20),

            // Description
            _buildLabeledTextField(
              label: 'Description',
              hintText: 'Description de la formation',
              controller: _descriptionController,
              maxLines: 4,
              icon: Icons.description,
            ),
            const SizedBox(height: 20),

            // Durée & Coût
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildLabeledTextField(
                    label: 'Durée',
                    hintText: '',
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    icon: Icons.timelapse,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildLabeledTextField(
                    label: 'Coût',
                    hintText: '',
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    icon: Icons.attach_money,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date début & Date fin
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildLabeledTextField(
                    label: 'Date début',
                    hintText: '',
                    controller: _startDateController,
                    readOnly: true, // Empêche la saisie manuelle
                    onTap: () => _selectDate(context, _startDateController),
                    icon: Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildLabeledTextField(
                    label: 'Date fin',
                    hintText: '',
                    controller: _endDateController,
                    readOnly: true,
                    onTap: () => _selectDate(context, _endDateController),
                    icon: Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Nombre de places
            _buildLabeledTextField(
              label: 'Nombre de places',
              hintText: 'Entrez le nombre de places de la formation',
              controller: _placesController,
              keyboardType: TextInputType.number,
              icon: Icons.groups,
            ),
            const SizedBox(height: 20),

            // Domaine de la formation
            _buildLabeledTextField(
              label: 'Domaine de la formation',
              hintText: 'Entrez le domaine de la formation',
              controller: _domainController,
              icon: Icons.category,
            ),
            const SizedBox(height: 20),

            // Format (Dropdown)
            _buildLabeledDropdown(
              label: 'Format',
              hintText: 'Choisissez le format de la formation',
              value: _selectedFormat,
              items: _formats,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFormat = newValue;
                });
              },
              icon: Icons.menu_book,
            ),
            const SizedBox(height: 20),

            // Url de formation en ligne
            _buildLabeledTextField(
              label: 'Url de formation en ligne',
              hintText: 'Url de la formation en ligne',
              controller: _urlController,
              icon: Icons.link,
            ),
            const SizedBox(height: 40),

            // Boutons d'action
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300], // Bouton Annuler gris
                      foregroundColor: Colors.black87,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor, // Bouton Ajouter bleu
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 5, // Ajout d'une ombre
                    ),
                    onPressed: () {
                      // Logique pour ajouter la formation
                      print('Ajouter formation: ${_titleController.text}');
                    },
                    child: const Text('Ajouter formation',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, 
                        fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets Utilitaires pour les champs de formulaire ---

  Widget _buildLabeledTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    bool readOnly = false,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3), // Ombre subtile
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onTap: onTap,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: icon != null ? Icon(icon, color: kPrimaryColor.withOpacity(0.7)) : null, // Icône ici
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none, // Pas de bordure visible
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledDropdown({
    required String label,
    required String hintText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: icon != null ? Icon(icon, color: kPrimaryColor.withOpacity(0.7)) : null, // Icône ici
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
            elevation: 2,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
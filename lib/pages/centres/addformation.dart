import 'package:flutter/material.dart';
import 'package:repartir_frontend/components/custom_header.dart';
import 'package:repartir_frontend/models/request/request_formation.dart';
import 'package:intl/intl.dart';
import 'package:repartir_frontend/services/centre_service.dart';
import 'package:repartir_frontend/services/secure_storage_service.dart';

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

  final dateFormat = DateFormat('dd/MM/yyyy');
  final centreService = CentreService();
  bool _isSubmitting = false;
  //form key pour la validation du formulaire
  final _formKey = GlobalKey<FormState>();
  final storage = SecureStorageService();

  // Pour le Dropdown (Format)
  String? _selectedFormat;
  final List<String> _formats = ['Presentiel', 'En ligne', 'Hybride'];
  String _formatFromString(String value) {
    switch (value.toLowerCase()) {
      case 'présentiel':
      case 'presentiel':
        return 'PRESENTIEL';
      case 'en ligne':
        return 'ENLIGNE';
      case 'hybride':
        return 'HYBRIDE';
      default:
        throw Exception('Format inconnu: $value');
    }
  }

  // Pour la sélection de date
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller, {
    DateTime? minDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: minDate ?? DateTime.now(),
      firstDate: minDate ?? DateTime.now(),
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
                foregroundColor:
                    kPrimaryColor, // Couleur des boutons Annuler/OK
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

  // --- Méthode pour soumettre le formulaire ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez corriger les erreurs")),
      );
      return;
    }

    try {
      setState(() => _isSubmitting = true);

      // Vérification logique des dates
      final DateTime dateDebut = dateFormat.parse(_startDateController.text);
      final DateTime dateFin = dateFormat.parse(_endDateController.text);

      if (dateFin.isBefore(dateDebut)) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "La date de fin ne peut pas être antérieure à la date de début.",
            ),
          ),
        );
        return;
      }

      // Création de l’objet formation
      final formation = RequestFormation(
        titre: _titleController.text,
        description: _descriptionController.text,
        dateDebut: dateDebut,
        dateFin: dateFin,
        statut: 'EN_ATTENTE',
        cout: double.tryParse(_costController.text),
        nbrePlace: int.tryParse(_placesController.text),
        format: _formatFromString(_selectedFormat!),
        duree: _durationController.text,
        urlFormation: _urlController.text.isEmpty ? null : _urlController.text,
        urlCertificat: _urlController.text.isEmpty ? null : _urlController.text,
      );

      int centreId = int.tryParse(await storage.getUserId() ?? '0') ?? 0;
      await centreService.createFormation(formation, centreId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Formation ajoutée avec succès !")),
      );

      // ✅ Réinitialisation des champs après ajout
      _titleController.clear();
      _descriptionController.clear();
      _durationController.clear();
      _costController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _placesController.clear();
      _domainController.clear();
      _urlController.clear();
      setState(() => _selectedFormat = null);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}")));
    } finally {
      setState(() => _isSubmitting = false);
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

      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Intitulé de la formation
              CustomHeader(title: "Nouvelle formation", showBackButton: true),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    _buildLabeledTextField(
                      label: 'Intitulé de la formation',
                      hintText: 'Entrez le nom de la formation',
                      controller: _titleController,
                      icon: Icons.title,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un intitulé';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description
                    _buildLabeledTextField(
                      label: 'Description',
                      hintText: 'Description de la formation',
                      controller: _descriptionController,
                      maxLines: 4,
                      icon: Icons.description,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer la durée';
                              }
                              return null;
                            },
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le coût';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Coût invalide';
                              }
                              return null;
                            },
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
                            onTap: () =>
                                _selectDate(context, _startDateController),
                            icon: Icons.calendar_today,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez sélectionner une date de début';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildLabeledTextField(
                            label: 'Date fin',
                            hintText: '',
                            controller: _endDateController,
                            readOnly: true,
                            onTap: () {
                              if (_startDateController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Veuillez d’abord choisir la date de début",
                                    ),
                                  ),
                                );
                                return;
                              }
                              _selectDate(
                                context,
                                _endDateController,
                                minDate: dateFormat.parse(
                                  _startDateController.text,
                                ),
                              );
                            },
                            icon: Icons.calendar_today,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez sélectionner une date de début';
                              }
                              return null;
                            },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nombre de places';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Nombre invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Domaine de la formation
                    _buildLabeledTextField(
                      label: 'Domaine de la formation',
                      hintText: 'Entrez le domaine de la formation',
                      controller: _domainController,
                      icon: Icons.category,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le domaine';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner un format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Url de formation en ligne
                    _buildLabeledTextField(
                      label: 'Url de formation en ligne',
                      hintText: 'Url de la formation en ligne',
                      controller: _urlController,
                      icon: Icons.link,
                      validator: (value) {
                        if ((_selectedFormat!.toLowerCase() == 'en ligne' ||
                                _selectedFormat!.toLowerCase() == 'hybride') &&
                            (value == null || value.isEmpty)) {
                          return 'Veuillez entrer l’URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // Boutons d'action
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.grey[300], // Bouton Annuler gris
                              foregroundColor: Colors.black87,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  kPrimaryColor, // Bouton Ajouter bleu
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5, // Ajout d'une ombre
                            ),
                            onPressed: _isSubmitting ? null : _submitForm,
                            child: _isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Ajouter formation',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets Utilitaires pour les champs de formulaire ---

  Widget _buildLabeledTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    String? Function(String?)? validator,
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
                color: Colors.grey.withValues(alpha: 0.15),
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
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: icon != null
                  ? Icon(icon, color: kPrimaryColor.withValues(alpha: 0.7))
                  : null, // Icône ici
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 15.0,
              ),
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
    String? Function(String?)? validator,
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
                color: Colors.grey.withValues(alpha: 0.15),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: value,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: icon != null
                  ? Icon(icon, color: kPrimaryColor.withValues(alpha: 0.7))
                  : null, // Icône ici
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 15.0,
              ),
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
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
          ),
        ),
      ],
    );
  }
}

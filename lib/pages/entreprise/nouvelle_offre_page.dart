import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/custom_header.dart';
import '../../services/offre_emploi_service.dart';
import '../../models/offre_emploi.dart';

class NouvelleOffrePage extends StatefulWidget {
  const NouvelleOffrePage({super.key});

  @override
  State<NouvelleOffrePage> createState() => _NouvelleOffrePageState();
}

class _NouvelleOffrePageState extends State<NouvelleOffrePage> {
  final _formKey = GlobalKey<FormState>();
  final OffreEmploiService _offreService = OffreEmploiService();
  
  final _titreController = TextEditingController();
  final _competencesController = TextEditingController();
  final _domaineController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lienController = TextEditingController();
  
  TypeContrat _typeContratSelectionne = TypeContrat.CDI;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titreController.dispose();
    _competencesController.dispose();
    _domaineController.dispose();
    _descriptionController.dispose();
    _lienController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          // Contenu principal
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec titre et bouton fermer
                    _buildHeader(),
                    const SizedBox(height: 30),

                    // Formulaire
                    _buildForm(),
                    const SizedBox(height: 30),

                    // Boutons d'action
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Header avec bouton retour
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              height: 120,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3EB2FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF3EB2FF),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouvelle offre',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Créez une nouvelle offre d\'emploi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre du poste
          _buildInputField(
            controller: _titreController,
            label: 'Titre du poste',
            hint: 'Ex: Développeur Front-end React',
            icon: Icons.work_outline,
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Compétences requises
          _buildInputField(
            controller: _competencesController,
            label: 'Compétences requises',
            hint: 'Ex: React, TypeScript, CSS',
            icon: Icons.star_outline,
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Domaine d'activité
          _buildInputField(
            controller: _domaineController,
            label: 'Domaine d\'activité',
            hint: 'Ex: Développement Web',
            icon: Icons.category_outlined,
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Description du poste
          _buildTextAreaField(
            controller: _descriptionController,
            label: 'Description du poste',
            hint: 'Décrivez les responsabilités et les missions du poste...',
            icon: Icons.description_outlined,
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Type de contrat (Dropdown)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment_outlined, color: Color(0xFF3EB2FF), size: 20),
                  const SizedBox(width: 8),
                  const Text('Type de contrat *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<TypeContrat>(
                value: _typeContratSelectionne,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                items: TypeContrat.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.displayName));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _typeContratSelectionne = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dates
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF3EB2FF), size: 20),
                        const SizedBox(width: 8),
                        const Text('Date de début *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          _dateDebut != null ? DateFormat('dd/MM/yyyy').format(_dateDebut!) : 'Sélectionner',
                          style: TextStyle(color: _dateDebut != null ? Colors.black87 : Colors.grey.shade400),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event, color: Color(0xFF3EB2FF), size: 20),
                        const SizedBox(width: 8),
                        const Text('Date de fin *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          _dateFin != null ? DateFormat('dd/MM/yyyy').format(_dateFin!) : 'Sélectionner',
                          style: TextStyle(color: _dateFin != null ? Colors.black87 : Colors.grey.shade400),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Lien
          _buildInputField(
            controller: _lienController,
            label: 'Lien de candidature',
            hint: 'Ex: https://votre-site.com/candidature',
            icon: Icons.link,
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF3EB2FF),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3EB2FF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF3EB2FF),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3EB2FF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _publierOffre,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3EB2FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Publier',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _publierOffre() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateDebut == null || _dateFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Veuillez sélectionner les dates')),
      );
      return;
    }

    if (_dateFin!.isBefore(_dateDebut!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ La date de fin doit être après la date de début')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final offreData = {
        'titre': _titreController.text.trim(),
        'description': _descriptionController.text.trim(),
        'competence': _competencesController.text.trim(),
        'type_contrat': _typeContratSelectionne.name,
        'lienPostuler': _lienController.text.trim(),
        'dateDebut': _dateDebut!.toIso8601String(),
        'dateFin': _dateFin!.toIso8601String(),
      };

      await _offreService.creerOffre(offreData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('✅ Offre publiée avec succès !'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDateDebut) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        if (isDateDebut) {
          _dateDebut = picked;
        } else {
          _dateFin = picked;
        }
      });
    }
  }
}

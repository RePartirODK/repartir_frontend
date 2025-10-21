import 'package:flutter/material.dart';

class FormationDetailPage extends StatelessWidget {
  const FormationDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for formation details
    final formationDetails = {
      'title': 'Développement Web Frontend',
      'center_name': 'ODC_MALI',
      'location': 'Bamako, Mali',
      'description_title': 'Description',
      'description_body':
          'Cette formation intensive vous permettra de maîtriser les technologies frontend les plus demandées sur le marché. Au programme:\n- React et son écosystème\n- TypeScript pour le développement web\n- Tests unitaires et d\'intégration\n- Performance et optimisation\n- Accessibilité web\nNos formateurs expérimentés vous guideront à travers des exercices pratiques et des projets concrets pour assurer une montée en compétence rapide et efficace.',
      'dates_title': 'Dates',
      'dates_body': 'Du 15 septembre 2023 au 15 décembre 2023',
      'places': '12',
      'sourcing': 'Oui',
      'type': 'Présentiel',
    };

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Container(
            height: 180,
            color: Colors.blue,
            child: SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: BackButton(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 120.0),
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(formationDetails),
                      const SizedBox(height: 20),
                      Text(
                        formationDetails['title']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.blue),
                      ),
                      const SizedBox(height: 20),
                      _buildSection(formationDetails['description_title']!,
                          formationDetails['description_body']!),
                      const SizedBox(height: 20),
                      _buildSection(formationDetails['dates_title']!,
                          formationDetails['dates_body']!,
                          icon: Icons.date_range),
                      const SizedBox(height: 20),
                      _buildInfoBox(formationDetails),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _showInscriptionChoiceDialog(context);
                          },
                          child: const Text("S'inscrire"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInscriptionChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close this dialog
                    _showConditionsDialog(context);
                  },
                  child: const Text('Demander à être parrainé'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Handle payment logic
                  },
                  child: const Text('Payer ma formation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConditionsDialog(BuildContext context) {
    bool accepted = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: const Text(
                'Conditions de parrainage',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text('En acceptant, vous reconnaissez que si un parrain vous est attribué, vous avez l\'obligation de suivre votre formation jusqu\'à la fin.'),
                    const SizedBox(height: 10),
                    const Text('En cas d\'abandon injustifié, vous devrez rembourser les fonds versés par le parrain.'),
                    const SizedBox(height: 20),
                    const Text('Acceptez-vous ces conditions ?'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: accepted,
                          onChanged: (bool? value) {
                            setState(() {
                              accepted = value ?? false;
                            });
                          },
                        ),
                        const Expanded(child: Text('J\'accepte les conditions')),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Oui, je confirme'),
                  onPressed: accepted
                      ? () {
                          Navigator.of(context).pop(); // Close conditions dialog
                          _showSuccessDialog(context);
                        }
                      : null, // Button is disabled if conditions are not accepted
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Demande envoyée',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Votre demande de parrainage a bien été prise en compte.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Nous vous contacterons très bientôt pour la suite du processus.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Fermer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Map<String, String> details) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage:
                NetworkImage('https://via.placeholder.com/150'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(details['center_name']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(details['location']!,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue)),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(
                child: Text(content,
                    style: const TextStyle(fontSize: 16, height: 1.5))),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBox(Map<String, String> details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildInfoBoxRow(
              'Places disponibles', details['places']!, Icons.group),
          const Divider(),
          _buildInfoBoxRow(
              'Sourcing', details['sourcing']!, Icons.business_center),
          const Divider(),
          _buildInfoBoxRow(
              'Type de formation', details['type']!, Icons.school),
        ],
      ),
    );
  }

  Widget _buildInfoBoxRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}

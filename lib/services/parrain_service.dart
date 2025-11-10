import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:repartir_frontend/models/request/parrain_request.dart';
import 'package:repartir_frontend/models/utilisateur.dart';
import 'package:repartir_frontend/network/api_config.dart';

class ParrainService {
  static const String baseUrl = "http://localhost:8183/api/utilisateurs";

  //register parrain
  Future<Utilisateur?> registerParrain(ParrainRequest parrain) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/utilisateurs/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(parrain.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final utilisateur = Utilisateur.fromJson(data);
      return utilisateur;
    } else if (response.statusCode == 302) {
      throw Exception('Email déjà utilisé');
    } else {
      throw Exception(
        'Erreur lors de l\'inscription du jeune: ${response.statusCode}',
      );
    }
  }
}

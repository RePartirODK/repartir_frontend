import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/parrains/accueilparrain.dart';
import 'package:repartir_frontend/pages/parrains/detailsdemande.dart';
import 'package:repartir_frontend/pages/parrains/dons.dart';
import 'package:repartir_frontend/pages/parrains/formationdetails.dart';
import 'package:repartir_frontend/pages/parrains/inscription.dart';
import 'package:repartir_frontend/pages/parrains/jeunesparraines.dart';
import 'package:repartir_frontend/pages/parrains/pagepaiement.dart';
import 'package:repartir_frontend/pages/parrains/profil.dart';
import 'package:repartir_frontend/pages/parrains/voirdetailformation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => RegistrationPage(),
         '/donation': (context) => const DonationsPage(),
         '/details': (context)=> const DetailPage(),
         '/formations': (context) => const FormationPage(),
         '/profil':(context) => const ProfilePage(),
         '/formationdetails': (context)=> const FormationDetailsPage(),
         '/paiementform': (context)=> const PaymentPage(),
         '/parrainés' : (context) => SponsoredYouthPage(),
         '/inscriptionparrain': (context)=>RegistrationPage(),
         '/accueil': (context)=> ParrainHomePage(),

      },
    );
  }
}


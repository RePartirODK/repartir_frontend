import 'package:flutter/material.dart';
import 'package:repartir_frontend/pages/accueilparrain.dart';
import 'package:repartir_frontend/pages/detailsdemande.dart';
import 'package:repartir_frontend/pages/dons.dart';
import 'package:repartir_frontend/pages/formationdetails.dart';
import 'package:repartir_frontend/pages/jeunesparraines.dart';
import 'package:repartir_frontend/pages/pagepaiement.dart';
import 'package:repartir_frontend/pages/profil.dart';
import 'package:repartir_frontend/pages/voirdetailformation.dart';

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
        '/': (context) => SponsoredYouthPage(),
         '/donation': (context) => const DonationsPage(),
         '/details': (context)=> const DetailPage(),
         '/formations': (context) => const FormationPage(),
         '/profil':(context) => const ProfilePage(),
         '/formationdetails': (context)=> const FormationDetailsPage(),
         '/paiementform': (context)=> const PaymentPage(),
         '/parrainés' : (context) => SponsoredYouthPage(),

      },
    );
  }
}


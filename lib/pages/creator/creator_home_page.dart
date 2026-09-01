import 'package:flutter/material.dart';

import '../app_creator/app_creator_page.dart';
import '../applications/applications_list_page.dart';
import '../client/home_client_page.dart';
import 'subscriptions_page.dart';
import 'gestion_avis_page.dart';

class CreatorHomePage extends StatelessWidget {
  const CreatorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Business App Builder",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,

            children: [
              const Text(
                "Création d'applications",

                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // =====================================================
              // NOUVELLE APPLICATION
              // =====================================================

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.add_business,
                    size: 40,
                  ),

                  title: const Text(
                    "Nouvelle application",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    "Créer une application pour un nouveau client",
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AppCreatorPage(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // MES APPLICATIONS
              // =====================================================

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.apps,
                    size: 40,
                  ),

                  title: const Text(
                    "Mes applications",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    "Voir les applications déjà créées",
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ApplicationsListPage(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // TESTER FATIMA
              // =====================================================

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.public,
                    size: 40,
                    color: Colors.green,
                  ),

                  title: const Text(
                    "Tester FATIMA",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    "Voir l'application comme un client",
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const HomeClientPage(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // ABONNEMENTS
              // =====================================================

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.card_membership,
                    size: 40,
                    color: Colors.orange,
                  ),

                  title: const Text(
                    "Abonnements",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    "Activer ou désactiver les abonnements des commerces",
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SubscriptionsPage(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // GÉRER LES AVIS
              // =====================================================

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.rate_review,
                    size: 40,
                    color: Colors.deepPurple,
                  ),

                  title: const Text(
                    "Gérer les avis",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    "Consulter et supprimer les avis faux ou injustifiés",
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const GestionAvisPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
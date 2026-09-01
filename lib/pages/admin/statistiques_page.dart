import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_storage/application_manager.dart';
import 'reservations_statut_page.dart';


class StatistiquesPage extends StatelessWidget {
  const StatistiquesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app =
        ApplicationManager.getCurrentApplication();

    if (app == null) {
      return const Scaffold(
        body: Center(
          child: Text("Commerce introuvable"),
        ),
      );
    }

    final commerceId = app.commerceId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiques"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reservations")
            .where(
              "commerceId",
              isEqualTo: commerceId,
            )
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erreur : ${snapshot.error}",
              ),
            );
          }

          int total = 0;
          int enAttente = 0;
          int acceptees = 0;
          int terminees = 0;
          int annulees = 0;

          final Set<String> clients = {};

          if (snapshot.hasData) {
            for (final doc in snapshot.data!.docs) {
              final data =
                  doc.data() as Map<String, dynamic>;

              total++;

              final status = data["status"]
                  ?.toString()
                  .toLowerCase()
                  .trim();

              if (status == "en attente") {
  enAttente++;
} else if (status == "confirmée" ||
    status == "confirmee") {
  acceptees++;
} else if (status == "terminée" ||
    status == "terminee") {
  terminees++;
} else if (status == "refusée" ||
    status == "refusee") {
  annulees++;
}
              final telephone =
                  data["phone"]?.toString().trim();

              if (telephone != null &&
                  telephone.isNotEmpty) {
                clients.add(telephone);
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [

              const Text(
                "Vue d'ensemble",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_month,
                      titre: "Réservations",
                      valeur: total.toString(),
                      couleur: Colors.orange,
                      onTap: () {
    // Nous ferons la page reservation ensuite
  },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _StatCard(
                      icon: Icons.people,
                      titre: "Clients",
                      valeur: clients.length.toString(),
                      couleur: Colors.blue,
                      onTap: () {
    // Nous ferons la page Clients ensuite
  },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.hourglass_empty,
                      titre: "En attente",
                      valeur: enAttente.toString(),
                      couleur: Colors.orange,
                      onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ReservationsStatutPage(
        statut: "En attente",
      ),
    ),
  );
},
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      titre: "Confirmées",
                      valeur: acceptees.toString(),
                      couleur: Colors.green,
                      onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReservationsStatutPage(
          statut: "Confirmée",
        ),
      ),
    );
  },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.done_all,
                      titre: "Terminées",
                      valeur: terminees.toString(),
                      couleur: Colors.teal,
                      onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReservationsStatutPage(
          statut: "Terminée",
        ),
      ),
    );
  },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _StatCard(
                      icon: Icons.cancel,
                      titre: "Refusées",
                      valeur: annulees.toString(),
                      couleur: Colors.red,
                       onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReservationsStatutPage(
          statut: "Refusée",
        ),
      ),
    );
  },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String titre;
  final String valeur;
  final Color couleur;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.titre,
    required this.valeur,
    required this.couleur,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Icon(
                icon,
                color: couleur,
                size: 35,
              ),

              const SizedBox(height: 10),

              Text(
                valeur,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                titre,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
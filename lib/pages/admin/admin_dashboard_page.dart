import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../reservation/reservations_admin_page.dart';
import '../catalog/catalog_page.dart';
import '../clients_page.dart';
import 'my_business_page.dart';
import '../../core/app_storage/application_manager.dart';
import 'statistiques_page.dart';
import 'subscription_page.dart';
import '../business/avis_commerce_business_page.dart';

// ==========================================================
// NOTIFICATIONS
// ==========================================================

import '../../services/notification_service.dart';


// ==========================================================
// PAGE DASHBOARD ADMINISTRATEUR
// ==========================================================

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() =>
      _AdminDashboardPageState();
}


// ==========================================================
// STATE
// ==========================================================

class _AdminDashboardPageState
    extends State<AdminDashboardPage> {

  // ========================================================
  // INITIALISATION
  // ========================================================

  @override
  void initState() {
    super.initState();

    _initialiserNotifications();
  }


  // ========================================================
  // INITIALISER LES NOTIFICATIONS
  // ========================================================

  Future<void> _initialiserNotifications() async {

    try {

      final application =
          ApplicationManager.getCurrentApplication();

      if (application == null) {

        debugPrint(
          "NOTIFICATIONS : aucun commerce connecté.",
        );

        return;
      }

      final commerceId =
          application.commerceId;

      debugPrint(
        "NOTIFICATIONS : initialisation pour "
        "le commerce $commerceId",
      );

      await NotificationService.initialiser(
        commerceId: commerceId,
      );

      debugPrint(
        "NOTIFICATIONS : initialisation terminée.",
      );

    } catch (e) {

      debugPrint(
        "ERREUR INITIALISATION NOTIFICATIONS DASHBOARD : $e",
      );

    }
  }


  // ========================================================
  // BUILD
  // ========================================================

  @override
  Widget build(BuildContext context) {

    final application =
        ApplicationManager.getCurrentApplication();


    // ======================================================
    // COMMERCE INTROUVABLE
    // ======================================================

    if (application == null) {

      return const Scaffold(

        body: Center(

          child: Text(
            "Commerce introuvable.",
            style: TextStyle(
              fontSize: 18,
            ),
          ),

        ),

      );
    }


    final commerceId =
        application.commerceId;


    // ======================================================
    // STREAM DU COMMERCE
    // ======================================================
    //
    // Permet de suivre en temps réel :
    // - l'abonnement
    // - la note
    // - le nombre d'avis
    //
    // ======================================================

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("commerces")
          .doc(commerceId)
          .snapshots(),

      builder: (context, commerceSnapshot) {

        // ==================================================
        // DONNÉES DU COMMERCE
        // ==================================================

        final commerceData =
            commerceSnapshot.hasData &&
                    commerceSnapshot.data!.exists
                ? commerceSnapshot.data!.data()
                    as Map<String, dynamic>
                : <String, dynamic>{};


        // ==================================================
        // NOTE
        // ==================================================

        final double note =
            (commerceData["rating"] ?? 0).toDouble();


        // ==================================================
        // NOMBRE D'AVIS
        // ==================================================

        final int nombreAvis =
            int.tryParse(
                  commerceData["reviews"]
                          ?.toString() ??
                      "0",
                ) ??
                0;


        // ==================================================
        // ABONNEMENT
        // ==================================================

        final bool abonnementActif =
            commerceData["abonnementActif"] == true;


        DateTime? expiration;


        final expirationData =
            commerceData["expirationAbonnement"];


        if (expirationData is Timestamp) {

          expiration =
              expirationData.toDate();

        } else if (expirationData is DateTime) {

          expiration =
              expirationData;
        }


        // ==================================================
        // VALIDATION ABONNEMENT
        // ==================================================
        //
        // L'abonnement est actif seulement si :
        //
        // 1. abonnementActif = true
        // 2. expiration existe
        // 3. expiration n'est pas dépassée
        //
        // ==================================================

        final bool abonnementValide =
            abonnementActif &&
            expiration != null &&
            expiration.isAfter(
              DateTime.now(),
            );


        // ==================================================
        // STREAM DES RESERVATIONS
        // ==================================================

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("reservations")
              .where(
                "commerceId",
                isEqualTo: commerceId,
              )
              .snapshots(),

          builder: (
            context,
            reservationSnapshot,
          ) {

            // =================================================
            // RESERVATIONS EN ATTENTE
            // =================================================

            int pendingReservations = 0;


            // =================================================
            // CLIENTS UNIQUES
            // =================================================

            final Set<String> clientsUniques = {};


            // =================================================
            // PARCOURS DES RESERVATIONS
            // =================================================

            if (reservationSnapshot.hasData) {

              for (
                final doc
                    in reservationSnapshot.data!.docs
              ) {

                final data =
                    doc.data()
                        as Map<String, dynamic>;


                // ---------------------------------------------
                // RESERVATIONS EN ATTENTE
                // ---------------------------------------------

                if (
                  data["status"] ==
                  "En attente"
                ) {

                  pendingReservations++;
                }


                // ---------------------------------------------
                // CLIENTS UNIQUES
                // ---------------------------------------------

                final telephone =
                    data["phone"]
                        ?.toString()
                        .trim();


                if (
                  telephone != null &&
                  telephone.isNotEmpty
                ) {

                  clientsUniques.add(
                    telephone,
                  );
                }
              }
            }


            // =================================================
            // NOMBRE DE CLIENTS
            // =================================================

            final int nombreClients =
                clientsUniques.length;


            // =================================================
            // AFFICHAGE DASHBOARD
            // =================================================

            return Scaffold(

              // =================================================
              // APP BAR
              // =================================================

              appBar: AppBar(

                title: const Text(
                  "Dashboard Administrateur",
                ),

              ),


              // =================================================
              // BODY
              // =================================================

              body: ListView(

                padding:
                    const EdgeInsets.all(20),

                children: [

                  // =================================================
                  // PREMIERE LIGNE
                  // RESERVATIONS + CLIENTS
                  // =================================================

                  Row(

                    children: [

                      // ===========================================
                      // RESERVATIONS
                      // ===========================================

                      Expanded(

                        child: Card(

                          child: Padding(

                            padding:
                                const EdgeInsets.all(15),

                            child: Column(

                              children: [

                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.orange,
                                  size: 35,
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                Text(

                                  pendingReservations
                                      .toString(),

                                  style:
                                      const TextStyle(

                                    fontSize: 28,

                                    fontWeight:
                                        FontWeight.bold,

                                  ),
                                ),

                                const Text(
                                  "En attente",
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(
                        width: 10,
                      ),


                      // ===========================================
                      // CLIENTS
                      // ===========================================

                      Expanded(

                        child: Card(

                          child: Padding(

                            padding:
                                const EdgeInsets.all(15),

                            child: Column(

                              children: [

                                const Icon(
                                  Icons.people,
                                  color: Colors.blue,
                                  size: 35,
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                Text(

                                  nombreClients
                                      .toString(),

                                  style:
                                      const TextStyle(

                                    fontSize: 28,

                                    fontWeight:
                                        FontWeight.bold,

                                  ),
                                ),

                                const Text(
                                  "Clients",
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),


                  const SizedBox(
                    height: 15,
                  ),


                  // =================================================
                  // DEUXIEME LIGNE
                  // NOTE + ABONNEMENT
                  // =================================================

                  Row(

                    children: [

                      // ===========================================
                      // NOTE
                      // ===========================================

                      Expanded(

                        child: Card(

                          child: InkWell(

                            borderRadius:
                                BorderRadius.circular(4),

                            onTap: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>
                                      AvisCommerceBusinessPage(

                                    commerceId:
                                        commerceId,

                                    nomCommerce:
                                        commerceData["nom"]
                                                ?.toString() ??
                                            "Mon commerce",

                                  ),
                                ),
                              );
                            },


                            child: Padding(

                              padding:
                                  const EdgeInsets.all(15),

                              child: Column(

                                children: [

                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 35,
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  Text(

                                    note.toStringAsFixed(1),

                                    style:
                                        const TextStyle(

                                      fontSize: 28,

                                      fontWeight:
                                          FontWeight.bold,

                                    ),
                                  ),

                                  const Text(
                                    "Note",
                                  ),


                                  if (nombreAvis > 0)

                                    Text(

                                      "$nombreAvis avis",

                                      style:
                                          const TextStyle(

                                        color:
                                            Colors.grey,

                                        fontSize: 12,

                                      ),
                                    ),


                                  const SizedBox(
                                    height: 8,
                                  ),


                                  const Text(

                                    "Appuyer pour voir les avis",

                                    style:
                                        TextStyle(

                                      color:
                                          Colors.orange,

                                      fontSize: 11,

                                      fontWeight:
                                          FontWeight.bold,

                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(
                        width: 10,
                      ),


                      // ===========================================
                      // ABONNEMENT
                      // ===========================================

                      Expanded(

                        child: Card(

                          child: InkWell(

                            borderRadius:
                                BorderRadius.circular(4),

                            onTap: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>
                                      const SubscriptionPage(),

                                ),
                              );
                            },


                            child: Padding(

                              padding:
                                  const EdgeInsets.all(15),

                              child: Column(

                                children: [

                                  Icon(

                                    abonnementValide
                                        ? Icons.workspace_premium
                                        : Icons.block,

                                    color:

                                        abonnementValide
                                            ? Colors.green
                                            : Colors.red,

                                    size: 35,

                                  ),


                                  const SizedBox(
                                    height: 10,
                                  ),


                                  Text(

                                    abonnementValide
                                        ? "ACTIF"
                                        : "INACTIF",

                                    style:
                                        TextStyle(

                                      fontSize: 20,

                                      fontWeight:
                                          FontWeight.bold,

                                      color:

                                          abonnementValide
                                              ? Colors.green
                                              : Colors.red,

                                    ),
                                  ),


                                  const Text(
                                    "Abonnement",
                                  ),


                                  if (expiration != null)

                                    Text(

                                      abonnementValide
                                          ? "Expire le ${_formatDate(expiration)}"
                                          : "Expiré le ${_formatDate(expiration)}",

                                      textAlign:
                                          TextAlign.center,

                                      style:
                                          const TextStyle(

                                        fontSize: 11,

                                        color:
                                            Colors.grey,

                                      ),
                                    ),


                                  const SizedBox(
                                    height: 8,
                                  ),


                                  const Text(

                                    "Appuyer pour renouveler",

                                    style:
                                        TextStyle(

                                      fontSize: 11,

                                      color:
                                          Colors.orange,

                                      fontWeight:
                                          FontWeight.bold,

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


                  const SizedBox(
                    height: 25,
                  ),


                  // =================================================
                  // MON COMMERCE
                  // =================================================

                  Card(

                    child: ListTile(

                      leading:
                          const Icon(
                        Icons.store,
                      ),

                      title:
                          const Text(
                        "Mon commerce",
                      ),

                      subtitle:
                          const Text(
                        "Logo, galerie, couverture, informations",
                      ),

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                const MyBusinessPage(),

                          ),
                        );
                      },
                    ),
                  ),


                  // =================================================
                  // CATALOGUE
                  // =================================================

                  Card(

                    child: ListTile(

                      leading:
                          const Icon(
                        Icons.inventory_2,
                      ),

                      title:
                          const Text(
                        "Catalogue",
                      ),

                      subtitle:
                          const Text(
                        "Gérer les services",
                      ),

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                CatalogPage(

                              adminMode:
                                  true,

                              commerceId:
                                  commerceId,

                            ),

                          ),
                        );
                      },
                    ),
                  ),


                  // =================================================
                  // RESERVATIONS
                  // =================================================

                  Card(

                    child: ListTile(

                      leading:
                          const Icon(
                        Icons.calendar_month,
                      ),

                      title:
                          const Text(
                        "Réservations",
                      ),

                      subtitle: Text(

                        pendingReservations == 0

                            ? "Aucune réservation en attente"

                            : "$pendingReservations réservation(s) en attente",

                        style:
                            TextStyle(

                          color:

                              pendingReservations == 0
                                  ? Colors.grey
                                  : Colors.red,

                          fontWeight:
                              FontWeight.bold,

                        ),
                      ),


                      trailing:

                          pendingReservations == 0

                              ? null

                              : CircleAvatar(

                                  radius: 14,

                                  backgroundColor:
                                      Colors.red,

                                  child: Text(

                                    pendingReservations
                                        .toString(),

                                    style:
                                        const TextStyle(

                                      color:
                                          Colors.white,

                                      fontSize: 12,

                                      fontWeight:
                                          FontWeight.bold,

                                    ),
                                  ),
                                ),


                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                const ReservationsAdminPage(),

                          ),
                        );
                      },
                    ),
                  ),


                  // =================================================
                  // CLIENTS
                  // =================================================

                  Card(

                    child: ListTile(

                      leading:
                          const Icon(
                        Icons.people,
                      ),

                      title:
                          const Text(
                        "Clients",
                      ),

                      subtitle:
                          Text(

                        "$nombreClients client(s) enregistré(s)",

                      ),

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                const ClientsPage(),

                          ),
                        );
                      },
                    ),
                  ),


                  // =================================================
                  // STATISTIQUES
                  // =================================================

                  Card(

                    child: ListTile(

                      leading:
                          const Icon(
                        Icons.bar_chart,
                      ),

                      title:
                          const Text(
                        "Statistiques",
                      ),

                      subtitle:
                          const Text(
                        "Voir les statistiques",
                      ),

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                const StatistiquesPage(),

                          ),
                        );
                      },
                    ),
                  ),

                ],
              ),
            );
          },
        );
      },
    );
  }


  // ============================================================
  // FORMAT DATE
  // ============================================================

  static String _formatDate(
    DateTime date,
  ) {

    return
        "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}
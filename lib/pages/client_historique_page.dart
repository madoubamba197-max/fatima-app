import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientHistoriquePage extends StatelessWidget {
  final String clientName;
  final String phone;
  final String commerceId;

  const ClientHistoriquePage({
    super.key,
    required this.clientName,
    required this.phone,
    required this.commerceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reservations")
            .where(
              "commerceId",
              isEqualTo: commerceId,
            )
            .where(
              "phone",
              isEqualTo: phone,
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

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aucune réservation trouvée.",
              ),
            );
          }

          final reservations =
              snapshot.data!.docs.toList();

          // Tri du plus récent au plus ancien
          reservations.sort((a, b) {
            final dataA =
                a.data()
                    as Map<String, dynamic>;

            final dataB =
                b.data()
                    as Map<String, dynamic>;

            final dateA =
                dataA["reservationDate"];

            final dateB =
                dataB["reservationDate"];

            if (dateA is Timestamp &&
                dateB is Timestamp) {
              return dateB
                  .compareTo(dateA);
            }

            return 0;
          });

          return ListView(
            padding: const EdgeInsets.all(15),

            children: [

              // ==================================================
              // INFORMATIONS CLIENT
              // ==================================================

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(18),

                  child: Row(
                    children: [

                      const CircleAvatar(
                        radius: 30,
                        child: Icon(
                          Icons.person,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              clientName,
                              style:
                                  const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(phone),

                            const SizedBox(height: 5),

                            Text(
                              "${reservations.length} réservation(s)",
                              style:
                                  const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Historique des réservations",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // RESERVATIONS
              // ==================================================

              ...reservations.map((doc) {
                final data =
                    doc.data()
                        as Map<String, dynamic>;

                DateTime? date;

                final reservationDate =
                    data["reservationDate"];

                if (reservationDate
                    is Timestamp) {
                  date =
                      reservationDate.toDate();
                }

                final status =
                    data["status"]
                            ?.toString() ??
                        "";

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: Padding(
                    padding:
                        const EdgeInsets.all(15),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          data["serviceName"]
                                  ?.toString() ??
                              "Service",

                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        if (date != null) ...[
                          Text(
                            "Date : "
                            "${date.day}/"
                            "${date.month}/"
                            "${date.year}",
                          ),

                          Text(
                            "Heure : "
                            "${date.hour.toString().padLeft(2, '0')}:"
                            "${date.minute.toString().padLeft(2, '0')}",
                          ),
                        ],

                        const SizedBox(height: 8),

                        Row(
                          children: [

                            const Text(
                              "Statut : ",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            Text(
                              status,
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    couleurStatut(
                                  status,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Color couleurStatut(String statut) {
    switch (
        statut.toLowerCase().trim()) {

      case "en attente":
        return Colors.orange;

      case "confirmée":
      case "confirmee":
        return Colors.green;

      case "terminée":
      case "terminee":
        return Colors.teal;

      case "refusée":
      case "refusee":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }
}
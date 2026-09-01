import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_storage/application_manager.dart';

class ReservationsStatutPage extends StatelessWidget {
  final String statut;

  const ReservationsStatutPage({
    super.key,
    required this.statut,
  });

  // ==========================================================
  // NORMALISER LE STATUT
  // ==========================================================

  String _normaliserStatut(String statut) {
    final valeur = statut.toLowerCase().trim();

    switch (valeur) {
      case "en attente":
        return "en attente";

      case "confirmée":
      case "confirmee":
        return "confirmée";

      case "terminée":
      case "terminee":
        return "terminée";

      case "refusée":
      case "refusee":
        return "refusée";

      default:
        return valeur;
    }
  }

  // ==========================================================
  // COULEUR DU STATUT
  // ==========================================================

  Color _couleurStatut(String statut) {
    switch (statut.toLowerCase().trim()) {
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

  // ==========================================================
  // AFFICHER L'IMAGE DU SERVICE
  // ==========================================================

  Widget _afficherImageService(
    String image,
  ) {
    final imageData = image.trim();

    // ----------------------------------------------------------
    // AUCUNE IMAGE
    // ----------------------------------------------------------

    if (imageData.isEmpty) {
      return _imageIndisponible();
    }

    // ----------------------------------------------------------
    // IMAGE BASE64
    // ----------------------------------------------------------

    try {
      final Uint8List bytes =
          base64Decode(imageData);

      return ClipRRect(
        borderRadius:
            BorderRadius.circular(12),

        child: Image.memory(
          bytes,

          width: double.infinity,

          height: 180,

          fit: BoxFit.cover,

          errorBuilder:
              (context, error, stackTrace) {
            return _imageIndisponible();
          },
        ),
      );
    } catch (_) {
      // Ce n'est pas du Base64.
    }

    // ----------------------------------------------------------
    // IMAGE URL
    // ----------------------------------------------------------

    if (imageData.startsWith("http")) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(12),

        child: Image.network(
          imageData,

          width: double.infinity,

          height: 180,

          fit: BoxFit.cover,

          loadingBuilder:
              (
            context,
            child,
            loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }

            return Container(
              width: double.infinity,
              height: 180,

              decoration:
                  BoxDecoration(
                color:
                    Colors.grey.shade200,

                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),

              child: const Center(
                child:
                    CircularProgressIndicator(),
              ),
            );
          },

          errorBuilder:
              (context, error, stackTrace) {
            return _imageIndisponible();
          },
        ),
      );
    }

    // ----------------------------------------------------------
    // IMAGE INCONNUE
    // ----------------------------------------------------------

    return _imageIndisponible();
  }

  // ==========================================================
  // IMAGE INDISPONIBLE
  // ==========================================================

  Widget _imageIndisponible() {
    return Container(
      width: double.infinity,

      height: 180,

      decoration: BoxDecoration(
        color: Colors.grey.shade200,

        borderRadius:
            BorderRadius.circular(12),
      ),

      child: const Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            Icons.image_not_supported,
            size: 55,
            color: Colors.grey,
          ),

          SizedBox(height: 8),

          Text(
            "Photo indisponible",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final app =
        ApplicationManager
            .getCurrentApplication();

    // ----------------------------------------------------------
    // COMMERCE INTROUVABLE
    // ----------------------------------------------------------

    if (app == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Commerce introuvable",
          ),
        ),
      );
    }

    final commerceId =
        app.commerceId;

    // ----------------------------------------------------------
    // NORMALISATION DU STATUT RECHERCHE
    // ----------------------------------------------------------

    final statutRecherche =
        _normaliserStatut(statut);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Réservations - $statut",
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore
            .instance
            .collection("reservations")
            .where(
              "commerceId",
              isEqualTo: commerceId,
            )
            .snapshots(),

        builder:
            (context, snapshot) {

          // ====================================================
          // CHARGEMENT
          // ====================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // ====================================================
          // ERREUR
          // ====================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Text(
                  "Erreur : "
                  "${snapshot.error}",

                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          // ====================================================
          // AUCUNE DONNÉE
          // ====================================================

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "Aucune réservation",
              ),
            );
          }

          // ====================================================
          // FILTRER LES RESERVATIONS
          // ====================================================

          final reservations =
              snapshot.data!.docs
                  .where(
            (doc) {

              final data =
                  doc.data()
                      as Map<String, dynamic>;

              final status =
                  _normaliserStatut(
                data["status"]
                        ?.toString() ??
                    "",
              );

              return status ==
                  statutRecherche;
            },
          ).toList();

          // ====================================================
          // AUCUNE RESERVATION POUR CE STATUT
          // ====================================================

          if (reservations.isEmpty) {
            return Center(
              child: Text(
                "Aucune réservation $statut.",
                style:
                    const TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          // ====================================================
          // LISTE DES RESERVATIONS
          // ====================================================

          return ListView.builder(
            padding:
                const EdgeInsets.all(10),

            itemCount:
                reservations.length,

            itemBuilder:
                (context, index) {

              final doc =
                  reservations[index];

              final data =
                  doc.data()
                      as Map<String, dynamic>;

              // =================================================
              // DATE
              // =================================================

              DateTime? date;

              final reservationDate =
                  data[
                      "reservationDate"];

              if (reservationDate
                  is Timestamp) {
                date =
                    reservationDate.toDate();
              }

              // =================================================
              // INFORMATIONS
              // =================================================

              final clientName =
                  data["clientName"]
                          ?.toString() ??
                      "";

              final serviceName =
                  data["serviceName"]
                          ?.toString() ??
                      "";

              final phone =
                  data["phone"]
                          ?.toString() ??
                      "";

              final serviceImage =
                  data["serviceImage"]
                          ?.toString() ??
                      "";

              final status =
                  data["status"]
                          ?.toString() ??
                      "";

              // =================================================
              // CARTE
              // =================================================

              return Card(
                elevation: 3,

                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),

                clipBehavior:
                    Clip.antiAlias,

                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    15,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      // =========================================
                      // PHOTO DU SERVICE
                      // =========================================

                      _afficherImageService(
                        serviceImage,
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // =========================================
                      // NOM DU SERVICE
                      // =========================================

                      Text(
                        serviceName,

                        style:
                            const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // =========================================
                      // CLIENT
                      // =========================================

                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 20,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child: Text(
                              clientName,

                              style:
                                  const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      // =========================================
                      // TELEPHONE
                      // =========================================

                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 20,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Text(
                            phone,

                            style:
                                const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      // =========================================
                      // DATE ET HEURE
                      // =========================================

                      if (date != null) ...[
                        const SizedBox(
                          height: 8,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 20,
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Text(
                              "${date.day.toString().padLeft(2, '0')}/"
                              "${date.month.toString().padLeft(2, '0')}/"
                              "${date.year}",

                              style:
                                  const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 20,
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Text(
                              "${date.hour.toString().padLeft(2, '0')}:"
                              "${date.minute.toString().padLeft(2, '0')}",

                              style:
                                  const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(
                        height: 12,
                      ),

                      // =========================================
                      // STATUT
                      // =========================================

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),

                        decoration:
                            BoxDecoration(
                          color: _couleurStatut(
                            status,
                          ).withOpacity(
                            0.12,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),

                        child: Text(
                          "Statut : $status",

                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,

                            color:
                                _couleurStatut(
                              status,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
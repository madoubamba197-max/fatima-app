import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_storage/application_manager.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {

  // ==========================================================
  // APPELER LE CLIENT
  // ==========================================================

  Future<void> appelerClient(String numero) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: numero,
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  // ==========================================================
  // WHATSAPP
  // ==========================================================

  Future<void> whatsappClient(
    String numero,
    String nom,
  ) async {
    final message =
        "Bonjour $nom, votre réservation a bien été reçue. "
        "Merci de nous confirmer votre disponibilité.";

    final Uri url = Uri.parse(
      "https://wa.me/$numero"
      "?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return "Date non définie";
    }

    final date = timestamp.toDate();

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  // ==========================================================
  // FORMAT HEURE
  // ==========================================================

  String _formatHeure(Timestamp? timestamp) {
    if (timestamp == null) {
      return "--:--";
    }

    final date = timestamp.toDate();

    return "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  // ==========================================================
  // COULEUR DU STATUT
  // ==========================================================

  Color _couleurStatut(String status) {
    switch (status) {
      case "En attente":
        return Colors.orange;

      case "Confirmée":
        return Colors.green;

      case "Refusée":
        return Colors.red;

      case "Terminée":
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  // ==========================================================
  // ICÔNE DU STATUT
  // ==========================================================

  IconData _iconeStatut(String status) {
    switch (status) {
      case "En attente":
        return Icons.access_time;

      case "Confirmée":
        return Icons.check_circle;

      case "Refusée":
        return Icons.cancel;

      case "Terminée":
        return Icons.done_all;

      default:
        return Icons.info;
    }
  }

  // ==========================================================
  // CHANGER LE STATUT
  // ==========================================================

  Future<void> _changerStatut(
    String reservationId,
    String nouveauStatut,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection("reservations")
          .doc(reservationId)
          .update({
        "status": nouveauStatut,
        "updatedAt": Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Réservation $nouveauStatut.",
          ),
          backgroundColor:
              _couleurStatut(nouveauStatut),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur : $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // IMAGE ARTICLE
  //
  // Accepte :
  // 1. une URL Firebase/HTTP
  // 2. une image Base64
  // ==========================================================

  Widget _imageArticle(String image) {
    final imageValue = image.trim();

    // ----------------------------------------------------------
    // AUCUNE IMAGE
    // ----------------------------------------------------------

    if (imageValue.isEmpty) {
      return _imageIndisponible();
    }

    // ----------------------------------------------------------
    // IMAGE PAR URL
    // ----------------------------------------------------------

    if (imageValue.startsWith("http://") ||
        imageValue.startsWith("https://")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageValue,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          loadingBuilder:
              (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return Container(
              width: 110,
              height: 110,
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(),
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
    // IMAGE BASE64
    // ----------------------------------------------------------

    try {
      String base64Image = imageValue;

      // Si la valeur contient :
      // data:image/jpeg;base64,...
      // on retire l'en-tête.

      if (base64Image.contains(",")) {
        base64Image =
            base64Image.split(",").last;
      }

      final Uint8List bytes =
          base64Decode(base64Image);

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          bytes,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return _imageIndisponible();
          },
        ),
      );
    } catch (e) {
      return _imageIndisponible();
    }
  }

  // ==========================================================
  // IMAGE INDISPONIBLE
  // ==========================================================

  Widget _imageIndisponible() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 35,
          ),
          SizedBox(height: 5),
          Text(
            "Image indisponible",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CARTE RESERVATION
  // ==========================================================

  Widget _carteReservation(
    BuildContext context,
    QueryDocumentSnapshot doc,
  ) {
    final data =
        doc.data() as Map<String, dynamic>;

    final reservationId = doc.id;

    // ----------------------------------------------------------
    // CLIENT
    // ----------------------------------------------------------

    final clientName =
        data["clientName"]
                ?.toString()
                .trim() ??
            "Client";

    // ----------------------------------------------------------
    // TELEPHONE
    // ----------------------------------------------------------

    final phone =
        data["phone"]
                ?.toString()
                .trim() ??
            "";

    // ----------------------------------------------------------
    // SERVICE
    // ----------------------------------------------------------

    final serviceName =
        data["serviceName"]
                ?.toString()
                .trim() ??
            "Article";

    // ----------------------------------------------------------
    // IMAGE
    //
    // IMPORTANT :
    // Firestore enregistre l'image dans :
    // serviceImageBase64
    // ----------------------------------------------------------

    final serviceImage =
        data["serviceImageBase64"]
                ?.toString()
                .trim() ??
            "";

    // ----------------------------------------------------------
    // COMMENTAIRE
    // ----------------------------------------------------------

    final comment =
        data["comment"]
                ?.toString()
                .trim() ??
            "";

    // ----------------------------------------------------------
    // STATUT
    // ----------------------------------------------------------

    final status =
        data["status"]
                ?.toString() ??
            "En attente";

    // ----------------------------------------------------------
    // DATE RESERVATION
    // ----------------------------------------------------------

    Timestamp? reservationDate;

    if (data["reservationDate"]
        is Timestamp) {
      reservationDate =
          data["reservationDate"]
              as Timestamp;
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // ==================================================
            // ARTICLE + PHOTO
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                // PHOTO
                _imageArticle(
                  serviceImage,
                ),

                const SizedBox(
                  width: 15,
                ),

                // INFORMATIONS SERVICE
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        serviceName,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Row(
                        children: [

                          Icon(
                            _iconeStatut(
                              status,
                            ),
                            color:
                                _couleurStatut(
                              status,
                            ),
                            size: 19,
                          ),

                          const SizedBox(
                            width: 5,
                          ),

                          Flexible(
                            child: Text(
                              status,
                              style:
                                  TextStyle(
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
                    ],
                  ),
                ),
              ],
            ),

            const Divider(
              height: 25,
            ),

            // ==================================================
            // CLIENT
            // ==================================================

            Text(
              "👤 Client : $clientName",
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              "📞 $phone",
            ),

            const SizedBox(
              height: 6,
            ),

            // ==================================================
            // DATE
            // ==================================================

            Text(
              "📅 ${_formatDate(reservationDate)}",
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              "🕒 ${_formatHeure(reservationDate)}",
            ),

            // ==================================================
            // COMMENTAIRE
            // ==================================================

            if (comment.isNotEmpty) ...[
              const SizedBox(
                height: 10,
              ),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(12),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  "💬 $comment",
                ),
              ),
            ],

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // APPEL / WHATSAPP
            // ==================================================

            Row(
              children: [

                Expanded(
                  child:
                      ElevatedButton.icon(
                    icon:
                        const Icon(
                      Icons.phone,
                    ),
                    label:
                        const Text(
                      "Appeler",
                    ),
                    onPressed:
                        phone.isEmpty
                            ? null
                            : () {
                                appelerClient(
                                  phone,
                                );
                              },
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child:
                      ElevatedButton.icon(
                    icon:
                        const Icon(
                      Icons.chat,
                    ),
                    label:
                        const Text(
                      "WhatsApp",
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green,
                      foregroundColor:
                          Colors.white,
                    ),
                    onPressed:
                        phone.isEmpty
                            ? null
                            : () {
                                whatsappClient(
                                  phone,
                                  clientName,
                                );
                              },
                  ),
                ),
              ],
            ),

            // ==================================================
            // ACTIONS RESERVATION
            // ==================================================

            if (status ==
                "En attente") ...[
              const SizedBox(
                height: 10,
              ),

              Row(
                children: [

                  Expanded(
                    child:
                        ElevatedButton.icon(
                      icon:
                          const Icon(
                        Icons.check,
                      ),
                      label:
                          const Text(
                        "Confirmer",
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,
                        foregroundColor:
                            Colors.white,
                      ),
                      onPressed: () {
                        _changerStatut(
                          reservationId,
                          "Confirmée",
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child:
                        ElevatedButton.icon(
                      icon:
                          const Icon(
                        Icons.close,
                      ),
                      label:
                          const Text(
                        "Refuser",
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red,
                        foregroundColor:
                            Colors.white,
                      ),
                      onPressed: () {
                        _changerStatut(
                          reservationId,
                          "Refusée",
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],

            // ==================================================
            // TERMINER
            // ==================================================

            if (status ==
                "Confirmée") ...[
              const SizedBox(
                height: 10,
              ),

              SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton.icon(
                  icon:
                      const Icon(
                    Icons.done_all,
                  ),
                  label:
                      const Text(
                    "Terminer la prestation",
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue,
                    foregroundColor:
                        Colors.white,
                  ),
                  onPressed: () {
                    _changerStatut(
                      reservationId,
                      "Terminée",
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final application =
        ApplicationManager
            .getCurrentApplication();

    // ========================================================
    // COMMERCE INTROUVABLE
    // ========================================================

    if (application == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Commerce introuvable.",
          ),
        ),
      );
    }

    final commerceId =
        application.commerceId;

    // ========================================================
    // PAGE
    // ========================================================

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          "Réservations",
        ),
      ),

      body:
          StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection(
                  "reservations",
                )
                .where(
                  "commerceId",
                  isEqualTo:
                      commerceId,
                )
                .snapshots(),

        builder:
            (context, snapshot) {

          // ==================================================
          // CHARGEMENT
          // ==================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // ==================================================
          // ERREUR
          // ==================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Text(
                  "Erreur lors du chargement "
                  "des réservations :\n"
                  "${snapshot.error}",
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          // ==================================================
          // AUCUNE RESERVATION
          // ==================================================

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [

                  Icon(
                    Icons.event_available,
                    size: 65,
                    color: Colors.grey,
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  Text(
                    "Aucune réservation",
                    style:
                        TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            );
          }

          // ==================================================
          // RECUPERATION DES RESERVATIONS
          // ==================================================

          final reservations =
              snapshot.data!.docs.toList();

          // ==================================================
          // TRI PAR DATE
          // Plus récente en premier
          // ==================================================

          reservations.sort(
            (a, b) {
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
            },
          );

          // ==================================================
          // LISTE
          // ==================================================

          return ListView.builder(
            padding:
                const EdgeInsets.only(
              top: 8,
              bottom: 20,
            ),

            itemCount:
                reservations.length,

            itemBuilder:
                (context, index) {

              return _carteReservation(
                context,
                reservations[index],
              );
            },
          );
        },
      ),
    );
  }
}
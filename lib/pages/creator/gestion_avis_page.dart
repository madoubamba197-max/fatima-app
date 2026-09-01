import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestionAvisPage extends StatefulWidget {
  const GestionAvisPage({
    super.key,
  });

  @override
  State<GestionAvisPage> createState() =>
      _GestionAvisPageState();
}

class _GestionAvisPageState
    extends State<GestionAvisPage> {
  // ==========================================================
  // CONTRÔLEUR DE RECHERCHE
  // ==========================================================

  final TextEditingController rechercheController =
      TextEditingController();

  String recherche = "";

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    rechercheController.dispose();
    super.dispose();
  }

  // ==========================================================
  // SUPPRESSION D'UN AVIS
  // ==========================================================

  Future<void> _supprimerAvis({
    required BuildContext context,
    required String commerceId,
    required String avisId,
    required String nomClient,
  }) async {
    // ========================================================
    // CONFIRMATION
    // ========================================================

    final confirmation =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Supprimer cet avis ?",
          ),
          content: Text(
            "Voulez-vous vraiment supprimer "
            "l'avis de $nomClient ?\n\n"
            "Cette action doit être utilisée uniquement "
            "pour un avis faux, abusif ou injustifié.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                "Annuler",
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              icon: const Icon(
                Icons.delete,
              ),
              label: const Text(
                "Supprimer",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirmation != true) {
      return;
    }

    // ========================================================
    // AFFICHER LE CHARGEMENT
    // ========================================================

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(25),
              child:
                  CircularProgressIndicator(),
            ),
          ),
        );
      },
    );

    try {
      final firestore =
          FirebaseFirestore.instance;

      final commerceRef =
          firestore
              .collection("commerces")
              .doc(commerceId);

      final avisRef =
          commerceRef
              .collection("avis")
              .doc(avisId);

      // ======================================================
      // RÉCUPÉRER TOUS LES AVIS
      // ======================================================

      final avisQuery =
          await commerceRef
              .collection("avis")
              .get();

      double totalNotes = 0;
      int nombreAvis = 0;

      for (final doc in avisQuery.docs) {
        // Ne pas compter l'avis
        // qui va être supprimé.
        if (doc.id == avisId) {
          continue;
        }

        final data = doc.data();

        final valeur = data["note"];

        double? note;

        if (valeur is num) {
          note = valeur.toDouble();
        } else {
          note = double.tryParse(
            valeur?.toString() ?? "",
          );
        }

        // Sécurité :
        // note comprise entre 0 et 5.
        if (note != null &&
            note >= 0 &&
            note <= 5) {
          totalNotes += note;
          nombreAvis++;
        }
      }

      // ======================================================
      // NOUVELLE MOYENNE
      // ======================================================

      final double nouvelleMoyenne =
          nombreAvis == 0
              ? 0.0
              : totalNotes / nombreAvis;

      // ======================================================
      // VÉRIFIER QUE L'AVIS EXISTE
      // ======================================================

      final avisExiste =
          await avisRef.get();

      if (!avisExiste.exists) {
        throw Exception(
          "Cet avis n'existe plus.",
        );
      }

      // ======================================================
      // TRANSACTION
      // ======================================================

      await firestore.runTransaction(
        (transaction) async {
          transaction.delete(
            avisRef,
          );

          transaction.update(
            commerceRef,
            {
              "rating":
                  nouvelleMoyenne,
              "reviews":
                  nombreAvis,
            },
          );
        },
      );

      // ======================================================
      // FERMER LE CHARGEMENT
      // ======================================================

      if (context.mounted) {
        Navigator.pop(context);
      }

      // ======================================================
      // MESSAGE SUCCÈS
      // ======================================================

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "L'avis a été supprimé avec succès.",
          ),
          backgroundColor:
              Colors.green,
        ),
      );
    } catch (e) {
      // ======================================================
      // FERMER LE CHARGEMENT
      // ======================================================

      if (context.mounted) {
        Navigator.pop(context);
      }

      debugPrint(
        "ERREUR SUPPRESSION AVIS : $e",
      );

      // ======================================================
      // MESSAGE ERREUR
      // ======================================================

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de supprimer l'avis : $e",
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String _formatDate(
    dynamic valeur,
  ) {
    if (valeur is Timestamp) {
      final date =
          valeur.toDate();

      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";
    }

    return "";
  }

  // ==========================================================
  // AFFICHER LES ÉTOILES
  // ==========================================================

  Widget _afficherEtoiles(
    dynamic valeur,
  ) {
    double note = 0;

    if (valeur is num) {
      note = valeur.toDouble();
    } else {
      note =
          double.tryParse(
                valeur?.toString() ?? "",
              ) ??
              0;
    }

    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children:
          List.generate(
        5,
        (index) {
          return Icon(
            index < note
                ? Icons.star
                : Icons.star_border,
            color:
                Colors.orange,
            size: 20,
          );
        },
      ),
    );
  }

  // ==========================================================
  // OUVRIR LES AVIS D'UN COMMERCE
  // ==========================================================

  void _ouvrirAvisCommerce({
    required BuildContext context,
    required String commerceId,
    required String nomCommerce,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AvisCommerceAdminPage(
          commerceId:
              commerceId,
          nomCommerce:
              nomCommerce,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gérer les avis",
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore
                .instance
                .collection("commerces")
                .orderBy("name")
                .snapshots(),

        builder:
            (
          context,
          snapshot,
        ) {
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
                    const EdgeInsets.all(
                  20,
                ),
                child: Text(
                  "Erreur lors du chargement "
                  "des commerces :\n"
                  "${snapshot.error}",
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          // ==================================================
          // AUCUN COMMERCE
          // ==================================================

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aucun commerce disponible.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            );
          }

          final tousLesCommerces =
              snapshot.data!.docs;

          // ==================================================
          // FILTRAGE RECHERCHE
          // ==================================================

          final commerces =
              tousLesCommerces.where((doc) {
            final data =
                doc.data()
                    as Map<String, dynamic>;

            // ------------------------------------------------
            // NOM
            // ------------------------------------------------

            final nom =
                data["name"]
                        ?.toString()
                        .toLowerCase()
                        .trim() ??
                    "";

            // ------------------------------------------------
            // ID
            // ------------------------------------------------

            final commerceId =
                doc.id
                    .toLowerCase()
                    .trim();

            // ------------------------------------------------
            // TÉLÉPHONE
            // ------------------------------------------------

            final telephone =
                data["phone"]
                        ?.toString()
                        .toLowerCase()
                        .trim() ??
                    "";

            // ------------------------------------------------
            // VILLE
            // ------------------------------------------------

            final ville =
                data["ville"]
                        ?.toString()
                        .toLowerCase()
                        .trim() ??
                    "";

            // ------------------------------------------------
            // RECHERCHE
            // ------------------------------------------------

            if (recherche.isEmpty) {
              return true;
            }

            return nom.contains(recherche) ||
                commerceId.contains(recherche) ||
                telephone.contains(recherche) ||
                ville.contains(recherche);
          }).toList();

          // ==================================================
          // INTERFACE
          // ==================================================

          return Column(
            children: [
              // =================================================
              // BARRE DE RECHERCHE
              // =================================================

              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  15,
                  15,
                  15,
                  10,
                ),
                child: TextField(
                  controller:
                      rechercheController,

                  onChanged: (value) {
                    setState(() {
                      recherche =
                          value
                              .toLowerCase()
                              .trim();
                    });
                  },

                  decoration:
                      InputDecoration(
                    hintText:
                        "Rechercher par nom, ID, téléphone ou ville...",

                    prefixIcon:
                        const Icon(
                      Icons.search,
                    ),

                    suffixIcon:
                        recherche.isNotEmpty
                            ? IconButton(
                                tooltip:
                                    "Effacer",

                                icon:
                                    const Icon(
                                  Icons.clear,
                                ),

                                onPressed: () {
                                  rechercheController
                                      .clear();

                                  setState(() {
                                    recherche =
                                        "";
                                  });
                                },
                              )
                            : null,

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),

                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                      borderSide:
                          BorderSide(
                        color:
                            Colors.grey.shade400,
                      ),
                    ),

                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            Colors.deepPurple,
                        width: 2,
                      ),
                    ),

                    filled: true,

                    fillColor:
                        Colors.grey.shade50,
                  ),
                ),
              ),

              // =================================================
              // NOMBRE DE RÉSULTATS
              // =================================================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 5,
                ),

                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 18,
                      color:
                          Colors.deepPurple,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Text(
                      recherche.isEmpty
                          ? "${commerces.length} commerces"
                          : "${commerces.length} résultat(s)",

                      style:
                          TextStyle(
                        color:
                            Colors.grey.shade700,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // AUCUN RÉSULTAT
              // =================================================

              if (commerces.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        25,
                      ),

                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [
                          Icon(
                            Icons.search_off,
                            size: 65,
                            color:
                                Colors.grey.shade400,
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          const Text(
                            "Aucun commerce trouvé.",
                            style:
                                TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            "Essayez avec un autre nom, "
                            "numéro de téléphone, ID ou ville.",
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )

              // =================================================
              // LISTE DES COMMERCES
              // =================================================

              else
                Expanded(
                  child:
                      ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(
                      15,
                      5,
                      15,
                      20,
                    ),

                    itemCount:
                        commerces.length,

                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      final doc =
                          commerces[index];

                      final data =
                          doc.data()
                              as Map<
                                  String,
                                  dynamic>;

                      final commerceId =
                          doc.id;

                      // ------------------------------------------------
                      // NOM
                      // ------------------------------------------------

                      final nomCommerce =
                          data["name"]
                                  ?.toString()
                                  .trim()
                                  .isNotEmpty ==
                              true
                              ? data["name"]
                                  .toString()
                                  .trim()
                              : "Commerce";

                      // ------------------------------------------------
                      // VILLE
                      // ------------------------------------------------

                      final ville =
                          data["ville"]
                                  ?.toString()
                                  .trim() ??
                              "";

                      // ------------------------------------------------
                      // TÉLÉPHONE
                      // ------------------------------------------------

                      final telephone =
                          data["phone"]
                                  ?.toString()
                                  .trim() ??
                              "";

                      // ------------------------------------------------
                      // NOTE
                      // ------------------------------------------------

                      final ratingValue =
                          data["rating"];

                      double rating = 0;

                      if (ratingValue
                          is num) {
                        rating =
                            ratingValue
                                .toDouble();
                      } else {
                        rating =
                            double.tryParse(
                                  ratingValue
                                          ?.toString() ??
                                      "",
                                ) ??
                                0;
                      }

                      // ------------------------------------------------
                      // NOMBRE D'AVIS
                      // ------------------------------------------------

                      final reviewsValue =
                          data["reviews"];

                      int reviews = 0;

                      if (reviewsValue
                          is num) {
                        reviews =
                            reviewsValue
                                .toInt();
                      } else {
                        reviews =
                            int.tryParse(
                                  reviewsValue
                                          ?.toString() ??
                                      "",
                                ) ??
                                0;
                      }

                      // =================================================
                      // CARTE COMMERCE
                      // =================================================

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),

                        elevation: 2,

                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),

                          // --------------------------------------------
                          // ICÔNE
                          // --------------------------------------------

                          leading:
                              CircleAvatar(
                            radius: 27,

                            backgroundColor:
                                Colors.deepPurple
                                    .shade50,

                            child:
                                const Icon(
                              Icons.store,
                              color:
                                  Colors.deepPurple,
                            ),
                          ),

                          // --------------------------------------------
                          // INFORMATIONS
                          // --------------------------------------------

                          title:
                              Text(
                            nomCommerce,

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize:
                                  17,
                            ),
                          ),

                          subtitle:
                              Padding(
                            padding:
                                const EdgeInsets.only(
                              top: 5,
                            ),

                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                // -------------------------------
                                // VILLE
                                // -------------------------------

                                if (ville
                                    .isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .location_on_outlined,
                                        size:
                                            16,
                                        color:
                                            Colors.deepPurple,
                                      ),

                                      const SizedBox(
                                        width:
                                            4,
                                      ),

                                      Expanded(
                                        child:
                                            Text(
                                          ville,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),

                                // -------------------------------
                                // TÉLÉPHONE
                                // -------------------------------

                                if (telephone
                                    .isNotEmpty)
                                  Padding(
                                    padding:
                                        const EdgeInsets
                                            .only(
                                      top: 3,
                                    ),

                                    child:
                                        Text(
                                      telephone,
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.grey.shade600,
                                        fontSize:
                                            13,
                                      ),
                                    ),
                                  ),

                                const SizedBox(
                                  height: 4,
                                ),

                                // -------------------------------
                                // NOTE + AVIS
                                // -------------------------------

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size:
                                          18,
                                      color:
                                          Colors.orange,
                                    ),

                                    const SizedBox(
                                      width:
                                          4,
                                    ),

                                    Text(
                                      rating
                                          .toStringAsFixed(
                                        1,
                                      ),
                                    ),

                                    const SizedBox(
                                      width:
                                          8,
                                    ),

                                    Text(
                                      "$reviews avis",
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // --------------------------------------------
                          // FLÈCHE
                          // --------------------------------------------

                          trailing:
                              const Icon(
                            Icons
                                .arrow_forward_ios,
                            size: 18,
                          ),

                          // --------------------------------------------
                          // OUVRIR
                          // --------------------------------------------

                          onTap: () {
                            _ouvrirAvisCommerce(
                              context:
                                  context,

                              commerceId:
                                  commerceId,

                              nomCommerce:
                                  nomCommerce,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// PAGE DES AVIS D'UN COMMERCE POUR LE SUPER ADMIN
// ============================================================

class AvisCommerceAdminPage
    extends StatelessWidget {
  final String commerceId;
  final String nomCommerce;

  const AvisCommerceAdminPage({
    super.key,
    required this.commerceId,
    required this.nomCommerce,
  });

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String _formatDate(
    dynamic valeur,
  ) {
    if (valeur is Timestamp) {
      final date =
          valeur.toDate();

      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";
    }

    return "";
  }

  // ==========================================================
  // ÉTOILES
  // ==========================================================

  Widget _etoiles(
    dynamic valeur,
  ) {
    double note = 0;

    if (valeur is num) {
      note =
          valeur.toDouble();
    } else {
      note =
          double.tryParse(
                valeur?.toString() ??
                    "",
              ) ??
              0;
    }

    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children:
          List.generate(
        5,
        (index) {
          return Icon(
            index < note
                ? Icons.star
                : Icons.star_border,
            color:
                Colors.orange,
            size: 21,
          );
        },
      ),
    );
  }

  // ==========================================================
  // SUPPRESSION
  // ==========================================================

  Future<void> _supprimerAvis(
    BuildContext context,
    String avisId,
    String nomClient,
  ) async {
    // ========================================================
    // CONFIRMATION
    // ========================================================

    final confirmation =
        await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) {
        return AlertDialog(
          title:
              const Text(
            "Supprimer l'avis",
          ),

          content:
              Text(
            "Voulez-vous supprimer définitivement "
            "l'avis de $nomClient ?\n\n"
            "Cette action est destinée aux avis "
            "faux, abusifs ou injustifiés.",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text(
                "Annuler",
              ),
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

              icon:
                  const Icon(
                Icons.delete,
              ),

              label:
                  const Text(
                "Supprimer",
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirmation != true) {
      return;
    }

    // ========================================================
    // CHARGEMENT
    // ========================================================

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible:
          false,
      builder: (_) {
        return const Center(
          child: Card(
            child: Padding(
              padding:
                  EdgeInsets.all(
                25,
              ),
              child:
                  CircularProgressIndicator(),
            ),
          ),
        );
      },
    );

    try {
      final firestore =
          FirebaseFirestore.instance;

      final commerceRef =
          firestore
              .collection(
                "commerces",
              )
              .doc(
                commerceId,
              );

      final avisRef =
          commerceRef
              .collection(
                "avis",
              )
              .doc(
                avisId,
              );

      // ======================================================
      // RÉCUPÉRER LES AVIS
      // ======================================================

      final avisSnapshot =
          await commerceRef
              .collection(
                "avis",
              )
              .get();

      double totalNotes = 0;
      int nombreAvis = 0;

      for (final doc
          in avisSnapshot.docs) {
        if (doc.id ==
            avisId) {
          continue;
        }

        final data =
            doc.data();

        final valeur =
            data["note"];

        double? note;

        if (valeur is num) {
          note =
              valeur.toDouble();
        } else {
          note =
              double.tryParse(
            valeur?.toString() ??
                "",
          );
        }

        if (note != null &&
            note >= 0 &&
            note <= 5) {
          totalNotes += note;
          nombreAvis++;
        }
      }

      // ======================================================
      // NOUVELLE MOYENNE
      // ======================================================

      final double nouvelleMoyenne =
          nombreAvis == 0
              ? 0.0
              : totalNotes /
                  nombreAvis;

      // ======================================================
      // VÉRIFIER QUE L'AVIS EXISTE
      // ======================================================

      final avisExiste =
          await avisRef.get();

      if (!avisExiste.exists) {
        throw Exception(
          "Cet avis n'existe plus.",
        );
      }

      // ======================================================
      // SUPPRESSION + MISE À JOUR
      // ======================================================

      await firestore.runTransaction(
        (transaction) async {
          transaction.delete(
            avisRef,
          );

          transaction.update(
            commerceRef,
            {
              "rating":
                  nouvelleMoyenne,

              "reviews":
                  nombreAvis,
            },
          );
        },
      );

      // ======================================================
      // FERMER CHARGEMENT
      // ======================================================

      if (context.mounted) {
        Navigator.pop(
          context,
        );
      }

      // ======================================================
      // MESSAGE
      // ======================================================

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            "Avis supprimé avec succès.",
          ),
          backgroundColor:
              Colors.green,
        ),
      );
    } catch (e) {
      // ======================================================
      // FERMER CHARGEMENT
      // ======================================================

      if (context.mounted) {
        Navigator.pop(
          context,
        );
      }

      debugPrint(
        "ERREUR SUPPRESSION AVIS : $e",
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
              Text(
            "Erreur : $e",
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(
          nomCommerce,
        ),
        centerTitle: true,
      ),

      body:
          StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore
                .instance
                .collection(
                  "commerces",
                )
                .doc(
                  commerceId,
                )
                .collection(
                  "avis",
                )
                .orderBy(
                  "createdAt",
                  descending:
                      true,
                )
                .snapshots(),

        builder:
            (
          context,
          snapshot,
        ) {
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
              child:
                  Padding(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                child:
                    Text(
                  "Erreur lors du chargement des avis :\n"
                  "${snapshot.error}",
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          // ==================================================
          // AUCUN AVIS
          // ==================================================

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child:
                  Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  Text(
                    "Aucun avis pour ce commerce.",
                    style:
                        TextStyle(
                      color:
                          Colors.grey,
                      fontSize:
                          16,
                    ),
                  ),
                ],
              ),
            );
          }

          final avis =
              snapshot.data!.docs;

          // ==================================================
          // LISTE
          // ==================================================

          return Column(
            children: [
              // =================================================
              // EN-TÊTE
              // =================================================

              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets.all(
                  15,
                ),

                color:
                    Colors.deepPurple
                        .shade50,

                child:
                    Row(
                  children: [
                    const Icon(
                      Icons.rate_review,
                      color:
                          Colors.deepPurple,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Text(
                      "${avis.length} avis",

                      style:
                          const TextStyle(
                        fontSize:
                            18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // AVIS
              // =================================================

              Expanded(
                child:
                    ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical:
                        10,
                  ),

                  itemCount:
                      avis.length,

                  itemBuilder:
                      (
                    context,
                    index,
                  ) {
                    final doc =
                        avis[index];

                    final data =
                        doc.data()
                            as Map<
                                String,
                                dynamic>;

                    // =========================================
                    // NOM CLIENT
                    // =========================================

                    final nomClient =
                        data["nomClient"]
                                ?.toString()
                                .trim()
                                .isNotEmpty ==
                            true
                            ? data[
                                    "nomClient"]
                                .toString()
                                .trim()
                            : data[
                                        "clientName"]
                                    ?.toString()
                                    .trim()
                                    .isNotEmpty ==
                                true
                                ? data[
                                        "clientName"]
                                    .toString()
                                    .trim()
                                : "Client";

                    // =========================================
                    // COMMENTAIRE
                    // =========================================

                    final commentaire =
                        data["commentaire"]
                                ?.toString()
                                .trim() ??
                            "";

                    // =========================================
                    // DATE
                    // =========================================

                    final date =
                        _formatDate(
                      data["createdAt"],
                    );

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal:
                            15,
                        vertical:
                            6,
                      ),

                      child:
                          Padding(
                        padding:
                            const EdgeInsets.all(
                          15,
                        ),

                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            // =================================
                            // CLIENT
                            // =================================

                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor:
                                      Colors.deepPurple,

                                  child:
                                      Icon(
                                    Icons.person,
                                    color:
                                        Colors.white,
                                  ),
                                ),

                                const SizedBox(
                                  width:
                                      10,
                                ),

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        nomClient,

                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize:
                                              16,
                                        ),
                                      ),

                                      const SizedBox(
                                        height:
                                            4,
                                      ),

                                      _etoiles(
                                        data[
                                            "note"],
                                      ),
                                    ],
                                  ),
                                ),

                                // =============================
                                // SUPPRIMER
                                // =============================

                                IconButton(
                                  tooltip:
                                      "Supprimer",

                                  icon:
                                      const Icon(
                                    Icons.delete_outline,
                                    color:
                                        Colors.red,
                                  ),

                                  onPressed:
                                      () {
                                    _supprimerAvis(
                                      context,
                                      doc.id,
                                      nomClient,
                                    );
                                  },
                                ),
                              ],
                            ),

                            // =================================
                            // COMMENTAIRE
                            // =================================

                            if (commentaire
                                .isNotEmpty) ...[
                              const SizedBox(
                                height:
                                    12,
                              ),

                              Container(
                                width:
                                    double.infinity,

                                padding:
                                    const EdgeInsets.all(
                                  12,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.grey.shade100,

                                  borderRadius:
                                      BorderRadius.circular(
                                    10,
                                  ),
                                ),

                                child:
                                    Text(
                                  commentaire,

                                  style:
                                      const TextStyle(
                                    fontSize:
                                        15,
                                  ),
                                ),
                              ),
                            ],

                            // =================================
                            // DATE
                            // =================================

                            if (date
                                .isNotEmpty) ...[
                              const SizedBox(
                                height:
                                    8,
                              ),

                              Text(
                                "Publié le $date",

                                style:
                                    TextStyle(
                                  fontSize:
                                      12,
                                  color:
                                      Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
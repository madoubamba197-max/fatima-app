import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/contact_service.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() =>
      _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final TextEditingController rechercheController =
      TextEditingController();

  String recherche = "";

  @override
  void dispose() {
    rechercheController.dispose();
    super.dispose();
  }

  // ==========================================================
  // FORMAT DATE + HEURE
  // ==========================================================

  static String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return "Non définie";
    }

    final date = timestamp.toDate();

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} à "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  static String _formatDate(DateTime? date) {
    if (date == null) {
      return "Non définie";
    }

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gestion des abonnements",
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ====================================================
          // DEMANDES WAVE EN ATTENTE
          // ====================================================

          _sectionDemandesWave(),

          // ====================================================
          // RECHERCHE DES COMMERCES
          // ====================================================

          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: rechercheController,

              onChanged: (value) {
                setState(() {
                  recherche =
                      value.toLowerCase().trim();
                });
              },

              decoration: InputDecoration(
                hintText:
                    "Rechercher par nom, ID, téléphone ou propriétaire...",

                prefixIcon: const Icon(
                  Icons.search,
                ),

                suffixIcon:
                    recherche.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                            ),
                            onPressed: () {
                              rechercheController.clear();

                              setState(() {
                                recherche = "";
                              });
                            },
                          )
                        : null,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color:
                        Colors.grey.shade400,
                  ),
                ),

                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide:
                      const BorderSide(
                    color:
                        Colors.deepPurple,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // ====================================================
          // LISTE DES COMMERCES
          // ====================================================

          Expanded(
            child:
                StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore
                      .instance
                      .collection(
                        "commerces",
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
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),
                      child: Text(
                        "Erreur : ${snapshot.error}",
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
                      "Aucun commerce créé",
                      style:
                          TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  );
                }

                // ==================================================
                // FILTRAGE
                // ==================================================

                final commerces =
                    snapshot.data!.docs
                        .where(
                  (doc) {
                    final data =
                        doc.data()
                            as Map<
                                String,
                                dynamic>;

                    final nom =
                        (data["name"] ??
                                "")
                            .toString()
                            .toLowerCase();

                    final telephone =
                        (data["phone"] ??
                                "")
                            .toString()
                            .toLowerCase();

                    final proprietaire =
                        (data[
                                    "proprietaire"] ??
                                "")
                            .toString()
                            .toLowerCase();

                    final commerceId =
                        doc.id
                            .toLowerCase();

                    return nom.contains(
                          recherche,
                        ) ||
                        telephone.contains(
                          recherche,
                        ) ||
                        proprietaire.contains(
                          recherche,
                        ) ||
                        commerceId.contains(
                          recherche,
                        );
                  },
                ).toList();

                // ==================================================
                // AUCUN RÉSULTAT
                // ==================================================

                if (commerces.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun commerce trouvé",
                      style:
                          TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                // ==================================================
                // LISTE
                // ==================================================

                return ListView.builder(
                  padding:
                      const EdgeInsets.all(
                    15,
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

                    final nom =
                        data["name"]
                                ?.toString() ??
                            "Commerce sans nom";

                    final telephone =
                        data["phone"]
                                ?.toString() ??
                            "";

                    // =================================================
                    // DATES
                    // =================================================

                    DateTime?
                        dateAbonnement;

                    DateTime?
                        dateExpiration;

                    if (data[
                            "dateAbonnement"]
                        is Timestamp) {
                      dateAbonnement =
                          (data[
                                      "dateAbonnement"]
                                  as Timestamp)
                              .toDate();
                    }

                    if (data[
                            "expirationAbonnement"]
                        is Timestamp) {
                      dateExpiration =
                          (data[
                                      "expirationAbonnement"]
                                  as Timestamp)
                              .toDate();
                    }

                    final maintenant =
                        DateTime.now();

                    // =================================================
                    // JOURS RESTANTS
                    // =================================================

                    int? joursRestants;

                    if (dateExpiration !=
                        null) {
                      joursRestants =
                          dateExpiration
                              .difference(
                                maintenant,
                              )
                              .inDays;
                    }

                    // =================================================
                    // STATUT
                    // =================================================

                    final abonnementActif =
                        data[
                                "abonnementActif"] ==
                            true;

                    final abonnementExpire =
                        !abonnementActif ||
                        dateExpiration ==
                            null ||
                        !dateExpiration
                            .isAfter(
                          maintenant,
                        );

                    final abonnementBientotExpire =
                        abonnementActif &&
                        !abonnementExpire &&
                        joursRestants !=
                            null &&
                        joursRestants <= 7;

                    // =================================================
                    // CARTE COMMERCE
                    // =================================================

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 15,
                      ),

                      elevation: 2,

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
                            // NOM
                            // =========================================

                            Text(
                              nom,

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
                            // ID
                            // =========================================

                            Text(
                              "Commerce ID : $commerceId",
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            // =========================================
                            // TÉLÉPHONE
                            // =========================================

                            Text(
                              "Téléphone : $telephone",
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            // =========================================
                            // DATE ABONNEMENT
                            // =========================================

                            Text(
                              "Date abonnement : "
                              "${_formatDate(dateAbonnement)}",
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            // =========================================
                            // DURÉE
                            // =========================================

                            Text(
                              "Durée : "
                              "${data["dureeAbonnement"] ?? "Non définie"}",
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            // =========================================
                            // DATE EXPIRATION
                            // =========================================

                            Text(
                              "Date expiration : "
                              "${_formatDate(dateExpiration)}",
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            // =========================================
                            // STATUT
                            // =========================================

                            Row(
                              children: [
                                Icon(
                                  abonnementExpire
                                      ? Icons.cancel
                                      : abonnementBientotExpire
                                          ? Icons.warning
                                          : Icons.check_circle,

                                  color:
                                      abonnementExpire
                                          ? Colors.red
                                          : abonnementBientotExpire
                                              ? Colors.orange
                                              : Colors.green,
                                ),

                                const SizedBox(
                                  width: 8,
                                ),

                                Expanded(
                                  child: Text(
                                    abonnementExpire
                                        ? "Abonnement expiré"
                                        : abonnementBientotExpire
                                            ? "Abonnement bientôt expiré"
                                            : "Abonnement actif",

                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight.bold,

                                      color:
                                          abonnementExpire
                                              ? Colors.red
                                              : abonnementBientotExpire
                                                  ? Colors.orange
                                                  : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            // =========================================
                            // JOURS RESTANTS
                            // =========================================

                            if (!abonnementExpire &&
                                joursRestants !=
                                    null)
                              Text(
                                joursRestants == 0
                                    ? "Il reste moins d'un jour"
                                    : "Il reste $joursRestants "
                                        "jour${joursRestants > 1 ? 's' : ''}",

                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight.bold,

                                  color:
                                      abonnementBientotExpire
                                          ? Colors.orange
                                          : Colors.green,
                                ),
                              ),

                            const SizedBox(
                              height: 15,
                            ),

                            // =========================================
                            // BOUTONS
                            // =========================================

                            Row(
                              children: [
                                Expanded(
                                  child:
                                      ElevatedButton
                                          .icon(
                                    icon:
                                        const Icon(
                                      Icons.check,
                                    ),

                                    label:
                                        const Text(
                                      "Activer",
                                    ),

                                    onPressed:
                                        () async {
                                      await _activer(
                                        context,
                                        commerceId,
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                Expanded(
                                  child:
                                      ElevatedButton
                                          .icon(
                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          Colors.red,
                                      foregroundColor:
                                          Colors.white,
                                    ),

                                    icon:
                                        const Icon(
                                      Icons.block,
                                    ),

                                    label:
                                        const Text(
                                      "Désactiver",
                                    ),

                                    onPressed:
                                        () async {
                                      await _desactiver(
                                        context,
                                        commerceId,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION DEMANDES WAVE
  // ==========================================================

  Widget _sectionDemandesWave() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore
              .instance
              .collection(
                "demandes_abonnement",
              )
              .where(
                "statut",
                isEqualTo: "en_attente",
              )
              .snapshots(),

      builder:
          (
        context,
        snapshot,
      ) {
        // ======================================================
        // CHARGEMENT
        // ======================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding:
                EdgeInsets.all(15),
            child:
                LinearProgressIndicator(),
          );
        }

        // ======================================================
        // ERREUR
        // ======================================================

        if (snapshot.hasError) {
          return Padding(
            padding:
                const EdgeInsets.all(15),
            child: Text(
              "Erreur demandes Wave : "
              "${snapshot.error}",
              style:
                  const TextStyle(
                color: Colors.red,
              ),
            ),
          );
        }

        // ======================================================
        // AUCUNE DEMANDE
        // ======================================================

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Container(
            width:
                double.infinity,

            margin:
                const EdgeInsets.fromLTRB(
              15,
              15,
              15,
              5,
            ),

            padding:
                const EdgeInsets.all(
              15,
            ),

            decoration:
                BoxDecoration(
              color:
                  Colors.green.shade50,

              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              border:
                  Border.all(
                color:
                    Colors.green.shade200,
              ),
            ),

            child: const Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Icon(
                  Icons.check_circle,
                  color:
                      Colors.green,
                ),

                SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    "Aucune demande "
                    "d'abonnement en attente.",

                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final demandes =
            snapshot.data!.docs;

        // ======================================================
        // SECTION
        // ======================================================

        return Container(
          width:
              double.infinity,

          margin:
              const EdgeInsets.fromLTRB(
            15,
            15,
            15,
            5,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              // ==================================================
              // TITRE CORRIGÉ
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  const Padding(
                    padding:
                        EdgeInsets.only(
                      top: 2,
                    ),
                    child: Icon(
                      Icons
                          .notifications_active,
                      color:
                          Colors.orange,
                      size: 28,
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  // IMPORTANT :
                  // Expanded permet au texte de revenir
                  // automatiquement à la ligne au lieu
                  // d'être coupé horizontalement.
                  Expanded(
                    child: Text(
                      "Demandes d'abonnement "
                      "en attente (${demandes.length})",

                      softWrap: true,

                      maxLines: 2,

                      overflow:
                          TextOverflow.visible,

                      style:
                          const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // DEMANDES
              // ==================================================

              ...demandes.map(
                (doc) =>
                    _carteDemandeWave(
                  doc,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // CARTE D'UNE DEMANDE WAVE
  // ==========================================================

  Widget _carteDemandeWave(
    QueryDocumentSnapshot doc,
  ) {
    final data =
        doc.data()
            as Map<String, dynamic>;

    final commerceId =
        data["commerceId"]
                ?.toString() ??
            "";

    final nomCommerce =
        data["nomCommerce"]
                ?.toString() ??
            "Commerce";

    final telephone =
        data["telephone"]
                ?.toString() ??
            "";

    final montant =
        data["montantTransfere"]
                ?.toString() ??
            "1010";

    final numeroWave =
        data["numeroWave"]
                ?.toString() ??
            "";

    final reference =
        data["referenceWave"]
                ?.toString() ??
            "";

    Timestamp? createdAt;

    if (data["createdAt"] is Timestamp) {
      createdAt =
          data["createdAt"]
              as Timestamp;
    }

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      elevation: 4,

      color:
          Colors.orange.shade50,

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
            // ==================================================
            // COMMERCE + STATUT
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                const Icon(
                  Icons
                      .account_balance_wallet,
                  color:
                      Colors.orange,
                  size: 30,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    nomCommerce,

                    softWrap:
                        true,

                    style:
                        const TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.orange,

                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),

                  child:
                      const Text(
                    "EN ATTENTE",

                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize:
                          11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(
              height: 25,
            ),

            // ==================================================
            // INFORMATIONS
            // ==================================================

            _ligneDemande(
              "Commerce ID",
              commerceId,
            ),

            _ligneDemande(
              "Téléphone",
              telephone,
            ),

            _ligneDemande(
              "Montant",
              "$montant FCFA",
              important: true,
            ),

            _ligneDemande(
              "Numéro Wave",
              numeroWave,
            ),

            const SizedBox(
              height: 8,
            ),

            // ==================================================
            // RÉFÉRENCE
            // ==================================================

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
                    Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  const Text(
                    "Référence du transfert",

                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  SelectableText(
                    reference.isEmpty
                        ? "Non renseignée"
                        : reference,

                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            // ==================================================
            // DATE DEMANDE
            // ==================================================

            Text(
              "Demande reçue : "
              "${formatDateTime(createdAt)}",

              style:
                  const TextStyle(
                color:
                    Colors.grey,
                fontSize:
                    12,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // BOUTONS
            // ==================================================

            Row(
              children: [
                Expanded(
                  child:
                      ElevatedButton.icon(
                    icon:
                        const Icon(
                      Icons
                          .check_circle,
                    ),

                    label:
                        const Text(
                      "Vérifier et activer",
                    ),

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.green,

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 13,
                      ),
                    ),

                    onPressed:
                        () async {
                      await _validerDemande(
                        context,
                        doc.id,
                        commerceId,
                        nomCommerce,
                        telephone,
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
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.red,

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 13,
                      ),
                    ),

                    onPressed:
                        () async {
                      await _refuserDemande(
                        context,
                        doc.id,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // LIGNE DEMANDE
  // ==========================================================

  Widget _ligneDemande(
    String titre,
    String valeur, {
    bool important = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 7,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [
          SizedBox(
            width: 125,

            child: Text(
              "$titre :",

              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              valeur,

              softWrap:
                  true,

              style:
                  TextStyle(
                fontWeight:
                    important
                        ? FontWeight.bold
                        : FontWeight.normal,

                fontSize:
                    important
                        ? 18
                        : 14,

                color:
                    important
                        ? Colors.orange
                        : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // VALIDER UNE DEMANDE
  // ==========================================================

  static Future<void> _validerDemande(
    BuildContext context,
    String demandeId,
    String commerceId,
    String nomCommerce,
    String telephone,
  ) async {
    final confirmer =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title:
              const Text(
            "Confirmer l'activation",
          ),

          content:
              Text(
            "Vous êtes sur le point de valider "
            "le paiement de $nomCommerce.\n\n"
            "Voulez-vous continuer ?",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
                  const Text(
                "Annuler",
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.green,

                foregroundColor:
                    Colors.white,
              ),

              child:
                  const Text(
                "Valider",
              ),
            ),
          ],
        );
      },
    );

    if (confirmer != true) {
      return;
    }

    await _activer(
      context,
      commerceId,
      demandeId:
          demandeId,
      telephoneDemande:
          telephone,
    );
  }

  // ==========================================================
  // REFUSER UNE DEMANDE
  // ==========================================================

  static Future<void> _refuserDemande(
    BuildContext context,
    String demandeId,
  ) async {
    final confirmer =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title:
              const Text(
            "Refuser la demande",
          ),

          content:
              const Text(
            "Voulez-vous vraiment refuser "
            "cette demande d'abonnement ?",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
                  const Text(
                "Annuler",
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    Colors.red,

                foregroundColor:
                    Colors.white,
              ),

              child:
                  const Text(
                "Refuser",
              ),
            ),
          ],
        );
      },
    );

    if (confirmer != true) {
      return;
    }

    try {
      await FirebaseFirestore
          .instance
          .collection(
            "demandes_abonnement",
          )
          .doc(
            demandeId,
          )
          .update({
        "statut":
            "refuse",

        "dateTraitement":
            Timestamp.now(),
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            "Demande refusée.",
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
              Text(
            "Erreur lors du refus : $e",
          ),
        ),
      );
    }
  }

  // ==========================================================
  // ACTIVER L'ABONNEMENT
  // ==========================================================

  static Future<void> _activer(
    BuildContext context,
    String commerceId, {
    String? demandeId,
    String? telephoneDemande,
  }) async {
    final duree =
        await showDialog<int>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title:
              const Text(
            "Durée de l'abonnement",
          ),

          content:
              Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              ListTile(
                leading:
                    const Icon(
                  Icons.calendar_month,
                  color:
                      Colors.blue,
                ),

                title:
                    const Text(
                  "1 mois",
                ),

                onTap: () {
                  Navigator.pop(
                    context,
                    1,
                  );
                },
              ),

              ListTile(
                leading:
                    const Icon(
                  Icons.calendar_month,
                  color:
                      Colors.green,
                ),

                title:
                    const Text(
                  "3 mois",
                ),

                onTap: () {
                  Navigator.pop(
                    context,
                    3,
                  );
                },
              ),

              ListTile(
                leading:
                    const Icon(
                  Icons.calendar_month,
                  color:
                      Colors.orange,
                ),

                title:
                    const Text(
                  "6 mois",
                ),

                onTap: () {
                  Navigator.pop(
                    context,
                    6,
                  );
                },
              ),

              ListTile(
                leading:
                    const Icon(
                  Icons.calendar_month,
                  color:
                      Colors.purple,
                ),

                title:
                    const Text(
                  "1 an",
                ),

                onTap: () {
                  Navigator.pop(
                    context,
                    12,
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (duree == null) {
      return;
    }

    try {
      // ======================================================
      // RÉCUPÉRER LE COMMERCE
      // ======================================================

      final commerceDoc =
          await FirebaseFirestore
              .instance
              .collection(
                "commerces",
              )
              .doc(
                commerceId,
              )
              .get();

      if (!commerceDoc.exists) {
        throw Exception(
          "Commerce introuvable",
        );
      }

      final commerceData =
          commerceDoc.data()
              as Map<String, dynamic>;

      // ======================================================
      // TÉLÉPHONE
      // ======================================================

      final telephoneCommerce =
          commerceData["phone"]
                  ?.toString() ??
              "";

      // Si le téléphone du commerce est vide,
      // on utilise celui de la demande Wave.
      final telephone =
          telephoneCommerce.isNotEmpty
              ? telephoneCommerce
              : telephoneDemande
                      ?.toString() ??
                  "";

      // ======================================================
      // NOM COMMERCE
      // ======================================================

      final nomCommerce =
          commerceData["name"]
                  ?.toString() ??
              "Commerce";

      // ======================================================
      // DATES
      // ======================================================

      final maintenant =
          DateTime.now();

      DateTime expiration;

      if (duree == 12) {
        expiration =
            DateTime(
          maintenant.year + 1,
          maintenant.month,
          maintenant.day,
          maintenant.hour,
          maintenant.minute,
          maintenant.second,
        );
      } else {
        expiration =
            DateTime(
          maintenant.year,
          maintenant.month + duree,
          maintenant.day,
          maintenant.hour,
          maintenant.minute,
          maintenant.second,
        );
      }

      // ======================================================
      // ACTIVATION DU COMMERCE
      // ======================================================

      await FirebaseFirestore
          .instance
          .collection(
            "commerces",
          )
          .doc(
            commerceId,
          )
          .update({
        "abonnementActif":
            true,

        "dateAbonnement":
            Timestamp.fromDate(
          maintenant,
        ),

        "expirationAbonnement":
            Timestamp.fromDate(
          expiration,
        ),

        "online":
            true,

        "dureeAbonnement":
            duree == 12
                ? "1 an"
                : "$duree mois",
      });

      // ======================================================
      // VALIDATION DE LA DEMANDE WAVE
      // ======================================================

      if (demandeId != null) {
        await FirebaseFirestore
            .instance
            .collection(
              "demandes_abonnement",
            )
            .doc(
              demandeId,
            )
            .update({
          "statut":
              "valide",

          "dateTraitement":
              Timestamp.now(),

          "dureeValidee":
              duree == 12
                  ? "1 an"
                  : "$duree mois",
        });
      }

      // ======================================================
      // SMS
      // ======================================================

      final dateExpirationTexte =
          "${expiration.day.toString().padLeft(2, '0')}/"
          "${expiration.month.toString().padLeft(2, '0')}/"
          "${expiration.year}";

      if (telephone.isNotEmpty) {
        final message = """
Bonjour abonné Fatima,

Votre abonnement pour $nomCommerce a été activé.

Votre abonnement prendra fin le $dateExpirationTexte.

Merci pour votre fidélité.
""";

        await ContactService.envoyerSMS(
          telephone,
          message,
        );
      }

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
              Text(
            "Abonnement activé pour "
            "${duree == 12 ? "1 an" : "$duree mois"}",
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
              Text(
            "Erreur lors de l'activation : $e",
          ),
        ),
      );
    }
  }

  // ==========================================================
  // DESACTIVER
  // ==========================================================

  static Future<void> _desactiver(
    BuildContext context,
    String commerceId,
  ) async {
    try {
      await FirebaseFirestore
          .instance
          .collection(
            "commerces",
          )
          .doc(
            commerceId,
          )
          .update({
        "abonnementActif":
            false,

        "online":
            false,
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content:
              Text(
            "Abonnement désactivé",
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
              Text(
            "Erreur lors de la désactivation : $e",
          ),
        ),
      );
    }
  }
}
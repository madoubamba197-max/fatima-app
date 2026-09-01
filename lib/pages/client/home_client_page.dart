import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';

import '../../models/created_application.dart';
import 'commerce_detail_page.dart';
import '../../config/business_type.dart';
import 'mes_reservations_page.dart';

class HomeClientPage extends StatefulWidget {
  const HomeClientPage({super.key});

  @override
  State<HomeClientPage> createState() => _HomeClientPageState();
}

class _HomeClientPageState extends State<HomeClientPage> {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController rechercheController =
      TextEditingController();

  final TextEditingController villeController =
      TextEditingController();

  // ==========================================================
  // VARIABLES
  // ==========================================================

  String recherche = "";
  String villeRecherchee = "";
  String categorieSelectionnee = "";

  // ==========================================================
  // NORMALISER TEXTE
  // ==========================================================

  String _normaliserTexte(String texte) {
    return removeDiacritics(
      texte.trim().toLowerCase(),
    ).replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    rechercheController.dispose();
    villeController.dispose();

    super.dispose();
  }

  // ==========================================================
  // AFFICHER LOGO
  // ==========================================================

  Widget _afficherLogo(String logo) {
    if (logo.trim().isEmpty) {
      return const CircleAvatar(
        radius: 28,
        child: Icon(
          Icons.store,
          size: 30,
        ),
      );
    }

    // ========================================================
    // BASE64
    // ========================================================

    try {
      String valeur = logo.trim();

      if (valeur.startsWith('data:image')) {
        valeur = valeur.split(',').last;
      }

      final bytes = base64Decode(valeur);

      return CircleAvatar(
        radius: 28,
        backgroundImage: MemoryImage(bytes),
      );
    } catch (_) {
      // ======================================================
      // URL
      // ======================================================

      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(logo),
      );
    }
  }

  // ==========================================================
  // EFFACER RECHERCHES
  // ==========================================================

  void _effacerRecherches() {
    setState(() {
      rechercheController.clear();
      villeController.clear();

      recherche = "";
      villeRecherchee = "";
      categorieSelectionnee = "";
    });
  }

  // ==========================================================
  // OUVRIR MES RESERVATIONS
  // ==========================================================

  void _ouvrirMesReservations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MesReservationsPage(),
      ),
    );
  }

  // ==========================================================
  // TEXTE RECHERCHE
  // ==========================================================

  String _texteRecherche() {
    final List<String> criteres = [];

    if (recherche.isNotEmpty) {
      criteres.add(
        'commerce : "$recherche"',
      );
    }

    if (villeRecherchee.isNotEmpty) {
      criteres.add(
        'ville : "$villeRecherchee"',
      );
    }

    if (categorieSelectionnee.isNotEmpty) {
      criteres.add(
        'catégorie : "${_nomCategorie(categorieSelectionnee)}"',
      );
    }

    return "Recherche — ${criteres.join(" • ")}";
  }

  // ==========================================================
  // MESSAGE AUCUN RESULTAT
  // ==========================================================

  String _messageAucunResultat() {
    if (villeRecherchee.isNotEmpty &&
        categorieSelectionnee.isNotEmpty) {
      return "Aucun ${_nomCategorie(categorieSelectionnee)} "
          "disponible à ${villeController.text}.";
    }

    if (villeRecherchee.isNotEmpty) {
      return "Aucun commerce disponible à "
          "${villeController.text}.";
    }

    if (categorieSelectionnee.isNotEmpty) {
      return "Aucun commerce de cette catégorie "
          "n'est actuellement disponible.";
    }

    if (recherche.isNotEmpty) {
      return "Aucun commerce ne correspond à votre recherche.";
    }

    return "Aucun commerce disponible.";
  }

  // ==========================================================
  // NOM CATEGORIE
  // ==========================================================

  String _nomCategorie(String categorie) {
    switch (categorie) {
      case "salon":
        return "salon";

      case "restaurant":
        return "restaurant";

      case "hotel":
        return "hôtel";

      case "garage":
        return "garage";

      case "boutique":
        return "boutique";

      case "pharmacie":
        return "pharmacie";

      case "cabinetMedical":
        return "cabinet médical";

      case "supermarche":
        return "supermarché";

      case "ecole":
        return "école";

      case "autre":
        return "commerce";

      default:
        return "commerce";
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FATIMA",
        ),
        centerTitle: true,
        actions: [
          if (recherche.isNotEmpty ||
              villeRecherchee.isNotEmpty ||
              categorieSelectionnee.isNotEmpty)
            IconButton(
              tooltip: "Effacer les recherches",
              icon: const Icon(
                Icons.clear,
              ),
              onPressed: _effacerRecherches,
            ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Column(
        children: [
          // ====================================================
          // RECHERCHE COMMERCE
          // ====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              15,
              15,
              15,
              8,
            ),
            child: TextField(
              controller: rechercheController,
              onChanged: (value) {
                setState(() {
                  recherche = _normaliserTexte(value);
                });
              },
              decoration: InputDecoration(
                labelText: "Commerce",
                hintText:
                    "Ex : Hôtel Ivoire, Fatima Beauty...",
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    rechercheController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                            ),
                            onPressed: () {
                              setState(() {
                                rechercheController.clear();
                                recherche = "";
                              });
                            },
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          // ====================================================
          // RECHERCHE VILLE
          // ====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              15,
              5,
              15,
              5,
            ),
            child: TextField(
              controller: villeController,
              onChanged: (value) {
                setState(() {
                  villeRecherchee =
                      _normaliserTexte(value);
                });
              },
              decoration: InputDecoration(
                labelText: "Ville",
                hintText:
                    "Ex : Abidjan, San Pedro, Yamoussoukro...",
                prefixIcon: const Icon(
                  Icons.location_city,
                  color: Colors.orange,
                ),
                suffixIcon:
                    villeController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                            ),
                            onPressed: () {
                              setState(() {
                                villeController.clear();
                                villeRecherchee = "";
                              });
                            },
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          // ====================================================
          // MES RESERVATIONS
          // ====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              15,
              5,
              15,
              10,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _ouvrirMesReservations,
                icon: const Icon(
                  Icons.calendar_month,
                ),
                label: const Text(
                  "Mes réservations",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.deepPurple,
                  foregroundColor:
                      Colors.white,
                  minimumSize:
                      const Size(
                    double.infinity,
                    50,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ====================================================
          // TEXTE RECHERCHE
          // ====================================================

          if (villeRecherchee.isNotEmpty ||
              recherche.isNotEmpty ||
              categorieSelectionnee.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 3,
              ),
              child: Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  _texteRecherche(),
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        Colors.grey.shade700,
                  ),
                ),
              ),
            ),

          // ====================================================
          // CATEGORIES
          // ====================================================

          SizedBox(
            height: 105,
            child: ListView(
              scrollDirection:
                  Axis.horizontal,
              children: [
                _CategorieCard(
                  icon: Icons.content_cut,
                  titre: "Salon",
                  actif:
                      categorieSelectionnee ==
                          "salon",
                  onTap: () {
                    setState(() {
                      categorieSelectionnee =
                          categorieSelectionnee ==
                                  "salon"
                              ? ""
                              : "salon";
                    });
                  },
                ),

                _CategorieCard(
                  icon: Icons.restaurant,
                  titre: "Restaurant",
                  actif:
                      categorieSelectionnee ==
                          "restaurant",
                  onTap: () {
                    setState(() {
                      categorieSelectionnee =
                          categorieSelectionnee ==
                                  "restaurant"
                              ? ""
                              : "restaurant";
                    });
                  },
                ),

                _CategorieCard(
                  icon: Icons.hotel,
                  titre: "Hôtel",
                  actif:
                      categorieSelectionnee ==
                          "hotel",
                  onTap: () {
                    setState(() {
                      categorieSelectionnee =
                          categorieSelectionnee ==
                                  "hotel"
                              ? ""
                              : "hotel";
                    });
                  },
                ),

                _CategorieCard(
                  icon: Icons.car_repair,
                  titre: "Garage",
                  actif:
                      categorieSelectionnee ==
                          "garage",
                  onTap: () {
                    setState(() {
                      categorieSelectionnee =
                          categorieSelectionnee ==
                                  "garage"
                              ? ""
                              : "garage";
                    });
                  },
                ),

                _CategorieCard(
                  icon: Icons.shopping_bag,
                  titre: "Boutique",
                  actif:
                      categorieSelectionnee ==
                          "boutique",
                  onTap: () {
                    setState(() {
                      categorieSelectionnee =
                          categorieSelectionnee ==
                                  "boutique"
                              ? ""
                              : "boutique";
                    });
                  },
                ),

                _CategorieCard(
                  icon: Icons.local_pharmacy,
                  titre: "Pharmacie",
                  actif:
                      categorieSelectionnee ==
                          "pharmacie",
                  onTap: () {
                    setState(() {
                      categorieSelectionnee =
                          categorieSelectionnee ==
                                  "pharmacie"
                              ? ""
                              : "pharmacie";
                    });
                  },
                ),

                _CategorieCard(
                  icon: Icons.medical_services,
                  titre: "Cabinet médical",
                  actif:
                      categorieSelectionnee ==
                          "cabinetMedical",
                  onTap: () {
                    setState(() {
                      categorieSelectionnee =
                          categorieSelectionnee ==
                                  "cabinetMedical"
                              ? ""
                              : "cabinetMedical";
                    });
                  },
                ),

                _CategorieCard(
                  icon: Icons.shopping_cart,
                  titre: "Supermarché",
                  actif:
                      categorieSelectionnee ==
                          "supermarche",
                  onTap: () {
                    setState(() {
                      categorieSelectionnee =
                          categorieSelectionnee ==
                                  "supermarche"
                              ? ""
                              : "supermarche";
                    });
                  },
                ),

                _CategorieCard(
                  icon: Icons.school,
                  titre: "École",
                  actif:
                      categorieSelectionnee ==
                          "ecole",
                  onTap: () {
                    setState(() {
                      categorieSelectionnee =
                          categorieSelectionnee ==
                                  "ecole"
                              ? ""
                              : "ecole";
                    });
                  },
                ),

                _CategorieCard(
                  icon: Icons.store,
                  titre: "Autre",
                  actif:
                      categorieSelectionnee ==
                          "autre",
                  onTap: () {
                    setState(() {
                      categorieSelectionnee =
                          categorieSelectionnee ==
                                  "autre"
                              ? ""
                              : "autre";
                    });
                  },
                ),
              ],
            ),
          ),

          // ====================================================
          // LISTE COMMERCES
          // ====================================================

          Expanded(
            child:
                StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore
                  .instance
                  .collection("commerces")
                  .snapshots(),
              builder:
                  (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint(
                    "ERREUR FIRESTORE : "
                    "${snapshot.error}",
                  );

                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),
                      child: Text(
                        "Erreur : "
                        "${snapshot.error}",
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun commerce disponible",
                    ),
                  );
                }

                // ==================================================
                // FILTRAGE
                // ==================================================

                final docs =
                    snapshot.data!.docs.where(
                  (doc) {
                    final data =
                        doc.data()
                            as Map<String, dynamic>;

                    // ==========================================
                    // ABONNEMENT ACTIF
                    // ==========================================

                    if (data[
                            "abonnementActif"] !=
                        true) {
                      return false;
                    }

                    // ==========================================
                    // EXPIRATION
                    // ==========================================

                    DateTime? expiration;

                    final expirationData =
                        data[
                            "expirationAbonnement"];

                    if (expirationData
                        is Timestamp) {
                      expiration =
                          expirationData.toDate();
                    } else if (expirationData
                        is DateTime) {
                      expiration =
                          expirationData;
                    }

                    if (expiration == null) {
                      return false;
                    }

                    if (!expiration.isAfter(
                      DateTime.now(),
                    )) {
                      return false;
                    }

                    // ==========================================
                    // ONLINE
                    // ==========================================

                    final online =
                        data["online"] ?? true;

                    if (online != true) {
                      return false;
                    }

                    // ==========================================
                    // NOM
                    // ==========================================

                    final nom =
                        _normaliserTexte(
                      data["name"]
                              ?.toString() ??
                          "",
                    );

                    if (recherche.isNotEmpty &&
                        !nom.contains(
                          recherche,
                        )) {
                      return false;
                    }

                    // ==========================================
                    // VILLE
                    // ==========================================

                    final ville =
                        _normaliserTexte(
                      data["ville"]
                              ?.toString() ??
                          "",
                    );

                    if (villeRecherchee
                            .isNotEmpty &&
                        !ville.contains(
                          villeRecherchee,
                        )) {
                      return false;
                    }

                    // ==========================================
                    // CATEGORIE
                    // ==========================================

                    final type =
                        _normaliserTexte(
                      data["type"]
                              ?.toString() ??
                          "",
                    );

                    final categorie =
                        _normaliserTexte(
                      categorieSelectionnee,
                    );

                    if (categorieSelectionnee
                            .isNotEmpty &&
                        type != categorie) {
                      return false;
                    }

                    return true;
                  },
                ).toList();

                // ==================================================
                // AUCUN RESULTAT
                // ==================================================

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 60,
                            color:
                                Colors.grey,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "Aucun commerce trouvé",
                            style:
                                TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            _messageAucunResultat(),
                            textAlign:
                                TextAlign
                                    .center,
                            style: TextStyle(
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ==================================================
                // LISTE
                // ==================================================

                return Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        15,
                        8,
                        15,
                        3,
                      ),
                      child: Align(
                        alignment:
                            Alignment
                                .centerLeft,
                        child: Text(
                          "${docs.length} commerce"
                          "${docs.length > 1 ? 's' : ''} trouvé"
                          "${docs.length > 1 ? 's' : ''}",
                          style:
                              TextStyle(
                            fontSize: 13,
                            color: Colors
                                .grey
                                .shade700,
                            fontWeight:
                                FontWeight
                                    .w500,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child:
                          ListView.builder(
                        itemCount:
                            docs.length,
                        itemBuilder:
                            (context, index) {
                          final data =
                              docs[index].data()
                                  as Map<String, dynamic>;

                          DateTime?
                              expiration;

                          if (data[
                                  "expirationAbonnement"]
                              is Timestamp) {
                            expiration =
                                (data[
                                        "expirationAbonnement"]
                                    as Timestamp)
                                .toDate();
                          }

                          // ========================================
                          // CREATION COMMERCE
                          // ========================================

                          final commerce =
                              CreatedApplication(
                            commerceId:
                                docs[index].id,
                            name:
                                data["name"] ??
                                    "",
                            slogan:
                                data["slogan"] ??
                                    "",
                            proprietaire:
                                data["proprietaire"] ??
                                    "",
                            phone:
                                data["phone"] ??
                                    "",
                            whatsapp:
                                data["whatsapp"] ??
                                    "",
                            ville:
                                data["ville"] ??
                                    "",
                            address:
                                data["address"] ??
                                    "",
                            verified:
                                data["verified"] ??
                                    false,
                            online:
                                data["online"] ??
                                    true,
                            rating:
                                (data["rating"] ??
                                        0)
                                    .toDouble(),
                            reviews:
                                data["reviews"] ??
                                    0,
                            logo:
                                data["logo"] ??
                                    "",
                            coverImage:
                                data["coverImage"] ??
                                    "",
                            gallery: [],
                            latitude:
                                (data["latitude"] ??
                                        0)
                                    .toDouble(),
                            longitude:
                                (data["longitude"] ??
                                        0)
                                    .toDouble(),
                            type:
                                BusinessType
                                    .values
                                    .firstWhere(
                              (e) =>
                                  e.name ==
                                  data["type"],
                              orElse: () =>
                                  BusinessType
                                      .autre,
                            ),
                            createdAt:
                                data["createdAt"]
                                        is Timestamp
                                    ? (data[
                                            "createdAt"]
                                        as Timestamp)
                                    .toDate()
                                    : DateTime
                                        .now(),
                            items: [],
                            adminUsername:
                                data[
                                        "adminUsername"] ??
                                    "",
                            adminPassword:
                                data[
                                        "adminPassword"] ??
                                    "",
                            abonnementActif:
                                data[
                                        "abonnementActif"] ==
                                    true,
                            expirationAbonnement:
                                expiration ??
                                    DateTime
                                        .now(),
                          );

                          // ========================================
                          // CARTE
                          // ========================================

                          return Card(
                            margin:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            elevation: 2,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),
                            child:
                                ListTile(
                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              leading:
                                  _afficherLogo(
                                commerce.logo,
                              ),
                              title:
                                  Text(
                                commerce.name,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  fontSize:
                                      17,
                                ),
                              ),
                              subtitle:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .location_on,
                                        size:
                                            16,
                                        color:
                                            Colors
                                                .orange,
                                      ),
                                      const SizedBox(
                                        width:
                                            4,
                                      ),
                                      Expanded(
                                        child:
                                            Text(
                                          commerce
                                              .ville,
                                          maxLines:
                                              1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  if (commerce
                                      .address
                                      .isNotEmpty)
                                    Text(
                                      commerce
                                          .address,
                                      maxLines:
                                          1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          TextStyle(
                                        fontSize:
                                            12,
                                        color: Colors
                                            .grey
                                            .shade600,
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .star,
                                        color:
                                            Colors
                                                .orange,
                                        size:
                                            16,
                                      ),
                                      const SizedBox(
                                        width:
                                            4,
                                      ),
                                      Text(
                                        commerce
                                            .rating
                                            .toStringAsFixed(
                                          1,
                                        ),
                                      ),
                                      Text(
                                        " (${commerce.reviews} avis)",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing:
                                  const Icon(
                                Icons
                                    .arrow_forward_ios,
                                size: 18,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CommerceDetailPage(
                                      commerce:
                                          commerce,
                                    ),
                                  ),
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
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// CARTE CATEGORIE
// ==========================================================

class _CategorieCard extends StatelessWidget {
  final IconData icon;
  final String titre;
  final bool actif;
  final VoidCallback onTap;

  const _CategorieCard({
    super.key,
    required this.icon,
    required this.titre,
    required this.actif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin:
            const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration:
            BoxDecoration(
          color: actif
              ? Colors.orange
              : Colors.orange.shade100,
          borderRadius:
              BorderRadius.circular(
            15,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 35,
              color: actif
                  ? Colors.white
                  : Colors.black,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              titre,
              maxLines: 1,
              softWrap: false,
              overflow:
                  TextOverflow.ellipsis,
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color: actif
                    ? Colors.white
                    : Colors.black,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
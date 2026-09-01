import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/firestore_service.dart';
import '../../models/created_application.dart';
import '../../config/business_type.dart';
import '../../core/app_storage/application_manager.dart';
import '../admin/admin_login_page.dart';
import '../app_creator/app_creator_page.dart';


class ApplicationsListPage extends StatefulWidget {
  const ApplicationsListPage({super.key});

  @override
  State<ApplicationsListPage> createState() =>
      _ApplicationsListPageState();
}

class _ApplicationsListPageState
    extends State<ApplicationsListPage> {

  final TextEditingController rechercheController =
      TextEditingController();

  String recherche = "";

  @override
  void dispose() {
    rechercheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes applications"),
      ),

      body: Column(
        children: [

          // =====================================================
          // BARRE DE RECHERCHE
          // =====================================================

          Padding(
            padding: const EdgeInsets.all(15),

            child: TextField(
              controller: rechercheController,

              onChanged: (value) {
                setState(() {
                  recherche = value.toLowerCase().trim();
                });
              },

              decoration: InputDecoration(
                hintText:
                    "Rechercher par nom, téléphone ou ID...",

                prefixIcon:
                    const Icon(Icons.search),

                suffixIcon:
                    recherche.isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(Icons.clear),

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
              ),
            ),
          ),

          // =====================================================
          // LISTE DES COMMERCES
          // =====================================================

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirestoreService.getCommerces(),

              builder:
                  (context, snapshot) {

                // -------------------------------------------------
                // CHARGEMENT
                // -------------------------------------------------

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                // -------------------------------------------------
                // ERREUR
                // -------------------------------------------------

                if (snapshot.hasError) {

                  return Center(
                    child: Text(
                      "Erreur : ${snapshot.error}",
                    ),
                  );
                }

                // -------------------------------------------------
                // AUCUN COMMERCE
                // -------------------------------------------------

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {

                  return const Center(
                    child: Text(
                      "Aucune application créée",
                      style:
                          TextStyle(fontSize: 20),
                    ),
                  );
                }

                // -------------------------------------------------
                // FILTRAGE RECHERCHE
                // -------------------------------------------------

                final commerces =
                    snapshot.data!.docs.where((doc) {

                  final data =
                      doc.data()
                          as Map<String, dynamic>;

                  final nom =
                      (data["name"] ?? "")
                          .toString()
                          .toLowerCase();

                  final telephone =
                      (data["phone"] ?? "")
                          .toString()
                          .toLowerCase();

                  final commerceId =
                      doc.id.toLowerCase();

                  return nom.contains(recherche) ||
                      telephone.contains(recherche) ||
                      commerceId.contains(recherche);

                }).toList();

                // -------------------------------------------------
                // AUCUN RESULTAT
                // -------------------------------------------------

                if (commerces.isEmpty) {

                  return const Center(
                    child: Text(
                      "Aucun commerce trouvé",
                      style:
                          TextStyle(fontSize: 18),
                    ),
                  );
                }

                // -------------------------------------------------
                // LISTVIEW
                // -------------------------------------------------

                return ListView.builder(

                  padding:
                      const EdgeInsets.only(
                    bottom: 20,
                  ),

                  itemCount:
                      commerces.length,

                  itemBuilder:
                      (context, index) {

                    final commerce =
                        commerces[index];

                    final data =
                        commerce.data()
                            as Map<String, dynamic>;

                    final application = CreatedApplication(
  commerceId: commerce.id,

  name: data["name"] ?? "",
  slogan: data["slogan"] ?? "",
  proprietaire: data["proprietaire"] ?? "",
  phone: data["phone"] ?? "",
  whatsapp: data["whatsapp"] ?? "",
  ville: data["ville"] ?? "",
  address: data["address"] ?? "",

  latitude:
      (data["latitude"] ?? 0).toDouble(),

  longitude:
      (data["longitude"] ?? 0).toDouble(),

  verified:
      data["verified"] ?? false,

  online:
      data["online"] ?? true,

  rating:
      (data["rating"] ?? 0).toDouble(),

  reviews:
      data["reviews"] ?? 0,

  logo:
      data["logo"] ?? "",

  coverImage:
      data["coverImage"] ?? "",

  gallery:
      List<String>.from(
        data["gallery"] ?? [],
      ),

  type:
      BusinessType.values.firstWhere(
    (type) => type.name == data["type"],
    orElse: () => BusinessType.autre,
  ),

  createdAt:
      data["createdAt"] is Timestamp
          ? (data["createdAt"] as Timestamp).toDate()
          : DateTime.now(),

  items: [],

  adminUsername:
      data["adminUsername"] ?? "",

  adminPassword:
      data["adminPassword"] ?? "",

  abonnementActif:
      data["abonnementActif"] ?? false,

  expirationAbonnement:
      data["expirationAbonnement"] is Timestamp
          ? (data["expirationAbonnement"] as Timestamp).toDate()
          : DateTime.now(),
);

                    return Card(

                      elevation: 5,

                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),

                      child: Padding(

                        padding:
                            const EdgeInsets.all(15),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            // =====================================
                            // NOM
                            // =====================================

                            Text(
                              data["name"] ?? "",

                              style:
                                  const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            // =====================================
                            // INFORMATIONS
                            // =====================================

                            Text(
                              "Commerce ID : ${commerce.id}",
                            ),

                            Text(
                              "Type : ${data["type"] ?? ""}",
                            ),

                            Text(
                              "Téléphone : ${data["phone"] ?? ""}",
                            ),

                            Text(
                              "Adresse : ${data["address"] ?? ""}",
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // =====================================
                            // BOUTONS
                            // =====================================

                            Row(

                              children: [

                                // ---------------------------------
                                // OUVRIR
                                // ---------------------------------

                                Expanded(
                                  child:
                                      ElevatedButton.icon(

                                    onPressed: () {

                                      final application =
                                          CreatedApplication(

                                        commerceId:
                                            commerce.id,

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

                                        latitude:
                                            (data["latitude"] ??
                                                    0)
                                                .toDouble(),

                                        longitude:
                                            (data["longitude"] ??
                                                    0)
                                                .toDouble(),

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

                                        gallery:
                                            List<String>.from(
                                          data["gallery"] ??
                                              [],
                                        ),

                                        type:
                                            BusinessType
                                                .values
                                                .first,

                                        createdAt:
                                            DateTime.now(),

                                        items: [],

                                        adminUsername:
                                            data["adminUsername"] ??
                                                "",

                                        adminPassword:
                                            data["adminPassword"] ??
                                                "",

                                        abonnementActif:
                                            data["abonnementActif"] ??
                                                true,

                                        expirationAbonnement:
                                            data[
                                                "expirationAbonnement"] is Timestamp
                                                ? (data[
                                                            "expirationAbonnement"]
                                                        as Timestamp)
                                                    .toDate()
                                                : DateTime.now()
                                                    .add(
                                                    const Duration(
                                                      days: 365,
                                                    ),
                                                  ),
                                      );

                                      // Enregistrer le commerce
                                      // actuellement sélectionné
                                      ApplicationManager
                                          .openApplication(
                                        application,
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminLoginPage(),
                                        ),
                                      );
                                    },

                                    icon:
                                        const Icon(
                                      Icons.open_in_new,
                                    ),

                                    label:
                                        const Text(
                                      "Ouvrir",
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 5,
                                ),

                                // ---------------------------------
                                // MODIFIER
                                // ---------------------------------

                                IconButton(
  icon: const Icon(
    Icons.edit,
    color: Colors.blue,
  ),

  tooltip: "Modifier",

  onPressed: () {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppCreatorPage(
          application: application,
        ),
      ),
    );

  },
),

                                // ---------------------------------
                                // SUPPRIMER
                                // ---------------------------------

                                IconButton(

                                  icon:
                                      const Icon(
                                    Icons.delete,
                                    color:
                                        Colors.red,
                                  ),

                                  onPressed:
                                      () async {

                                    final rep =
                                        await showDialog<bool>(
                                      context:
                                          context,

                                      builder:
                                          (_) =>
                                              AlertDialog(

                                        title:
                                            const Text(
                                          "Supprimer",
                                        ),

                                        content:
                                            Text(
                                          "Supprimer ${data["name"]} ?",
                                        ),

                                        actions: [

                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.pop(
                                              context,
                                              false,
                                            ),

                                            child:
                                                const Text(
                                              "Annuler",
                                            ),
                                          ),

                                          ElevatedButton(
                                            onPressed:
                                                () =>
                                                    Navigator.pop(
                                              context,
                                              true,
                                            ),

                                            child:
                                                const Text(
                                              "Supprimer",
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (rep == true) {

                                      await FirestoreService
                                          .deleteCommerce(
                                        commerce.id,
                                      );
                                    }
                                  },
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
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_storage/application_manager.dart';
import 'client_historique_page.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
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
        title: const Text("Clients"),
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

          if (!snapshot.hasData) {
            return const Center(
              child: Text("Aucun client"),
            );
          }

          // ==================================================
          // CLIENTS UNIQUES
          // ==================================================

          final Map<String, Map<String, String>> clients = {};

          for (final doc in snapshot.data!.docs) {
            final data =
                doc.data() as Map<String, dynamic>;

            final phone =
                data["phone"]?.toString().trim() ?? "";

            if (phone.isEmpty) {
              continue;
            }

            final name =
                data["clientName"]?.toString().trim() ?? "";

            final whatsapp =
                data["whatsapp"]?.toString().trim() ?? "";

            clients[phone] = {
              "name": name.isEmpty
                  ? "Client"
                  : name,
              "phone": phone,
              "whatsapp": whatsapp,
            };
          }

          final listeClients =
              clients.values.where((client) {
            final nom =
                client["name"]?.toLowerCase() ?? "";

            final telephone =
                client["phone"]?.toLowerCase() ?? "";

            final rechercheMinuscule =
                recherche.toLowerCase().trim();

            return nom.contains(
                  rechercheMinuscule,
                ) ||
                telephone.contains(
                  rechercheMinuscule,
                );
          }).toList();

          // ==================================================
          // AFFICHAGE
          // ==================================================

          return Column(
            children: [

              // ==================================================
              // BARRE DE RECHERCHE
              // ==================================================

              Padding(
                padding: const EdgeInsets.all(15),

                child: TextField(
                  controller: rechercheController,

                  onChanged: (value) {
                    setState(() {
                      recherche = value;
                    });
                  },

                  decoration: InputDecoration(
                    hintText:
                        "Rechercher un client...",

                    prefixIcon:
                        const Icon(Icons.search),

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

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // NOMBRE DE CLIENTS
              // ==================================================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 15,
                ),

                child: Align(
                  alignment:
                      Alignment.centerLeft,

                  child: Text(
                    "${listeClients.length} client(s)",
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ==================================================
              // LISTE
              // ==================================================

              Expanded(
                child: listeClients.isEmpty
                    ? Center(
                        child: Text(
                          recherche.isEmpty
                              ? "Aucun client enregistré."
                              : "Aucun client trouvé.",
                        ),
                      )

                    : ListView.builder(
                        padding:
                            const EdgeInsets.all(
                          10,
                        ),

                        itemCount:
                            listeClients.length,

                        itemBuilder:
                            (context, index) {
                          final client =
                              listeClients[index];

                          return Card(
                            elevation: 2,

                            margin:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),

                            child: ListTile(
                              leading:
                                  const CircleAvatar(
                                child: Icon(
                                  Icons.person,
                                ),
                              ),

                              title: Text(
                                client["name"] ??
                                    "Client",

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              subtitle: Text(
                                client["phone"] ?? "",
                              ),

                              trailing:
                                  const Icon(
                                Icons.chevron_right,
                              ),

                              // ==================================
                              // CLIC CLIENT
                              // ==================================

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ClientHistoriquePage(
                                      clientName:
                                          client["name"] ??
                                              "Client",
                                      phone:
                                          client["phone"] ??
                                              "",
                                      commerceId:
                                          commerceId,
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
    );
  }
}
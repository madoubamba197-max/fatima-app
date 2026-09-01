import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/client_identity_service.dart';
import 'client_auth_page.dart';

class AvisCommercePage extends StatefulWidget {
  final String commerceId;
  final String nomCommerce;

  const AvisCommercePage({
    super.key,
    required this.commerceId,
    required this.nomCommerce,
  });

  @override
  State<AvisCommercePage> createState() =>
      _AvisCommercePageState();
}

class _AvisCommercePageState extends State<AvisCommercePage> {
  // ==========================================================
  // CONTROLLER
  // ==========================================================

  final TextEditingController commentaireController =
      TextEditingController();

  // ==========================================================
  // VARIABLES
  // ==========================================================

  int noteSelectionnee = 5;

  bool envoiEnCours = false;
  bool chargementIdentite = true;

  String? clientId;
  String? nomClient;

  // ==========================================================
  // INITIALISATION
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _initialiserClient();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    commentaireController.dispose();

    super.dispose();
  }

  // ==========================================================
  // INITIALISER LE CLIENT
  // ==========================================================

  Future<void> _initialiserClient() async {
    try {
      // ========================================================
      // 1. VÉRIFIER SI LE CLIENT EST DÉJÀ CONNECTÉ
      // ========================================================

      if (!ClientIdentityService.isClientConnected) {
        if (!mounted) return;

        final connexion = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => ClientAuthPage(),
          ),
        );

        if (!mounted) return;

        // ------------------------------------------------------
        // Le client a annulé
        // ------------------------------------------------------

        if (connexion != true) {
          Navigator.of(context).pop();
          return;
        }
      }

      // ========================================================
      // 2. RÉCUPÉRER L'IDENTIFIANT FIREBASE
      // ========================================================

      final id = await ClientIdentityService.getClientId();

      if (id.trim().isEmpty) {
        if (!mounted) return;

        _message(
          "Impossible d'identifier votre compte.",
        );

        Navigator.of(context).pop();
        return;
      }

      // ========================================================
      // 3. RÉCUPÉRER LE NOM DU CLIENT
      // ========================================================

      String? nom =
          await ClientIdentityService.getClientName();

      if (!mounted) return;

      // ========================================================
      // 4. SI LE NOM N'EXISTE PAS
      // ========================================================

      if (nom == null || nom.trim().isEmpty) {
        final controller = TextEditingController();

        final nomSaisi = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text(
                "Votre nom",
              ),

              content: TextField(
                controller: controller,
                autofocus: true,
                textCapitalization:
                    TextCapitalization.words,

                decoration: const InputDecoration(
                  labelText: "Nom",
                  hintText: "Exemple : Aboubacar",
                  prefixIcon: Icon(
                    Icons.person,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    "Annuler",
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    final valeur =
                        controller.text.trim();

                    if (valeur.isEmpty) {
                      return;
                    }

                    Navigator.of(dialogContext).pop(
                      valeur,
                    );
                  },
                  child: const Text(
                    "Continuer",
                  ),
                ),
              ],
            );
          },
        );

        controller.dispose();

        if (!mounted) return;

        // ------------------------------------------------------
        // Le client a annulé
        // ------------------------------------------------------

        if (nomSaisi == null ||
            nomSaisi.trim().isEmpty) {
          Navigator.of(context).pop();
          return;
        }

        // ------------------------------------------------------
        // ENREGISTRER LE NOM
        // ------------------------------------------------------

        await ClientIdentityService.saveClientName(
          nomSaisi.trim(),
        );

        if (!mounted) return;

        nom = nomSaisi.trim();
      }

      // ========================================================
      // 5. PRÉPARER L'IDENTITÉ DU CLIENT
      // ========================================================

      final nomFinal = nom.trim();

      if (nomFinal.isEmpty) {
        if (!mounted) return;

        _message(
          "Impossible de récupérer votre nom.",
        );

        Navigator.of(context).pop();
        return;
      }

      // ========================================================
      // 6. UNE SEULE RECONSTRUCTION DE LA PAGE
      // ========================================================

      if (!mounted) return;

      setState(() {
        clientId = id;
        nomClient = nomFinal;
        chargementIdentite = false;
      });
    } catch (e) {
      debugPrint(
        "ERREUR INITIALISATION CLIENT : $e",
      );

      if (!mounted) return;

      _message(
        "Impossible de charger votre compte.",
      );

      Navigator.of(context).pop();
    }
  }

  // ==========================================================
  // ENVOYER / MODIFIER L'AVIS
  // ==========================================================

  Future<void> envoyerAvis() async {
    final commentaire =
        commentaireController.text.trim();

    // ========================================================
    // COMMENTAIRE OBLIGATOIRE
    // ========================================================

    if (commentaire.isEmpty) {
      _message(
        "Veuillez écrire un commentaire.",
      );

      return;
    }

    // ========================================================
    // IDENTITÉ
    // ========================================================

    final id = clientId;

    if (id == null || id.trim().isEmpty) {
      _message(
        "Impossible d'identifier le client.",
      );

      return;
    }

    // ========================================================
    // NOM
    // ========================================================

    final nom = nomClient;

    if (nom == null || nom.trim().isEmpty) {
      _message(
        "Impossible de récupérer votre nom.",
      );

      return;
    }

    // ========================================================
    // DÉMARRER L'ENVOI
    // ========================================================

    if (!mounted) return;

    setState(() {
      envoiEnCours = true;
    });

    try {
      // ======================================================
      // RÉFÉRENCE DU COMMERCE
      // ======================================================

      final commerceRef =
          FirebaseFirestore.instance
              .collection("commerces")
              .doc(widget.commerceId);

      // ======================================================
      // RÉFÉRENCE DE L'AVIS
      //
      // UN CLIENT = UN AVIS PAR COMMERCE
      //
      // Exemple :
      //
      // commerces
      //   └── commerce123
      //        └── avis
      //             ├── UID_CLIENT_1
      //             └── UID_CLIENT_2
      //
      // ======================================================

      final avisRef =
          commerceRef
              .collection("avis")
              .doc(id);

      // ======================================================
      // VÉRIFIER SI UN AVIS EXISTE DÉJÀ
      // ======================================================

      final ancienAvis =
          await avisRef.get();

      // ======================================================
      // DONNÉES DE L'AVIS
      // ======================================================

      final donnees =
          <String, dynamic>{
        "clientId": id,

        "nomClient": nom.trim(),

        "note": noteSelectionnee,

        "commentaire": commentaire,

        "updatedAt":
            FieldValue.serverTimestamp(),
      };

      // ======================================================
      // CRÉATION UNIQUEMENT
      // ======================================================

      if (!ancienAvis.exists) {
        donnees["createdAt"] =
            FieldValue.serverTimestamp();
      }

      // ======================================================
      // ENREGISTRER L'AVIS
      // ======================================================

      await avisRef.set(
        donnees,
        SetOptions(
          merge: true,
        ),
      );

      // ======================================================
      // RÉCUPÉRER TOUS LES AVIS DU COMMERCE
      // ======================================================

      final avisSnapshot =
          await commerceRef
              .collection("avis")
              .get();

      // ======================================================
      // CALCUL DE LA MOYENNE
      // ======================================================

      int totalNotes = 0;

      int nombreAvisValides = 0;

      for (final doc in avisSnapshot.docs) {
        final data = doc.data();

        final note = data["note"];

        if (note is num) {
          totalNotes += note.toInt();

          nombreAvisValides++;
        }
      }

      final double nouvelleMoyenne =
          nombreAvisValides == 0
              ? 0.0
              : totalNotes /
                  nombreAvisValides;

      // ======================================================
      // METTRE À JOUR LE COMMERCE
      // ======================================================

      await commerceRef.update({
        "rating": nouvelleMoyenne,
        "reviews": nombreAvisValides,
      });

      // ======================================================
      // SUCCÈS
      // ======================================================

      if (!mounted) return;

      final bool modification =
          ancienAvis.exists;

      final String message =
          modification
              ? "Votre avis a été modifié."
              : "Merci $nom ! Votre avis a été enregistré.";

      // Nettoyage
      commentaireController.clear();

      setState(() {
        noteSelectionnee = 5;
      });

      _message(message);

      // ======================================================
      // RETOUR À LA PAGE PRÉCÉDENTE
      // ======================================================

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint(
        "ERREUR ENREGISTREMENT AVIS : $e",
      );

      if (!mounted) return;

      _message(
        "Erreur lors de l'enregistrement de votre avis.",
      );
    } finally {
      if (mounted) {
        setState(() {
          envoiEnCours = false;
        });
      }
    }
  }

  // ==========================================================
  // ÉTOILES
  // ==========================================================

  Widget _etoiles() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: List.generate(
        5,
        (index) {
          final numero = index + 1;

          return IconButton(
            onPressed: envoiEnCours
                ? null
                : () {
                    setState(() {
                      noteSelectionnee =
                          numero;
                    });
                  },

            icon: Icon(
              numero <= noteSelectionnee
                  ? Icons.star
                  : Icons.star_border,

              color: Colors.orange,

              size: 42,
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _message(String texte) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(texte),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    // ========================================================
    // CHARGEMENT IDENTITÉ
    // ========================================================

    if (chargementIdentite) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Donner mon avis",
          ),
          centerTitle: true,
        ),

        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ========================================================
    // PAGE PRINCIPALE
    // ========================================================

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Donner mon avis",
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            // ==================================================
            // ICÔNE
            // ==================================================

            const Icon(
              Icons.rate_review,
              size: 70,
              color: Colors.orange,
            ),

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // NOM DU COMMERCE
            // ==================================================

            Text(
              widget.nomCommerce,

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // NOM DU CLIENT
            // ==================================================

            if (nomClient != null &&
                nomClient!.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.orange.shade50,

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    const Icon(
                      Icons.person,
                      color: Colors.orange,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Text(
                      nomClient!,

                      style:
                          const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // QUESTION
            // ==================================================

            const Text(
              "Quelle note donnez-vous à ce commerce ?",

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // ==================================================
            // ÉTOILES
            // ==================================================

            _etoiles(),

            const SizedBox(
              height: 5,
            ),

            Text(
              "$noteSelectionnee / 5",

              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================================
            // COMMENTAIRE
            // ==================================================

            TextField(
              controller:
                  commentaireController,

              maxLines: 5,

              enabled: !envoiEnCours,

              decoration: InputDecoration(
                labelText:
                    "Votre commentaire",

                hintText:
                    "Partagez votre expérience...",

                alignLabelWithHint: true,

                prefixIcon:
                    const Icon(
                  Icons.comment,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // BOUTON PUBLIER
            // ==================================================

            SizedBox(
              height: 52,

              child:
                  ElevatedButton.icon(
                onPressed:
                    envoiEnCours
                        ? null
                        : envoyerAvis,

                icon:
                    envoiEnCours
                        ? const SizedBox(
                            width: 20,
                            height: 20,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                          ),

                label:
                    Text(
                  envoiEnCours
                      ? "Envoi..."
                      : "Publier mon avis",
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.orange,

                  foregroundColor:
                      Colors.white,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
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

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // INFORMATION
            // ==================================================

            const Text(
              "Vous pouvez donner un seul avis "
              "par commerce. Vous pourrez ensuite "
              "modifier votre avis.",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
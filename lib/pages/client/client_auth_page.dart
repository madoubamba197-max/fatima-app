import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientAuthPage extends StatefulWidget {
  const ClientAuthPage({
    super.key,
  });

  @override
  State<ClientAuthPage> createState() =>
      _ClientAuthPageState();
}

class _ClientAuthPageState extends State<ClientAuthPage> {
  // ==========================================================
  // CONTROLLER
  // ==========================================================

  final TextEditingController nomController =
      TextEditingController();

  // ==========================================================
  // VARIABLES
  // ==========================================================

  bool connexionEnCours = false;

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    nomController.dispose();
    super.dispose();
  }

  // ==========================================================
  // CONNEXION / IDENTITÉ ANONYME
  // ==========================================================

  Future<void> continuer() async {
    final nom = nomController.text.trim();

    // --------------------------------------------------------
    // VÉRIFICATION DU NOM
    // --------------------------------------------------------

    if (nom.isEmpty) {
      _message(
        "Veuillez saisir votre nom.",
      );
      return;
    }

    // --------------------------------------------------------
    // DÉMARRAGE
    // --------------------------------------------------------

    if (!mounted) return;

    setState(() {
      connexionEnCours = true;
    });

    try {
      // ======================================================
      // 1. VÉRIFIER SI UN UTILISATEUR FIREBASE EXISTE
      // ======================================================

      User? user =
          FirebaseAuth.instance.currentUser;

      // ======================================================
      // 2. SI AUCUN UTILISATEUR
      //    → CRÉER UNE IDENTITÉ ANONYME
      // ======================================================

      if (user == null) {
        final resultat =
            await FirebaseAuth.instance
                .signInAnonymously();

        user = resultat.user;
      }

      // ======================================================
      // 3. VÉRIFICATION DE L'UTILISATEUR
      // ======================================================

      if (user == null) {
        throw Exception(
          "Impossible de créer l'identité du client.",
        );
      }

      // ======================================================
      // 4. RÉFÉRENCE CLIENT FIRESTORE
      // ======================================================

      final clientRef =
          FirebaseFirestore.instance
              .collection("clients")
              .doc(user.uid);

      // ======================================================
      // 5. VÉRIFIER SI LE CLIENT EXISTE DÉJÀ
      // ======================================================

      final ancienClient =
          await clientRef.get();

      // ======================================================
      // 6. DONNÉES CLIENT
      // ======================================================

      final donnees =
          <String, dynamic>{
        "clientId": user.uid,

        "nom": nom,

        "typeCompte": "anonyme",

        "updatedAt":
            FieldValue.serverTimestamp(),
      };

      // ======================================================
      // 7. createdAt UNIQUEMENT À LA CRÉATION
      // ======================================================

      if (!ancienClient.exists) {
        donnees["createdAt"] =
            FieldValue.serverTimestamp();
      }

      // ======================================================
      // 8. ENREGISTRER / METTRE À JOUR LE CLIENT
      // ======================================================

      await clientRef.set(
        donnees,
        SetOptions(
          merge: true,
        ),
      );

      // ======================================================
      // 9. VÉRIFIER QUE LA PAGE EXISTE TOUJOURS
      // ======================================================

      if (!mounted) return;

      // ======================================================
      // 10. RETOUR À LA PAGE AVIS
      //
      // IMPORTANT :
      // On retourne true à AvisCommercePage.
      //
      // AvisCommercePage pourra alors continuer son
      // initialisation sans reconstruire inutilement
      // ClientAuthPage.
      // ======================================================

      Navigator.pop(
        context,
        true,
      );
    }

    // ========================================================
    // ERREUR FIREBASE AUTH
    // ========================================================

    on FirebaseAuthException catch (e) {
      debugPrint(
        "ERREUR AUTH CLIENT : ${e.code}",
      );

      if (!mounted) return;

      String message =
          "Impossible de créer votre compte.";

      // ------------------------------------------------------
      // AUTHENTIFICATION ANONYME NON ACTIVÉE
      // ------------------------------------------------------

      if (e.code ==
          "operation-not-allowed") {
        message =
            "L'authentification anonyme n'est pas activée dans Firebase.";
      }

      // ------------------------------------------------------
      // PROBLÈME RÉSEAU
      // ------------------------------------------------------

      else if (e.code ==
          "network-request-failed") {
        message =
            "Vérifiez votre connexion Internet.";
      }

      // ------------------------------------------------------
      // AUTRE ERREUR AUTH
      // ------------------------------------------------------

      else if (e.message != null &&
          e.message!.isNotEmpty) {
        debugPrint(
          "Message Firebase : ${e.message}",
        );
      }

      _message(message);
    }

    // ========================================================
    // AUTRES ERREURS
    // ========================================================

    catch (e) {
      debugPrint(
        "ERREUR CLIENT AUTH : $e",
      );

      if (!mounted) return;

      _message(
        "Erreur lors de la création du compte.",
      );
    }

    // ========================================================
    // FIN DU TRAITEMENT
    // ========================================================

    finally {
      if (mounted) {
        setState(() {
          connexionEnCours = false;
        });
      }
    }
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
  // CHAMP NOM
  // ==========================================================

  Widget _champNom() {
    return TextField(
      controller: nomController,

      textCapitalization:
          TextCapitalization.words,

      enabled:
          !connexionEnCours,

      keyboardType:
          TextInputType.name,

      textInputAction:
          TextInputAction.done,

      onSubmitted:
          connexionEnCours
              ? null
              : (_) {
                  continuer();
                },

      decoration:
          InputDecoration(
        labelText:
            "Votre nom",

        hintText:
            "Exemple : Aboubacar",

        prefixIcon:
            const Icon(
          Icons.person,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
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
      appBar:
          AppBar(
        title:
            const Text(
          "Espace client",
        ),

        centerTitle:
            true,
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          20,
        ),

        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [

            const SizedBox(
              height: 30,
            ),

            // ==================================================
            // ICÔNE
            // ==================================================

            const Icon(
              Icons.person_pin,
              size: 85,
              color: Colors.orange,
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // TITRE
            // ==================================================

            const Text(
              "Bienvenue",
              textAlign:
                  TextAlign.center,

              style:
                  TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            const Text(
              "Pour laisser un avis, "
              "veuillez indiquer votre nom.",
              textAlign:
                  TextAlign.center,

              style:
                  TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(
              height: 35,
            ),

            // ==================================================
            // NOM
            // ==================================================

            _champNom(),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // BOUTON CONTINUER
            // ==================================================

            SizedBox(
              height: 52,

              child:
                  ElevatedButton.icon(
                onPressed:
                    connexionEnCours
                        ? null
                        : continuer,

                icon:
                    connexionEnCours
                        ? const SizedBox(
                            width: 22,
                            height: 22,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward,
                          ),

                label:
                    Text(
                  connexionEnCours
                      ? "Connexion..."
                      : "Continuer",
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.orange,

                  foregroundColor:
                      Colors.white,

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
              height: 30,
            ),

            // ==================================================
            // INFORMATION
            // ==================================================

            const Text(
              "Votre compte client est créé "
              "automatiquement. Aucun SMS n'est nécessaire.",
              textAlign:
                  TextAlign.center,

              style:
                  TextStyle(
                color:
                    Colors.grey,

                fontSize:
                    12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
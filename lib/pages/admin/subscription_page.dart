import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../../core/app_storage/application_manager.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final referenceController = TextEditingController();

  bool envoiEnCours = false;

  // ==========================================================
  // TARIFICATION
  // ==========================================================

  static const int prixAbonnement = 1000;
  static const int fraisWave = 10;
  static const int montantTotal = 1010;

  // ==========================================================
  // NUMÉRO WAVE
  // ==========================================================

  static const String numeroWave = "+225 05 45 86 86 99";

  // ==========================================================
  // PACKAGE APPLICATION WAVE ANDROID
  // ==========================================================

  static const String wavePackage = "com.wave.personal";

  @override
  void dispose() {
    referenceController.dispose();
    super.dispose();
  }

  // ==========================================================
  // OUVRIR L'APPLICATION WAVE
  // ==========================================================

  Future<void> ouvrirWave() async {
  try {
    const AndroidIntent intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      package: 'com.wave.personal',
      componentName: 'com.wave.customer.RootActivity',
    );

    await intent.launch();
  } catch (e) {
    debugPrint("Erreur ouverture Wave : $e");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Impossible d'ouvrir Wave : $e",
        ),
      ),
    );
  }
}

  // ==========================================================
  // ENVOYER LA DEMANDE D'ABONNEMENT
  // ==========================================================

  Future<void> envoyerDemande() async {
    final reference =
        referenceController.text.trim();

    if (reference.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez renseigner la référence du transfert Wave.",
          ),
        ),
      );
      return;
    }

    final app =
        ApplicationManager.getCurrentApplication();

    if (app == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Commerce introuvable.",
          ),
        ),
      );
      return;
    }

    setState(() {
      envoiEnCours = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("demandes_abonnement")
          .add({
        "commerceId": app.commerceId,

        "nomCommerce": app.name,

        "telephone": app.phone,

        "montantAbonnement":
            prixAbonnement,

        "fraisWave":
            fraisWave,

        "montantTransfere":
            montantTotal,

        "numeroWave":
            numeroWave,

        "referenceWave":
            reference,

        "statut":
            "en_attente",

        "createdAt":
            Timestamp.now(),
      });

      if (!mounted) return;

      referenceController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Votre demande a été envoyée. "
            "Elle sera vérifiée par l'administrateur.",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors de l'envoi : $e",
          ),
        ),
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
  // AFFICHAGE
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mon abonnement",
        ),
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
              Icons.workspace_premium,
              size: 80,
              color: Colors.orange,
            ),

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // TITRE
            // ==================================================

            const Text(
              "Abonnement FATIMA",
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // TARIF
            // ==================================================

            Card(
              elevation: 4,

              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  children: [

                    const Text(
                      "Abonnement 30 jours",

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _ligne(
                      "Abonnement",
                      "1 000 FCFA",
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    _ligne(
                      "Frais Wave (1 %)",
                      "10 FCFA",
                    ),

                    const Divider(
                      height: 30,
                    ),

                    _ligne(
                      "TOTAL À TRANSFÉRER",
                      "1 010 FCFA",
                      important: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // ÉTAPE 1
            // ==================================================

            const Text(
              "1. Effectuez le transfert Wave",

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // ==================================================
            // BOUTON WAVE
            // ==================================================

            Card(
              color:
                  Colors.orange.shade50,

              elevation: 3,

              child: InkWell(
                borderRadius:
                    BorderRadius.circular(12),

                onTap: ouvrirWave,

                child: Padding(
                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    children: [

                      const Icon(
                        Icons
                            .account_balance_wallet,
                        size: 50,
                        color:
                            Colors.orange,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Text(
                        "Ouvrir Wave pour effectuer le transfert",

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      const Text(
                        "Vous devez transférer :",

                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      const Text(
                        "1 010 FCFA",

                        style: TextStyle(
                          fontSize: 25,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.orange,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      const Text(
                        "Vers le numéro :",

                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      const SelectableText(
                        numeroWave,

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 13,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.orange,

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      10),
                        ),

                        child:
                            const Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [

                            Icon(
                              Icons
                                  .open_in_new,
                              color:
                                  Colors.white,
                            ),

                            SizedBox(
                              width: 8,
                            ),

                            Text(
                              "OUVRIR WAVE",

                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize:
                                    16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      const Text(
                        "Après ouverture de Wave, "
                        "effectuez vous-même le transfert "
                        "vers le numéro indiqué ci-dessus.",

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(
                          color:
                              Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // ÉTAPE 2
            // ==================================================

            const Text(
              "2. Entrez la référence du transfert",

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            TextField(
              controller:
                  referenceController,

              decoration:
                  InputDecoration(
                labelText:
                    "Référence Wave",

                hintText:
                    "Exemple : TXN123456789",

                prefixIcon:
                    const Icon(
                  Icons.receipt_long,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // BOUTON CONFIRMATION
            // ==================================================

            ElevatedButton.icon(
              onPressed:
                  envoiEnCours
                      ? null
                      : envoyerDemande,

              icon: envoiEnCours
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

              label: Text(
                envoiEnCours
                    ? "Envoi en cours..."
                    : "J'ai effectué le transfert",
              ),

              style:
                  ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 15,
                ),

                backgroundColor:
                    Colors.orange,

                foregroundColor:
                    Colors.white,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          12),
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
              "Votre abonnement sera activé après "
              "vérification du transfert par l'administrateur.",

              textAlign:
                  TextAlign.center,

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

  // ==========================================================
  // LIGNE TARIF
  // ==========================================================

  Widget _ligne(
    String titre,
    String valeur, {
    bool important = false,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,

      children: [

        Text(
          titre,

          style: TextStyle(
            fontWeight:
                important
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),

        Text(
          valeur,

          style: TextStyle(
            fontSize:
                important ? 20 : 16,

            fontWeight:
                FontWeight.bold,

            color:
                important
                    ? Colors.orange
                    : Colors.black,
          ),
        ),
      ],
    );
  }
}
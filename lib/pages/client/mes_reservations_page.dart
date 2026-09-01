import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MesReservationsPage extends StatefulWidget {
  const MesReservationsPage({
    super.key,
  });

  @override
  State<MesReservationsPage> createState() =>
      _MesReservationsPageState();
}

class _MesReservationsPageState
    extends State<MesReservationsPage> {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController nomController =
      TextEditingController();

  final TextEditingController telephoneController =
      TextEditingController();

  // ==========================================================
  // VARIABLES
  // ==========================================================

  bool rechercheEffectuee = false;

  String nomRecherche = '';
  String telephoneRecherche = '';

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    nomController.dispose();
    telephoneController.dispose();

    super.dispose();
  }

  // ==========================================================
  // NORMALISER TEXTE
  // ==========================================================

  String normaliserTexte(String texte) {
    return texte
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  // ==========================================================
  // NORMALISER TELEPHONE
  // ==========================================================

  String normaliserTelephone(String telephone) {
    String resultat = telephone.trim();

    // Supprimer espaces, tirets, parenthèses, etc.
    resultat = resultat.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );

    // Supprimer le +
    if (resultat.startsWith('+')) {
      resultat = resultat.substring(1);
    }

    // Côte d'Ivoire
    //
    // 0700000000 -> 225700000000
    // 0500000000 -> 225500000000
    // 0100000000 -> 225100000000

    if (resultat.startsWith('0')) {
      resultat = '225${resultat.substring(1)}';
    }

    return resultat;
  }

  // ==========================================================
  // VALIDER LA RECHERCHE
  // ==========================================================

  void _valider() {
    final nom =
        nomController.text.trim();

    final telephone =
        telephoneController.text.trim();

    // --------------------------------------------------------
    // NOM
    // --------------------------------------------------------

    if (nom.isEmpty) {
      _afficherMessage(
        'Veuillez renseigner votre nom.',
      );

      return;
    }

    // --------------------------------------------------------
    // TELEPHONE
    // --------------------------------------------------------

    if (telephone.isEmpty) {
      _afficherMessage(
        'Veuillez renseigner votre numéro de téléphone.',
      );

      return;
    }

    final telephoneNormalise =
        normaliserTelephone(telephone);

    if (telephoneNormalise.isEmpty) {
      _afficherMessage(
        'Veuillez renseigner un numéro de téléphone valide.',
      );

      return;
    }

    // --------------------------------------------------------
    // LANCER LA RECHERCHE
    // --------------------------------------------------------

    setState(() {
      nomRecherche =
          normaliserTexte(nom);

      telephoneRecherche =
          telephoneNormalise;

      rechercheEffectuee = true;
    });
  }

  // ==========================================================
  // EFFACER LA RECHERCHE
  // ==========================================================

  void _effacerRecherche() {
    setState(() {
      nomController.clear();
      telephoneController.clear();

      nomRecherche = '';
      telephoneRecherche = '';

      rechercheEffectuee = false;
    });
  }

  // ==========================================================
  // AFFICHER MESSAGE
  // ==========================================================

  void _afficherMessage(
    String message, {
    Color? couleur,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: couleur,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================
  // RECUPERER UNE VALEUR STRING
  // ==========================================================

  String _stringValue(
    Map<String, dynamic> data,
    List<String> keys, {
    String valeurParDefaut = '',
  }) {
    for (final key in keys) {
      final valeur = data[key];

      if (valeur != null &&
          valeur.toString().trim().isNotEmpty) {
        return valeur.toString().trim();
      }
    }

    return valeurParDefaut;
  }

  // ==========================================================
  // RECUPERER UNE VALEUR NUMERIQUE
  // ==========================================================

  double _doubleValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final valeur = data[key];

      if (valeur is num) {
        return valeur.toDouble();
      }

      if (valeur != null) {
        final resultat =
            double.tryParse(
          valeur.toString().replaceAll(',', '.'),
        );

        if (resultat != null) {
          return resultat;
        }
      }
    }

    return 0;
  }

  // ==========================================================
  // RECUPERER DATE
  // ==========================================================

  DateTime? _recupererDate(
    dynamic valeur,
  ) {
    if (valeur == null) {
      return null;
    }

    if (valeur is Timestamp) {
      return valeur.toDate();
    }

    if (valeur is DateTime) {
      return valeur;
    }

    if (valeur is String) {
      return DateTime.tryParse(
        valeur,
      );
    }

    return null;
  }

  // ==========================================================
  // RECUPERER DATE RESERVATION
  // ==========================================================

  DateTime? _dateReservation(
    Map<String, dynamic> reservation,
  ) {
    // On teste plusieurs noms possibles
    // pour être compatible avec la structure actuelle.

    final valeurs = [
      reservation['reservationDate'],
      reservation['dateReservation'],
      reservation['date'],
      reservation['scheduledDate'],
      reservation['createdAt'],
    ];

    for (final valeur in valeurs) {
      final date = _recupererDate(valeur);

      if (date != null) {
        return date;
      }
    }

    return null;
  }

  // ==========================================================
  // FORMATER DATE
  // ==========================================================

  String formaterDate(
    Map<String, dynamic> reservation,
  ) {
    final date =
        _dateReservation(reservation);

    if (date == null) {
      return 'Date non disponible';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ==========================================================
  // FORMATER HEURE
  // ==========================================================

  String formaterHeure(
    Map<String, dynamic> reservation,
  ) {
    final date =
        _dateReservation(reservation);

    if (date == null) {
      return '--:--';
    }

    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  // ==========================================================
  // STATUT NORMALISE
  // ==========================================================

  String _statutNormalise(
    String statut,
  ) {
    final valeur =
        normaliserTexte(statut);

    switch (valeur) {
      case 'confirmee':
      case 'confirmée':
      case 'confirme':
      case 'confirmé':
        return 'confirmee';

      case 'terminee':
      case 'terminée':
      case 'termine':
      case 'terminé':
        return 'terminee';

      case 'annulee':
      case 'annulée':
      case 'annule':
      case 'annulé':
        return 'annulee';

      case 'en attente':
      case 'attente':
      case 'pending':
        return 'en attente';

      default:
        return 'en attente';
    }
  }

  // ==========================================================
  // COULEUR STATUT
  // ==========================================================

  Color couleurStatut(
    String statut,
  ) {
    switch (_statutNormalise(statut)) {
      case 'confirmee':
        return Colors.green;

      case 'terminee':
        return Colors.green.shade700;

      case 'annulee':
        return Colors.red;

      case 'en attente':
      default:
        return Colors.orange;
    }
  }

  // ==========================================================
  // RECUPERER INDEX ETAPE
  //
  // 0 = En attente
  // 1 = Confirmée
  // 2 = Terminée
  // ==========================================================

  int _indexEtape(
    String statut,
  ) {
    switch (_statutNormalise(statut)) {
      case 'confirmee':
        return 1;

      case 'terminee':
        return 2;

      case 'annulee':
        return -1;

      case 'en attente':
      default:
        return 0;
    }
  }

  // ==========================================================
  // INDICATEUR ETAPE
  // ==========================================================

  Widget _construireIndicateurEtape({
    required String titre,
    required int index,
    required int etapeActuelle,
  }) {
    final franchie =
        etapeActuelle >= index;

    final actuelle =
        etapeActuelle == index;

    final couleur =
        franchie
            ? (actuelle
                ? Colors.green.shade800
                : Colors.green)
            : Colors.grey.shade300;

    return Column(
      children: [
        AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 300,
          ),
          width: 34,
          height: 34,
          decoration:
              BoxDecoration(
            shape: BoxShape.circle,
            color: couleur,
          ),
          child: Icon(
            franchie
                ? Icons.check
                : Icons.circle,
            size: franchie ? 20 : 10,
            color: franchie
                ? Colors.white
                : Colors.grey.shade500,
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        Text(
          titre,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                actuelle
                    ? FontWeight.bold
                    : FontWeight.w500,
            color:
                franchie
                    ? Colors.green.shade800
                    : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // LIGNE ENTRE LES ETAPES
  // ==========================================================

  Widget _construireLigneEtape({
    required bool active,
  }) {
    return Expanded(
      child: Container(
        height: 3,
        margin:
            const EdgeInsets.only(
          bottom: 25,
          left: 5,
          right: 5,
        ),
        decoration:
            BoxDecoration(
          color:
              active
                  ? Colors.green
                  : Colors.grey.shade300,
          borderRadius:
              BorderRadius.circular(
            10,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // PROGRESSION RESERVATION
  // ==========================================================

  Widget _construireProgression(
    String statut,
  ) {
    final etapeActuelle =
        _indexEtape(statut);

    // --------------------------------------------------------
    // RESERVATION ANNULEE
    // --------------------------------------------------------

    if (etapeActuelle == -1) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(
          12,
        ),
        decoration:
            BoxDecoration(
          color: Colors.red.shade50,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cancel,
              color: Colors.red.shade700,
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                'Réservation annulée',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        10,
        15,
        10,
        10,
      ),
      decoration:
          BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _construireIndicateurEtape(
            titre: 'En attente',
            index: 0,
            etapeActuelle:
                etapeActuelle,
          ),

          _construireLigneEtape(
            active:
                etapeActuelle >= 1,
          ),

          _construireIndicateurEtape(
            titre: 'Confirmée',
            index: 1,
            etapeActuelle:
                etapeActuelle,
          ),

          _construireLigneEtape(
            active:
                etapeActuelle >= 2,
          ),

          _construireIndicateurEtape(
            titre: 'Terminée',
            index: 2,
            etapeActuelle:
                etapeActuelle,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // IMAGE SERVICE / ARTICLE
  // ==========================================================

  Widget _construireImageService(
    Map<String, dynamic> reservation,
  ) {
    final image =
        _stringValue(
      reservation,
      [
        'serviceImage',
        'articleImage',
        'image',
        'imageUrl',
        'photo',
        'servicePhoto',
      ],
    );

    final imageBase64 =
        _stringValue(
      reservation,
      [
        'serviceImageBase64',
        'articleImageBase64',
        'imageBase64',
        'photoBase64',
      ],
    );

    // ========================================================
    // URL
    // ========================================================

    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return _cadreImage(
        Image.network(
          image,
          width: 105,
          height: 105,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) {
            return _imageErreur();
          },
        ),
      );
    }

    // ========================================================
    // DATA URI
    // ========================================================

    if (image.startsWith('data:image')) {
      try {
        final partie =
            image.split(',').last;

        final bytes =
            base64Decode(partie);

        return _cadreImage(
          Image.memory(
            bytes,
            width: 105,
            height: 105,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {}
    }

    // ========================================================
    // BASE64
    // ========================================================

    if (imageBase64.isNotEmpty) {
      try {
        final bytes =
            base64Decode(
          imageBase64,
        );

        return _cadreImage(
          Image.memory(
            bytes,
            width: 105,
            height: 105,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {}
    }

    return _imageErreur();
  }

  // ==========================================================
  // CADRE IMAGE
  // ==========================================================

  Widget _cadreImage(
    Widget image,
  ) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        12,
      ),
      child: SizedBox(
        width: 105,
        height: 105,
        child: image,
      ),
    );
  }

  // ==========================================================
  // IMAGE PAR DEFAUT
  // ==========================================================

  Widget _imageErreur() {
    return Container(
      width: 105,
      height: 105,
      decoration:
          BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 40,
      ),
    );
  }

  // ==========================================================
  // RECUPERER NOM COMMERCE
  // ==========================================================

  Future<String> _recupererNomCommerce(
    Map<String, dynamic> reservation,
  ) async {
    // --------------------------------------------------------
    // Si le nom est déjà enregistré dans la réservation
    // --------------------------------------------------------

    final nomDirect =
        _stringValue(
      reservation,
      [
        'commerceName',
        'nomCommerce',
        'businessName',
        'shopName',
      ],
    );

    if (nomDirect.isNotEmpty) {
      return nomDirect;
    }

    // --------------------------------------------------------
    // Sinon recherche avec commerceId
    // --------------------------------------------------------

    final commerceId =
        _stringValue(
      reservation,
      [
        'commerceId',
        'businessId',
        'shopId',
      ],
    );

    if (commerceId.isEmpty) {
      return 'Commerce';
    }

    try {
      final document =
          await FirebaseFirestore
              .instance
              .collection('commerces')
              .doc(commerceId)
              .get();

      if (!document.exists) {
        return 'Commerce';
      }

      final data =
          document.data();

      if (data == null) {
        return 'Commerce';
      }

      return _stringValue(
        data,
        [
          'name',
          'nom',
          'commerceName',
        ],
        valeurParDefaut: 'Commerce',
      );
    } catch (e) {
      debugPrint(
        'ERREUR NOM COMMERCE : $e',
      );

      return 'Commerce';
    }
  }

  // ==========================================================
  // CARTE RESERVATION
  // ==========================================================

  Widget _construireCarteReservation(
    Map<String, dynamic> reservation,
  ) {
    final service =
        _stringValue(
      reservation,
      [
        'serviceName',
        'articleName',
        'service',
        'article',
        'itemName',
      ],
      valeurParDefaut: 'Service',
    );

    final statut =
        _stringValue(
      reservation,
      [
        'status',
        'statut',
      ],
      valeurParDefaut: 'En attente',
    );

    final commentaire =
        _stringValue(
      reservation,
      [
        'comment',
        'commentaire',
        'notes',
      ],
    );

    final employe =
        _stringValue(
      reservation,
      [
        'employeeName',
        'employeName',
        'employee',
        'employe',
        'staffName',
      ],
    );

    final prix =
        _doubleValue(
      reservation,
      [
        'price',
        'prix',
        'servicePrice',
        'articlePrice',
        'amount',
        'montant',
      ],
    );

    final hasVoiceNote =
        reservation['hasVoiceNote'] == true;

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 18,
      ),
      elevation: 3,
      shadowColor:
          Colors.black.withValues(
        alpha: 0.08,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          15,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // IMAGE + INFORMATIONS PRINCIPALES
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _construireImageService(
                  reservation,
                ),

                const SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ----------------------------------------
                      // COMMERCE
                      // ----------------------------------------

                      FutureBuilder<String>(
                        future:
                            _recupererNomCommerce(
                          reservation,
                        ),
                        builder:
                            (
                          context,
                          snapshot,
                        ) {
                          final nomCommerce =
                              snapshot.data ??
                                  'Commerce';

                          return Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Icon(
                                Icons.store,
                                size: 18,
                                color:
                                    Colors.deepPurple,
                              ),

                              const SizedBox(
                                width: 6,
                              ),

                              Expanded(
                                child:
                                    Text(
                                  nomCommerce,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(
                        height: 9,
                      ),

                      // ----------------------------------------
                      // SERVICE
                      // ----------------------------------------

                      Text(
                        service,
                        maxLines: 3,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      // ----------------------------------------
                      // STATUT
                      // ----------------------------------------

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
                              couleurStatut(
                            statut,
                          ).withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Text(
                          statut,
                          style:
                              TextStyle(
                            color:
                                couleurStatut(
                              statut,
                            ),
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            const Divider(),

            const SizedBox(
              height: 12,
            ),

            // ==================================================
            // DATE
            // ==================================================

            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 20,
                  color:
                      Colors.deepPurple,
                ),

                const SizedBox(
                  width: 8,
                ),

                const Text(
                  'Date : ',
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Expanded(
                  child: Text(
                    formaterDate(
                      reservation,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 9,
            ),

            // ==================================================
            // HEURE
            // ==================================================

            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 20,
                  color:
                      Colors.deepPurple,
                ),

                const SizedBox(
                  width: 8,
                ),

                const Text(
                  'Heure : ',
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Expanded(
                  child: Text(
                    formaterHeure(
                      reservation,
                    ),
                  ),
                ),
              ],
            ),

            // ==================================================
            // PRIX
            // ==================================================

            if (prix > 0) ...[
              const SizedBox(
                height: 9,
              ),

              Row(
                children: [
                  const Icon(
                    Icons.payments,
                    size: 20,
                    color:
                        Colors.green,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  const Text(
                    'Prix : ',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${prix.toStringAsFixed(0)} FCFA',
                    style:
                        const TextStyle(
                      color:
                          Colors.green,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],

            // ==================================================
            // EMPLOYE
            // ==================================================

            if (employe.isNotEmpty) ...[
              const SizedBox(
                height: 9,
              ),

              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 20,
                    color:
                        Colors.deepPurple,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  const Text(
                    'Employé : ',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Expanded(
                    child: Text(
                      employe,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(
              height: 18,
            ),

            // ==================================================
            // PROGRESSION
            // ==================================================

            const Text(
              'Progression de la réservation',
              style:
                  TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            _construireProgression(
              statut,
            ),

            // ==================================================
            // COMMENTAIRE
            // ==================================================

            if (commentaire.isNotEmpty) ...[
              const SizedBox(
                height: 14,
              ),

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  11,
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
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Icon(
                      Icons.comment,
                      size: 20,
                      color:
                          Colors.deepPurple,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child: Text(
                        commentaire,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ==================================================
            // NOTE VOCALE
            // ==================================================

            if (hasVoiceNote) ...[
              const SizedBox(
                height: 10,
              ),

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  10,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.green.shade50,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.mic,
                      color:
                          Colors.green,
                    ),

                    SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child: Text(
                        'Une note vocale est associée à cette réservation.',
                        style:
                            TextStyle(
                          color:
                              Colors.green,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FILTRER UNE RESERVATION
  // ==========================================================

  bool _reservationCorrespond(
    Map<String, dynamic> data,
  ) {
    final nomClient =
        normaliserTexte(
      _stringValue(
        data,
        [
          'clientName',
          'nomClient',
          'client',
          'customerName',
        ],
      ),
    );

    final telephoneClient =
        normaliserTelephone(
      _stringValue(
        data,
        [
          'phone',
          'telephone',
          'clientPhone',
          'customerPhone',
        ],
      ),
    );

    return nomClient ==
            nomRecherche &&
        telephoneClient ==
            telephoneRecherche;
  }

  // ==========================================================
  // TRIER LES RESERVATIONS
  // ==========================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      _filtrerEtTrier(
    QuerySnapshot<Map<String, dynamic>>
        snapshot,
  ) {
    final resultat =
        snapshot.docs.where(
      (document) {
        return _reservationCorrespond(
          document.data(),
        );
      },
    ).toList();

    resultat.sort(
      (a, b) {
        final dateA =
            _dateReservation(
          a.data(),
        );

        final dateB =
            _dateReservation(
          b.data(),
        );

        if (dateA == null &&
            dateB == null) {
          return 0;
        }

        if (dateA == null) {
          return 1;
        }

        if (dateB == null) {
          return -1;
        }

        return dateB.compareTo(dateA);
      },
    );

    return resultat;
  }

  // ==========================================================
  // RESULTATS EN TEMPS REEL
  // ==========================================================

  Widget _construireResultatsTempsReel() {
    if (!rechercheEffectuee) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('reservations')
              .snapshots(),

      builder:
          (
        context,
        snapshot,
      ) {
        // ====================================================
        // CHARGEMENT
        // ====================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding:
                EdgeInsets.only(
              top: 30,
            ),
            child: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        // ====================================================
        // ERREUR
        // ====================================================

        if (snapshot.hasError) {
          debugPrint(
            'ERREUR STREAM RESERVATIONS : '
            '${snapshot.error}',
          );

          return Container(
            margin:
                const EdgeInsets.only(
              top: 25,
            ),
            padding:
                const EdgeInsets.all(
              20,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.red.shade50,
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red,
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(
                  'Impossible de charger vos réservations.',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        // ====================================================
        // FILTRAGE
        // ====================================================

        final documents =
            _filtrerEtTrier(
          snapshot.data!,
        );

        // ====================================================
        // AUCUNE RESERVATION
        // ====================================================

        if (documents.isEmpty) {
          return Container(
            margin:
                const EdgeInsets.only(
              top: 25,
            ),
            padding:
                const EdgeInsets.all(
              20,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.grey.shade100,
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.event_busy,
                  size: 55,
                  color: Colors.grey,
                ),

                const SizedBox(
                  height: 12,
                ),

                const Text(
                  'Aucune réservation trouvée',
                  textAlign:
                      TextAlign.center,
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
                  'Vérifiez que vous utilisez '
                  'le même nom et le même numéro '
                  'de téléphone que lors de la réservation.',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color:
                        Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }

        // ====================================================
        // NOMBRE DE RESERVATIONS
        // ====================================================

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),

            Row(
              children: [
                const Icon(
                  Icons.history,
                  color:
                      Colors.deepPurple,
                ),

                const SizedBox(
                  width: 8,
                ),

                Text(
                  '${documents.length} réservation'
                  '${documents.length > 1 ? 's' : ''}',
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // LISTE
            // ==================================================

            ...documents.map(
              (
                document,
              ) {
                final data =
                    document.data();

                data['_documentId'] =
                    document.id;

                return _construireCarteReservation(
                  data,
                );
              },
            ),
          ],
        );
      },
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
        title:
            const Text(
          'Mes réservations',
        ),
        centerTitle: true,

        actions: [
          if (rechercheEffectuee)
            IconButton(
              tooltip:
                  'Nouvelle recherche',
              icon:
                  const Icon(
                Icons.clear,
              ),
              onPressed:
                  _effacerRecherche,
            ),
        ],
      ),

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            20,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,

            children: [
              // ==================================================
              // ICONE
              // ==================================================

              const SizedBox(
                height: 10,
              ),

              const Icon(
                Icons.calendar_month,
                size: 75,
                color:
                    Colors.deepPurple,
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // TITRE
              // ==================================================

              const Text(
                'Retrouver mes réservations',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                'Entrez votre nom et votre numéro '
                'de téléphone pour retrouver vos réservations.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  fontSize: 15,
                  color:
                      Colors.grey.shade700,
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // NOM
              // ==================================================

              TextField(
                controller:
                    nomController,
                textInputAction:
                    TextInputAction.next,

                decoration:
                    InputDecoration(
                  labelText:
                      'Nom du client',
                  hintText:
                      'Ex : Mariam Bamba',

                  prefixIcon:
                      const Icon(
                    Icons.person,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // ==================================================
              // TELEPHONE
              // ==================================================

              TextField(
                controller:
                    telephoneController,
                keyboardType:
                    TextInputType.phone,
                textInputAction:
                    TextInputAction.done,

                onSubmitted:
                    (_) {
                  _valider();
                },

                decoration:
                    InputDecoration(
                  labelText:
                      'Numéro de téléphone',

                  hintText:
                      'Ex : +2250700000000',

                  prefixIcon:
                      const Icon(
                    Icons.phone,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 22,
              ),

              // ==================================================
              // BOUTON RECHERCHE
              // ==================================================

              SizedBox(
                height: 52,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      _valider,

                  icon:
                      const Icon(
                    Icons.search,
                  ),

                  label:
                      const Text(
                    'Voir mes réservations',
                    style:
                        TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.deepPurple,
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
                height: 15,
              ),

              // ==================================================
              // INFORMATION
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.all(
                  14,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.deepPurple.shade50,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Icon(
                      Icons.info_outline,
                      color:
                          Colors.deepPurple
                              .shade700,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        'Utilisez exactement le même '
                        'nom et le même numéro de téléphone '
                        'que ceux utilisés lors de la réservation.'
                        'Pour toute assistance, veuillez appeler l’un des numéros suivants : +225 05 45 86 86 99 / +225 01 60 37 70 42.',
                        style:
                            TextStyle(
                          fontSize: 13,
                          color:
                              Colors.deepPurple
                                  .shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // RESULTATS TEMPS REEL
              // ==================================================

              _construireResultatsTempsReel(),
            ],
          ),
        ),
      ),
    );
  }
}
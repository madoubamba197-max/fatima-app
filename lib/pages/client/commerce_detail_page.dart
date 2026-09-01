import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/business_config.dart';
import '../../models/business_item.dart';
import '../../models/created_application.dart';
import '../reservation/add_reservation_page.dart';
import 'avis_commerce_page.dart';

class CommerceDetailPage extends StatefulWidget {
  final CreatedApplication commerce;

  const CommerceDetailPage({
    super.key,
    required this.commerce,
  });

  @override
  State<CommerceDetailPage> createState() => _CommerceDetailPageState();
}

class _CommerceDetailPageState extends State<CommerceDetailPage> {
  bool avisOuverts = false;

  // ==========================================================
  // AFFICHAGE IMAGE
  // ==========================================================

  Widget _afficherImage(
    String image, {
    BoxFit fit = BoxFit.contain,
  }) {
    if (image.trim().isEmpty) {
      return _imageIndisponible();
    }

    final imageNettoyee = image.trim();

    // ========================================================
    // DATA URI BASE64
    // ========================================================

    if (imageNettoyee.startsWith('data:image')) {
      try {
        final partie = imageNettoyee.split(',').last;
        final bytes = base64Decode(partie);

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          alignment: Alignment.center,
          child: Image.memory(
            bytes,
            width: double.infinity,
            height: double.infinity,
            fit: fit,
            errorBuilder: (_, __, ___) {
              return _imageIndisponible();
            },
          ),
        );
      } catch (_) {
        return _imageIndisponible();
      }
    }

    // ========================================================
    // BASE64 CLASSIQUE
    // ========================================================

    try {
      final bytes = base64Decode(imageNettoyee);

      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        alignment: Alignment.center,
        child: Image.memory(
          bytes,
          width: double.infinity,
          height: double.infinity,
          fit: fit,
          errorBuilder: (_, __, ___) {
            return _imageIndisponible();
          },
        ),
      );
    } catch (_) {
      // Ce n'est pas du Base64.
    }

    // ========================================================
    // URL
    // ========================================================

    if (imageNettoyee.startsWith('http://') ||
        imageNettoyee.startsWith('https://')) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        alignment: Alignment.center,
        child: Image.network(
          imageNettoyee,
          width: double.infinity,
          height: double.infinity,
          fit: fit,
          errorBuilder: (_, __, ___) {
            return _imageIndisponible();
          },
        ),
      );
    }

    return _imageIndisponible();
  }

  Widget _imageIndisponible() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image,
        size: 50,
        color: Colors.grey,
      ),
    );
  }

  // ==========================================================
  // AVIS
  // ==========================================================

  Widget _afficherAvis(String commerceId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('commerces')
          .doc(commerceId)
          .collection('avis')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Erreur lors du chargement des avis :\n${snapshot.error}',
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Aucun avis pour le moment.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        final avis = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              child: Text(
                '${avis.length} avis',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ),

            SizedBox(
              height: 450,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  top: 5,
                  bottom: 10,
                ),
                itemCount: avis.length,
                itemBuilder: (context, index) {
                  final data =
                      avis[index].data() as Map<String, dynamic>;

                  final noteValue = data['note'];

                  final note = noteValue is num
                      ? noteValue.toDouble()
                      : double.tryParse(
                            noteValue?.toString() ?? '0',
                          ) ??
                          0;

                  final commentaire =
                      data['commentaire']?.toString() ?? '';

                  final nomClient =
                      data['nomClient']?.toString() ??
                          data['clientName']?.toString() ??
                          'Client';

                  final createdAt = data['createdAt'];

                  final date = createdAt is Timestamp
                      ? createdAt.toDate()
                      : null;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                child: Icon(Icons.person),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nomClient,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < note
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (commentaire.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              commentaire,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],

                          if (date != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${date.day.toString().padLeft(2, '0')}/'
                              '${date.month.toString().padLeft(2, '0')}/'
                              '${date.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
    );
  }

  // ==========================================================
  // CARTE SERVICE RESPONSIVE
  // ==========================================================

  Widget _carteService(
    BuildContext context,
    QueryDocumentSnapshot doc,
    Map<String, dynamic> data,
    String commerceId, {
    required bool uneColonne,
  }) {
    final nom = data['name']?.toString() ?? '';

    final description =
        data['description']?.toString() ?? '';

    final image =
        data['image']?.toString() ?? '';

    final prix =
        int.tryParse(
              data['price']?.toString() ?? '',
            ) ??
            0;

    final categorie =
        data['category']?.toString() ?? '';

    final duree =
        int.tryParse(
              data['duration']?.toString() ?? '',
            ) ??
            0;

    // ========================================================
    // DIMENSIONS ADAPTATIVES
    // ========================================================

    final double hauteurImage =
        uneColonne ? 180 : 125;

    final double hauteurCarte =
        uneColonne ? 430 : 390;

    return SizedBox(
      height: hauteurCarte,
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // PHOTO DU SERVICE
            // ==================================================
            //
            // BoxFit.contain :
            // → l'image entière reste visible
            // → aucune partie de la photo n'est coupée
            // → les espaces blancs sont conservés si nécessaire
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: hauteurImage,
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: _afficherImage(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // ==================================================
            // INFORMATIONS DU SERVICE
            // ==================================================

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  10,
                  12,
                  10,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // NOM
                    // ==================================================

                    Text(
                      nom.isEmpty
                          ? 'Service'
                          : nom,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ==================================================
                    // CATEGORIE
                    // ==================================================

                    if (categorie.isNotEmpty)
                      Text(
                        categorie,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),

                    const SizedBox(height: 5),

                    // ==================================================
                    // DESCRIPTION
                    // ==================================================

                    Text(
                      description.isEmpty
                          ? 'Aucune description'
                          : description,
                      maxLines: uneColonne ? 3 : 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ==================================================
                    // PRIX
                    // ==================================================

                    Text(
                      '$prix ${BusinessConfig.currency}',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // ==================================================
                    // DUREE
                    // ==================================================

                    Text(
                      'Durée : $duree min',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),

                    const Spacer(),

                    // ==================================================
                    // BOUTON RESERVER
                    // ==================================================

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddReservationPage(
                                commerceId:
                                    commerceId,
                                item:
                                    BusinessItem
                                        .fromFirestore(
                                  doc.id,
                                  data,
                                ),
                              ),
                            ),
                          );
                        },
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              BusinessConfig
                                  .primaryColor,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          minimumSize:
                              const Size(
                            double.infinity,
                            44,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 8,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Réserver',
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final commerce = widget.commerce;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          commerce.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body: ListView(
        children: [
          // =====================================================
          // COUVERTURE
          // =====================================================

          SizedBox(
            height: 220,
            width: double.infinity,
            child: commerce.coverImage.isNotEmpty
                ? _afficherImage(
                    commerce.coverImage,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 15),

          // =====================================================
          // LOGO
          // =====================================================

          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.shade50,
              ),
              clipBehavior:
                  Clip.antiAlias,
              child: commerce.logo.isNotEmpty
                  ? _afficherImage(
                      commerce.logo,
                      fit: BoxFit.contain,
                    )
                  : const Icon(
                      Icons.store,
                      size: 45,
                      color: Colors.deepPurple,
                    ),
            ),
          ),

          const SizedBox(height: 15),

          // =====================================================
          // NOM + SLOGAN
          // =====================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Text(
              commerce.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
              textAlign:
                  TextAlign.center,
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Text(
              commerce.slogan,
              textAlign:
                  TextAlign.center,
            ),
          ),

          const SizedBox(height: 15),

          // =====================================================
          // NOTE GLOBALE
          // =====================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.orange,
                ),

                const SizedBox(width: 5),

                Text(
                  commerce.rating
                      .toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 5),

                Flexible(
                  child: Text(
                    '(${commerce.reviews} avis)',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // =====================================================
          // DONNER MON AVIS
          // =====================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AvisCommercePage(
                      commerceId:
                          commerce.commerceId,
                      nomCommerce:
                          commerce.name,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.rate_review,
              ),
              label: const Text(
                'Donner mon avis',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.orange,
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 13,
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

          const SizedBox(height: 20),

          // =====================================================
          // AVIS DES CLIENTS
          // =====================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: ExpansionTile(
                initiallyExpanded:
                    false,
                onExpansionChanged:
                    (ouvert) {
                  setState(() {
                    avisOuverts = ouvert;
                  });
                },
                leading: const Icon(
                  Icons.rate_review,
                  color: Colors.orange,
                ),
                title: const Text(
                  'Avis des clients',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  avisOuverts
                      ? 'Masquer les avis'
                      : 'Afficher les avis',
                  style:
                      const TextStyle(
                    fontSize: 12,
                  ),
                ),
                children: avisOuverts
                    ? [
                        _afficherAvis(
                          commerce.commerceId,
                        ),
                      ]
                    : [],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // =====================================================
          // ADRESSE
          // =====================================================

          ListTile(
            leading:
                const Icon(
              Icons.location_on,
            ),
            title:
                Text(commerce.address),
          ),

          // =====================================================
          // TELEPHONE
          // =====================================================

          ListTile(
            leading:
                const Icon(
              Icons.phone,
            ),
            title:
                Text(commerce.phone),
          ),

          const Divider(),

          // =====================================================
          // TITRE SERVICES
          // =====================================================

          const Padding(
            padding:
                EdgeInsets.all(15),
            child: Text(
              'Nos services',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          // =====================================================
          // SERVICES
          // =====================================================

          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore
                    .instance
                    .collection(
                      'commerces',
                    )
                    .doc(
                      commerce.commerceId,
                    )
                    .collection(
                      'services',
                    )
                    .orderBy(
                      'createdAt',
                    )
                    .snapshots(),

            builder:
                (context, snapshot) {
              // =================================================
              // CHARGEMENT
              // =================================================

              if (snapshot
                      .connectionState ==
                  ConnectionState.waiting) {
                return const Padding(
                  padding:
                      EdgeInsets.all(30),
                  child: Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                );
              }

              // =================================================
              // ERREUR
              // =================================================

              if (snapshot.hasError) {
                return Padding(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Center(
                    child: Text(
                      'Erreur : ${snapshot.error}',
                    ),
                  ),
                );
              }

              // =================================================
              // AUCUN SERVICE
              // =================================================

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding:
                      EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Aucun service disponible',
                    ),
                  ),
                );
              }

              final services =
                  snapshot.data!.docs;

              // =================================================
              // RESPONSIVE
              // =================================================
              //
              // On regarde la largeur réelle disponible.
              //
              // < 380 px :
              //     1 carte par ligne
              //
              // >= 380 px :
              //     2 cartes par ligne
              //
              // Cela évite que le bouton "Réserver"
              // soit coupé sur les petits téléphones.
              // =================================================

              return LayoutBuilder(
                builder:
                    (
                  context,
                  constraints,
                ) {
                  final largeur =
                      constraints.maxWidth;

                  final bool uneColonne =
                      largeur < 380;

                  final int nombreColonnes =
                      uneColonne ? 1 : 2;

                  final double espace =
                      12;

                  final double largeurCarte =
                      nombreColonnes == 1
                          ? largeur -
                              24
                          : (largeur -
                                  24 -
                                  espace) /
                              2;

                  // Petite sécurité pour éviter
                  // des dimensions impossibles.
                  final double hauteurImage =
                      uneColonne
                          ? 180
                          : 125;

                  final double hauteurCarte =
                      uneColonne
                          ? 430
                          : 390;

                  return GridView.builder(
                    shrinkWrap: true,

                    physics:
                        const NeverScrollableScrollPhysics(),

                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),

                    itemCount:
                        services.length,

                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          nombreColonnes,

                      crossAxisSpacing:
                          espace,

                      mainAxisSpacing:
                          espace,

                      mainAxisExtent:
                          hauteurCarte,
                    ),

                    itemBuilder:
                        (context, index) {
                      final doc =
                          services[index];

                      final data =
                          doc.data()
                              as Map<String,
                                  dynamic>;

                      return _carteService(
                        context,
                        doc,
                        data,
                        commerce.commerceId,
                        uneColonne:
                            uneColonne,
                      );
                    },
                  );
                },
              );
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
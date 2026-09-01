import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvisCommerceBusinessPage extends StatelessWidget {
  final String commerceId;
  final String nomCommerce;

  const AvisCommerceBusinessPage({
    super.key,
    required this.commerceId,
    required this.nomCommerce,
  });

  @override
  Widget build(BuildContext context) {
    final commerceRef = FirebaseFirestore.instance
        .collection('commerces')
        .doc(commerceId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avis des clients'),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: commerceRef
            .collection('avis')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          // ====================================================
          // CHARGEMENT
          // ====================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ====================================================
          // ERREUR
          // ====================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Impossible de charger les avis.\n\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final avis =
              snapshot.data?.docs ?? [];

          // ====================================================
          // AUCUN AVIS
          // ====================================================

          if (avis.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.rate_review_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      nomCommerce,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Aucun avis client pour le moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ====================================================
          // LISTE DES AVIS
          // ====================================================

          return ListView(
            padding: const EdgeInsets.all(15),

            children: [
              // ==================================================
              // EN-TÊTE
              // ==================================================

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),

                  child: Column(
                    children: [
                      Text(
                        nomCommerce,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 32,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            _calculerMoyenne(avis)
                                .toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            '(${avis.length} avis)',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // AVIS
              // ==================================================

              ...avis.map(
                (document) {
                  final data =
                      document.data()
                          as Map<String, dynamic>;

                  return _buildAvisCard(
                    data,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // CARTE AVIS
  // ==========================================================

  Widget _buildAvisCard(
    Map<String, dynamic> data,
  ) {
    final nom =
        data['nomClient']
            ?.toString()
            .trim();

    final commentaire =
        data['commentaire']
            ?.toString()
            .trim();

    final noteData =
        data['note'];

    final note =
        noteData is num
            ? noteData.toInt()
            : 0;

    final date =
        _convertirDate(
      data['createdAt'],
    );

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // NOM + NOTE
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                CircleAvatar(
                  backgroundColor:
                      Colors.orange.shade100,

                  child: const Icon(
                    Icons.person,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        nom == null ||
                                nom.isEmpty
                            ? 'Client'
                            : nom,

                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) {
                              return Icon(
                                index < note
                                    ? Icons.star
                                    : Icons.star_border,
                                color:
                                    Colors.amber,
                                size: 20,
                              );
                            },
                          ),

                          const SizedBox(
                            width: 6,
                          ),

                          Text(
                            '$note/5',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // COMMENTAIRE
            // ==================================================

            if (commentaire != null &&
                commentaire.isNotEmpty)
              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(12),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.grey.shade100,

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),

                child: Text(
                  commentaire,

                  style:
                      const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),

            // ==================================================
            // DATE
            // ==================================================

            if (date != null) ...[
              const SizedBox(
                height: 10,
              ),

              Align(
                alignment:
                    Alignment.centerRight,

                child: Text(
                  'Publié le ${_formatDate(date)}',

                  style:
                      const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CALCUL MOYENNE
  // ==========================================================

  double _calculerMoyenne(
    List<QueryDocumentSnapshot> avis,
  ) {
    if (avis.isEmpty) {
      return 0;
    }

    double total = 0;

    for (final document in avis) {
      final data =
          document.data()
              as Map<String, dynamic>;

      final note =
          data['note'];

      if (note is num) {
        total += note.toDouble();
      }
    }

    return total / avis.length;
  }

  // ==========================================================
  // DATE FIRESTORE
  // ==========================================================

  DateTime? _convertirDate(
    dynamic valeur,
  ) {
    if (valeur is Timestamp) {
      return valeur.toDate();
    }

    if (valeur is DateTime) {
      return valeur;
    }

    return null;
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
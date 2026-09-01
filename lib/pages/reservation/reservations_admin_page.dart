import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_storage/application_manager.dart';
import '../../services/contact_service.dart';

class ReservationsAdminPage extends StatefulWidget {
  const ReservationsAdminPage({super.key});

  @override
  State<ReservationsAdminPage> createState() =>
      _ReservationsAdminPageState();
}

class _ReservationsAdminPageState
    extends State<ReservationsAdminPage> {
  // ==========================================================
  // LECTEUR AUDIO
  // ==========================================================

  final audio.AudioPlayer _audioPlayer = audio.AudioPlayer();

  StreamSubscription<audio.PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  String? _reservationAudioEnCours;

  bool _audioEnChargement = false;

  audio.PlayerState _playerState =
      audio.PlayerState.stopped;

  Duration _audioPosition = Duration.zero;

  Duration _audioDuree = Duration.zero;

  // ==========================================================
  // REQUETE FIRESTORE CONSERVEE
  // ==========================================================
  //
  // IMPORTANT :
  // On ne recrée pas la requête à chaque setState().
  //
  // Cela évite que la page affiche "chargement" pendant
  // la lecture de la note vocale.
  // ==========================================================

  Stream<QuerySnapshot>? _reservationsStream;

  // ==========================================================
  // FILTRE
  // ==========================================================

  final TextEditingController _rechercheController =
      TextEditingController();

  String _statutSelectionne = "Tous";

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    // ----------------------------------------------------------
    // INITIALISATION DU LECTEUR
    // ----------------------------------------------------------

    _playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen(
      (state) {
        if (!mounted) {
          return;
        }

        setState(() {
          _playerState = state;

          if (state == audio.PlayerState.completed) {
            _audioEnChargement = false;
            _audioPosition = Duration.zero;
          }

          if (state == audio.PlayerState.stopped) {
            _audioEnChargement = false;
          }
        });
      },
    );

    // ----------------------------------------------------------
    // POSITION AUDIO
    // ----------------------------------------------------------

    _positionSubscription =
        _audioPlayer.onPositionChanged.listen(
      (position) {
        if (!mounted) {
          return;
        }

        setState(() {
          _audioPosition = position;
        });
      },
    );

    // ----------------------------------------------------------
    // DUREE AUDIO
    // ----------------------------------------------------------

    _durationSubscription =
        _audioPlayer.onDurationChanged.listen(
      (duration) {
        if (!mounted) {
          return;
        }

        setState(() {
          _audioDuree = duration;
        });
      },
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();

    _rechercheController.dispose();

    _audioPlayer.dispose();

    super.dispose();
  }

  // ==========================================================
  // CREER LA REQUETE FIRESTORE
  // ==========================================================

  void _initialiserStreamReservations(
    String commerceId,
  ) {
    _reservationsStream ??= FirebaseFirestore.instance
        .collection("reservations")
        .where(
          "commerceId",
          isEqualTo: commerceId,
        )
        .snapshots();
  }

  // ==========================================================
  // EXTRAIRE BASE64
  // ==========================================================

  String _nettoyerBase64(
    String valeur,
  ) {
    String base64String = valeur.trim();

    if (base64String.isEmpty) {
      return "";
    }

    // Exemple :
    // data:audio/mp4;base64,AAAA...
    if (base64String.contains(",")) {
      base64String =
          base64String.split(",").last.trim();
    }

    return base64String;
  }

  // ==========================================================
  // LIRE NOTE VOCALE
  // ==========================================================

  Future<void> _lireNoteVocale(
    String reservationId,
    Map<String, dynamic> data,
  ) async {
    try {
      // ========================================================
      // RECUPERATION URL
      // ========================================================

      final voiceNoteUrl =
          data["voiceNoteUrl"]
                  ?.toString()
                  .trim() ??
              "";

      // ========================================================
      // RECUPERATION BASE64
      // ========================================================

      final voiceNoteBase64 =
          data["voiceNoteBase64"]
                  ?.toString()
                  .trim() ??
              "";

      final voiceNoteMimeType =
          data["voiceNoteMimeType"]
                  ?.toString()
                  .trim() ??
              "audio/mp4";

      // ========================================================
      // DEBUG
      // ========================================================

      debugPrint(
        "========================================",
      );

      debugPrint(
        "LECTURE NOTE VOCALE",
      );

      debugPrint(
        "RESERVATION : $reservationId",
      );

      debugPrint(
        "URL PRESENTE : "
        "${voiceNoteUrl.isNotEmpty}",
      );

      debugPrint(
        "BASE64 PRESENT : "
        "${voiceNoteBase64.isNotEmpty}",
      );

      debugPrint(
        "BASE64 LENGTH : "
        "${voiceNoteBase64.length}",
      );

      debugPrint(
        "MIME TYPE : $voiceNoteMimeType",
      );

      debugPrint(
        "========================================",
      );

      // ========================================================
      // AUCUNE NOTE
      // ========================================================

      if (voiceNoteUrl.isEmpty &&
          voiceNoteBase64.isEmpty) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Aucune note vocale disponible.",
            ),
            backgroundColor: Colors.orange,
          ),
        );

        return;
      }

      // ========================================================
      // SI CETTE NOTE EST DEJA SELECTIONNEE
      // ========================================================

      if (_reservationAudioEnCours ==
          reservationId) {
        // ------------------------------------------------------
        // PAUSE
        // ------------------------------------------------------

        if (_playerState ==
            audio.PlayerState.playing) {
          await _audioPlayer.pause();
          return;
        }

        // ------------------------------------------------------
        // REPRISE
        // ------------------------------------------------------

        if (_playerState ==
            audio.PlayerState.paused) {
          await _audioPlayer.resume();
          return;
        }

        // ------------------------------------------------------
        // NOTE TERMINEE
        // ------------------------------------------------------

        if (_playerState ==
            audio.PlayerState.completed) {
          await _audioPlayer.seek(
            Duration.zero,
          );

          await _audioPlayer.resume();

          return;
        }
      }

      // ========================================================
      // ARRETER AUTRE AUDIO
      // ========================================================

      await _audioPlayer.stop();

      if (!mounted) {
        return;
      }

      setState(() {
        _reservationAudioEnCours =
            reservationId;

        _audioEnChargement = true;

        _playerState =
            audio.PlayerState.stopped;

        _audioPosition = Duration.zero;

        _audioDuree = Duration.zero;
      });

      // ========================================================
      // CHOIX DE LA SOURCE AUDIO
      // ========================================================
      //
      // PRIORITE :
      //
      // 1. Base64
      // 2. URL
      //
      // Comme tes anciennes réservations utilisent Base64,
      // nous privilégions Base64.
      // ========================================================

      if (voiceNoteBase64.isNotEmpty) {
        // ------------------------------------------------------
        // LECTURE BASE64
        // ------------------------------------------------------

        final base64String =
            _nettoyerBase64(
          voiceNoteBase64,
        );

        if (base64String.isEmpty) {
          throw Exception(
            "La note vocale Base64 est vide.",
          );
        }

        Uint8List bytes;

        try {
          bytes = base64Decode(
            base64String,
          );
        } catch (e) {
          throw Exception(
            "Base64 audio invalide : $e",
          );
        }

        if (bytes.isEmpty) {
          throw Exception(
            "Les données audio Base64 sont vides.",
          );
        }

        debugPrint(
          "AUDIO BASE64 : lecture de "
          "${bytes.length} octets",
        );

        // ------------------------------------------------------
        // CHARGEMENT AUDIO EN MEMOIRE
        // ------------------------------------------------------

        await _audioPlayer.setSource(
          audio.BytesSource(
            bytes,
            mimeType: voiceNoteMimeType,
          ),
        );
      } else {
        // ------------------------------------------------------
        // LECTURE URL
        // ------------------------------------------------------

        final audioUrl =
            voiceNoteUrl.trim();

        if (!audioUrl.startsWith(
              "http://",
            ) &&
            !audioUrl.startsWith(
              "https://",
            )) {
          throw Exception(
            "L'URL de la note vocale "
            "n'est pas valide.",
          );
        }

        debugPrint(
          "AUDIO URL : $audioUrl",
        );

        await _audioPlayer.setSource(
          audio.UrlSource(
            audioUrl,
          ),
        );
      }

      // ========================================================
      // AUDIO CHARGE
      // ========================================================

      if (!mounted) {
        return;
      }

      setState(() {
        _audioEnChargement = false;
      });

      // ========================================================
      // LANCER
      // ========================================================

      await _audioPlayer.resume();
    } catch (e) {
      debugPrint(
        "ERREUR LECTURE AUDIO : $e",
      );

      try {
        await _audioPlayer.stop();
      } catch (_) {}

      if (!mounted) {
        return;
      }

      setState(() {
        _audioEnChargement = false;

        _reservationAudioEnCours = null;

        _playerState =
            audio.PlayerState.stopped;

        _audioPosition = Duration.zero;

        _audioDuree = Duration.zero;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de lire la note vocale : $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // ARRETER AUDIO
  // ==========================================================

  Future<void> _arreterAudio() async {
    try {
      await _audioPlayer.stop();

      if (!mounted) {
        return;
      }

      setState(() {
        _reservationAudioEnCours = null;

        _audioEnChargement = false;

        _playerState =
            audio.PlayerState.stopped;

        _audioPosition = Duration.zero;

        _audioDuree = Duration.zero;
      });
    } catch (e) {
      debugPrint(
        "ERREUR ARRET AUDIO : $e",
      );
    }
  }

  // ==========================================================
  // FORMAT DUREE
  // ==========================================================

  String _formatDureeAudio(
    Duration duration,
  ) {
    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final secondes = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return "$minutes:$secondes";
  }

  // ==========================================================
  // SECTION NOTE VOCALE
  // ==========================================================

  Widget _sectionNoteVocale(
    BuildContext context,
    String reservationId,
    Map<String, dynamic> data,
  ) {
    final voiceNoteUrl =
        data["voiceNoteUrl"]
                ?.toString()
                .trim() ??
            "";

    final voiceNoteBase64 =
        data["voiceNoteBase64"]
                ?.toString()
                .trim() ??
            "";

    final hasVoiceNote =
        data["hasVoiceNote"] == true;

    // ========================================================
    // NOTE DISPONIBLE
    // ========================================================

    final noteVocaleDisponible =
        voiceNoteUrl.isNotEmpty ||
        voiceNoteBase64.isNotEmpty;

    // ========================================================
    // DEBUG
    // ========================================================

    debugPrint(
      "========================================",
    );

    debugPrint(
      "NOTE VOCALE",
    );

    debugPrint(
      "Reservation ID : $reservationId",
    );

    debugPrint(
      "hasVoiceNote : $hasVoiceNote",
    );

    debugPrint(
      "voiceNoteUrl : "
      "${voiceNoteUrl.isNotEmpty ? 'OUI' : 'NON'}",
    );

    debugPrint(
      "voiceNoteBase64 : "
      "${voiceNoteBase64.isNotEmpty ? 'OUI' : 'NON'}",
    );

    debugPrint(
      "Base64 length : "
      "${voiceNoteBase64.length}",
    );

    debugPrint(
      "Disponible : $noteVocaleDisponible",
    );

    debugPrint(
      "========================================",
    );

    if (!noteVocaleDisponible) {
      return const SizedBox.shrink();
    }

    // ========================================================
    // ETAT DE CETTE NOTE
    // ========================================================

    final estCetteNote =
        _reservationAudioEnCours ==
            reservationId;

    final estEnLecture =
        estCetteNote &&
        _playerState ==
            audio.PlayerState.playing;

    final estEnPause =
        estCetteNote &&
        _playerState ==
            audio.PlayerState.paused;

    final estEnChargement =
        estCetteNote &&
        _audioEnChargement;

    // ========================================================
    // DUREE
    // ========================================================

    final dureeMs =
        _audioDuree.inMilliseconds > 0
            ? _audioDuree.inMilliseconds
            : 1;

    // ========================================================
    // POSITION
    // ========================================================

    final positionMs =
        _audioPosition.inMilliseconds
            .clamp(
          0,
          dureeMs,
        );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 15,
      ),
      padding: const EdgeInsets.all(
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ====================================================
          // TITRE
          // ====================================================

          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(8),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.deepPurple,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Note vocale du client",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      "Message vocal reçu",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          // ====================================================
          // LECTEUR
          // ====================================================

          Row(
            children: [
              // ------------------------------------------------
              // PLAY / PAUSE
              // ------------------------------------------------

              Container(
                decoration:
                    const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple,
                ),
                child: IconButton(
                  tooltip:
                      estEnLecture
                          ? "Pause"
                          : estEnPause
                              ? "Reprendre"
                              : "Lire",
                  onPressed:
                      estEnChargement
                          ? null
                          : () {
                              _lireNoteVocale(
                                reservationId,
                                data,
                              );
                            },
                  icon:
                      estEnChargement
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
                          : Icon(
                              estEnLecture
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color:
                                  Colors.white,
                            ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              // ------------------------------------------------
              // PROGRESSION
              // ------------------------------------------------

              Expanded(
                child: Column(
                  children: [
                    Slider(
                      value:
                          positionMs
                              .toDouble(),
                      min: 0,
                      max:
                          dureeMs
                              .toDouble(),
                      activeColor:
                          Colors.deepPurple,
                      inactiveColor:
                          Colors.deepPurple
                              .shade100,
                      onChanged:
                          estCetteNote &&
                                  _audioDuree
                                          .inMilliseconds >
                                      0
                              ? (
                                  value,
                                ) async {
                                  final nouvellePosition =
                                      Duration(
                                    milliseconds:
                                        value
                                            .round(),
                                  );

                                  await _audioPlayer
                                      .seek(
                                    nouvellePosition,
                                  );
                                }
                              : null,
                    ),

                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 4,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          Text(
                            _formatDureeAudio(
                              _audioPosition,
                            ),
                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  Colors.grey,
                            ),
                          ),
                          Text(
                            _formatDureeAudio(
                              _audioDuree,
                            ),
                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------
              // STOP
              // ------------------------------------------------

              IconButton(
                tooltip: "Arrêter",
                onPressed:
                    estCetteNote
                        ? _arreterAudio
                        : null,
                icon: Icon(
                  Icons.stop_circle,
                  color:
                      estCetteNote
                          ? Colors.red
                          : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // IMAGE SERVICE
  // ==========================================================

  Widget _imageService(
    Map<String, dynamic> data,
  ) {
    String image = "";

    if (data["serviceImageBase64"] != null) {
      image = data["serviceImageBase64"]
          .toString()
          .trim();
    }

    if (image.isEmpty &&
        data["serviceImage"] != null) {
      image = data["serviceImage"]
          .toString()
          .trim();
    }

    if (image.isEmpty) {
      return _imageIndisponible();
    }

    // ========================================================
    // URL
    // ========================================================

    if (image.startsWith("http://") ||
        image.startsWith("https://")) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(12),
        child: Image.network(
          image,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          loadingBuilder:
              (
            context,
            child,
            loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }

            return Container(
              width: 120,
              height: 120,
              color: Colors.grey.shade200,
              child: const Center(
                child:
                    CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder:
              (
            context,
            error,
            stackTrace,
          ) {
            debugPrint(
              "ERREUR IMAGE URL : $error",
            );

            return _imageIndisponible();
          },
        ),
      );
    }

    // ========================================================
    // BASE64
    // ========================================================

    try {
      String base64Image = image;

      if (base64Image.contains(",")) {
        base64Image =
            base64Image
                .split(",")
                .last
                .trim();
      }

      final Uint8List bytes =
          base64Decode(
        base64Image,
      );

      if (bytes.isEmpty) {
        return _imageIndisponible();
      }

      return ClipRRect(
        borderRadius:
            BorderRadius.circular(12),
        child: Image.memory(
          bytes,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder:
              (
            context,
            error,
            stackTrace,
          ) {
            debugPrint(
              "ERREUR IMAGE MEMORY : $error",
            );

            return _imageIndisponible();
          },
        ),
      );
    } catch (e) {
      debugPrint(
        "ERREUR DECODAGE BASE64 : $e",
      );

      return _imageIndisponible();
    }
  }

  // ==========================================================
  // IMAGE INDISPONIBLE
  // ==========================================================

  Widget _imageIndisponible() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: const Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 38,
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            "Image indisponible",
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // STATUT COULEUR
  // ==========================================================

  Color _couleurStatut(
    String statut,
  ) {
    switch (statut) {
      case "En attente":
        return Colors.orange;

      case "Confirmée":
        return Colors.green;

      case "Refusée":
        return Colors.red;

      case "Terminée":
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  // ==========================================================
  // STATUT ICONE
  // ==========================================================

  IconData _iconeStatut(
    String statut,
  ) {
    switch (statut) {
      case "En attente":
        return Icons.access_time;

      case "Confirmée":
        return Icons.check_circle;

      case "Refusée":
        return Icons.cancel;

      case "Terminée":
        return Icons.done_all;

      default:
        return Icons.info;
    }
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String _formatDate(
    dynamic valeur,
  ) {
    if (valeur is! Timestamp) {
      return "Date non définie";
    }

    final date = valeur.toDate();

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  // ==========================================================
  // FORMAT HEURE
  // ==========================================================

  String _formatHeure(
    dynamic valeur,
  ) {
    if (valeur is! Timestamp) {
      return "--:--";
    }

    final date = valeur.toDate();

    return "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  // ==========================================================
  // CHANGER STATUT
  // ==========================================================

  Future<void> _changerStatut(
    BuildContext context,
    DocumentReference reference,
    String nouveauStatut,
  ) async {
    try {
      await reference.update({
        "status": nouveauStatut,
        "updatedAt": Timestamp.now(),
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Réservation $nouveauStatut.",
          ),
          backgroundColor:
              _couleurStatut(
            nouveauStatut,
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        "ERREUR CHANGEMENT STATUT : $e",
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Erreur : $e",
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // CARTE RESERVATION
  // ==========================================================

  Widget _carteReservation(
    BuildContext context,
    QueryDocumentSnapshot doc,
    String commerceName,
  ) {
    final data =
        doc.data()
            as Map<String, dynamic>;

    // ========================================================
    // INFORMATIONS
    // ========================================================

    final clientName =
        data["clientName"]
                ?.toString()
                .trim() ??
            "Client";

    final phone =
        data["phone"]
                ?.toString()
                .trim() ??
            "";

    final serviceName =
        data["serviceName"]
                ?.toString()
                .trim() ??
            "Service";

    final status =
        data["status"]
                ?.toString()
                .trim() ??
            "En attente";

    final comment =
        data["comment"]
                ?.toString()
                .trim() ??
            "";

    final reservationDate =
        data["reservationDate"];

    return Card(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      elevation: 3,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // SERVICE + PHOTO
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _imageService(data),

                const SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              _couleurStatut(
                            status,
                          ).withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              _iconeStatut(
                                status,
                              ),
                              size: 18,
                              color:
                                  _couleurStatut(
                                status,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              status,
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    _couleurStatut(
                                  status,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(
              height: 25,
            ),

            // ==================================================
            // CLIENT
            // ==================================================

            Text(
              "👤 Client : $clientName",
              style:
                  const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              "📞 Téléphone : "
              "${phone.isEmpty ? 'Non renseigné' : phone}",
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              "📅 Date : "
              "${_formatDate(
                reservationDate,
              )}",
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              "🕒 Heure : "
              "${_formatHeure(
                reservationDate,
              )}",
            ),

            // ==================================================
            // COMMENTAIRE
            // ==================================================

            if (comment.isNotEmpty) ...[
              const SizedBox(
                height: 14,
              ),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  12,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                  border: Border.all(
                    color:
                        Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "💬 Commentaire du client",
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      comment,
                      style:
                          const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ==================================================
            // NOTE VOCALE
            // ==================================================

            _sectionNoteVocale(
              context,
              doc.id,
              data,
            ),

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // APPEL + WHATSAPP
            // ==================================================

            Row(
              children: [
                Expanded(
                  child:
                      ElevatedButton.icon(
                    icon: const Icon(
                      Icons.call,
                    ),
                    label: const Text(
                      "Appeler",
                    ),
                    onPressed:
                        phone.isEmpty
                            ? null
                            : () {
                                ContactService
                                    .appeler(
                                  phone,
                                );
                              },
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child:
                      ElevatedButton.icon(
                    icon: const Icon(
                      Icons.message,
                    ),
                    label: const Text(
                      "WhatsApp",
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          Colors.green,
                      foregroundColor:
                          Colors.white,
                    ),
                    onPressed:
                        phone.isEmpty
                            ? null
                            : () {
                                final message =
                                    """
Bonjour $clientName,

Votre réservation chez $commerceName.

Service : $serviceName

Date : ${_formatDate(
                                      reservationDate,
                                    )}

Heure : ${_formatHeure(
                                      reservationDate,
                                    )}

Statut : $status

Merci pour votre confiance.
""";

                                ContactService
                                    .envoyerWhatsapp(
                                  phone,
                                  message,
                                );
                              },
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 8,
            ),

            // ==================================================
            // SMS
            // ==================================================

            SizedBox(
              width: double.infinity,
              child:
                  ElevatedButton.icon(
                icon: const Icon(
                  Icons.sms,
                ),
                label: const Text(
                  "SMS",
                ),
                onPressed:
                    phone.isEmpty
                        ? null
                        : () {
                            final message =
                                """
Bonjour $clientName,

Votre réservation chez $commerceName.

Service : $serviceName

Date : ${_formatDate(
                                  reservationDate,
                                )}

Heure : ${_formatHeure(
                                  reservationDate,
                                )}

Statut : $status

Merci pour votre confiance.
""";

                            ContactService
                                .envoyerSMS(
                              phone,
                              message,
                            );
                          },
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // ==================================================
            // ACTIONS
            // ==================================================

            Row(
              children: [
                // ------------------------------------------------
                // ACCEPTER
                // ------------------------------------------------

                if (status ==
                    "En attente")
                  Expanded(
                    child:
                        ElevatedButton.icon(
                      icon: const Icon(
                        Icons.check,
                      ),
                      label: const Text(
                        "Accepter",
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.green,
                        foregroundColor:
                            Colors.white,
                      ),
                      onPressed: () {
                        _changerStatut(
                          context,
                          doc.reference,
                          "Confirmée",
                        );
                      },
                    ),
                  ),

                if (status ==
                    "En attente")
                  const SizedBox(
                    width: 10,
                  ),

                // ------------------------------------------------
                // REFUSER
                // ------------------------------------------------

                if (status ==
                    "En attente")
                  Expanded(
                    child:
                        ElevatedButton.icon(
                      icon: const Icon(
                        Icons.close,
                      ),
                      label: const Text(
                        "Refuser",
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.red,
                        foregroundColor:
                            Colors.white,
                      ),
                      onPressed: () {
                        _changerStatut(
                          context,
                          doc.reference,
                          "Refusée",
                        );
                      },
                    ),
                  ),

                // ------------------------------------------------
                // TERMINER
                // ------------------------------------------------

                if (status ==
                    "Confirmée")
                  Expanded(
                    child:
                        ElevatedButton.icon(
                      icon: const Icon(
                        Icons.done_all,
                      ),
                      label: const Text(
                        "Terminer",
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.blue,
                        foregroundColor:
                            Colors.white,
                      ),
                      onPressed: () {
                        _changerStatut(
                          context,
                          doc.reference,
                          "Terminée",
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
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final application =
        ApplicationManager
            .getCurrentApplication();

    // ==========================================================
    // APPLICATION INTROUVABLE
    // ==========================================================

    if (application == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Commerce introuvable.",
          ),
        ),
      );
    }

    final commerceId =
        application.commerceId;

    final commerceName =
        application.name;

    // ==========================================================
    // INITIALISER STREAM
    // ==========================================================

    _initialiserStreamReservations(
      commerceId,
    );

    // ==========================================================
    // PAGE
    // ==========================================================

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Réservations",
        ),
      ),

      body: Column(
        children: [
          // ====================================================
          // BARRE DE RECHERCHE
          // ====================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              6,
            ),
            child: TextField(
              controller:
                  _rechercheController,
              onChanged: (_) {
                setState(() {});
              },
              decoration:
                  InputDecoration(
                hintText:
                    "Rechercher client, téléphone ou service...",
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    _rechercheController
                            .text
                            .isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(
                              Icons.clear,
                            ),
                            onPressed: () {
                              _rechercheController
                                  .clear();

                              setState(
                                () {},
                              );
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

          // ====================================================
          // FILTRE STATUT
          // ====================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              12,
              6,
              12,
              10,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  color: Colors.deepPurple,
                ),

                const SizedBox(
                  width: 8,
                ),

                const Text(
                  "Statut :",
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child:
                      DropdownButtonFormField<
                          String>(
                    initialValue:
                        _statutSelectionne,
                    decoration:
                        InputDecoration(
                      contentPadding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Tous",
                        child: Text(
                          "Tous",
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            "En attente",
                        child: Text(
                          "En attente",
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            "Confirmée",
                        child: Text(
                          "Confirmée",
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            "Refusée",
                        child: Text(
                          "Refusée",
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            "Terminée",
                        child: Text(
                          "Terminée",
                        ),
                      ),
                    ],
                    onChanged:
                        (value) {
                      if (value ==
                          null) {
                        return;
                      }

                      setState(() {
                        _statutSelectionne =
                            value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // RESERVATIONS
          // ====================================================

          Expanded(
            child:
                StreamBuilder<QuerySnapshot>(
              stream:
                  _reservationsStream,
              builder:
                  (
                context,
                snapshot,
              ) {
                // ==============================================
                // CHARGEMENT INITIAL
                // ==============================================

                if (snapshot.connectionState ==
                        ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                // ==============================================
                // ERREUR
                // ==============================================

                if (snapshot.hasError) {
                  debugPrint(
                    "ERREUR FIRESTORE : "
                    "${snapshot.error}",
                  );

                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(
                        20,
                      ),
                      child: Text(
                        "Erreur lors du chargement "
                        "des réservations :\n\n"
                        "${snapshot.error}",
                        textAlign:
                            TextAlign.center,
                      ),
                    ),
                  );
                }

                // ==============================================
                // AUCUNE DONNEE
                // ==============================================

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      "Aucune donnée.",
                    ),
                  );
                }

                // ==============================================
                // COPIE
                // ==============================================

                final reservations =
                    snapshot.data!.docs
                        .toList();

                // ==============================================
                // RECHERCHE
                // ==============================================

                final recherche =
                    _rechercheController
                        .text
                        .trim()
                        .toLowerCase();

                // ==============================================
                // FILTRAGE
                // ==============================================

                final reservationsFiltrees =
                    reservations.where(
                  (doc) {
                    final data =
                        doc.data()
                            as Map<String,
                                dynamic>;

                    final clientName =
                        data["clientName"]
                                ?.toString()
                                .toLowerCase() ??
                            "";

                    final phone =
                        data["phone"]
                                ?.toString()
                                .toLowerCase() ??
                            "";

                    final serviceName =
                        data["serviceName"]
                                ?.toString()
                                .toLowerCase() ??
                            "";

                    final status =
                        data["status"]
                                ?.toString()
                                .trim() ??
                            "En attente";

                    // ------------------------------------------
                    // FILTRE STATUT
                    // ------------------------------------------

                    final statutOk =
                        _statutSelectionne ==
                                "Tous" ||
                            status ==
                                _statutSelectionne;

                    // ------------------------------------------
                    // FILTRE RECHERCHE
                    // ------------------------------------------

                    final rechercheOk =
                        recherche.isEmpty ||
                            clientName.contains(
                              recherche,
                            ) ||
                            phone.contains(
                              recherche,
                            ) ||
                            serviceName.contains(
                              recherche,
                            );

                    return statutOk &&
                        rechercheOk;
                  },
                ).toList();

                // ==============================================
                // TRI
                // ==============================================

                reservationsFiltrees.sort(
                  (
                    a,
                    b,
                  ) {
                    final dataA =
                        a.data()
                            as Map<String,
                                dynamic>;

                    final dataB =
                        b.data()
                            as Map<String,
                                dynamic>;

                    final dateA =
                        dataA[
                            "reservationDate"];

                    final dateB =
                        dataB[
                            "reservationDate"];

                    if (dateA is Timestamp &&
                        dateB is Timestamp) {
                      return dateB.compareTo(
                        dateA,
                      );
                    }

                    if (dateA is Timestamp &&
                        dateB is! Timestamp) {
                      return -1;
                    }

                    if (dateA is! Timestamp &&
                        dateB is Timestamp) {
                      return 1;
                    }

                    return 0;
                  },
                );

                // ==============================================
                // AUCUN RESULTAT
                // ==============================================

                if (reservationsFiltrees
                    .isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          recherche.isNotEmpty ||
                                  _statutSelectionne !=
                                      "Tous"
                              ? "Aucune réservation ne correspond aux filtres."
                              : "Aucune réservation",
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            color:
                                Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // ==============================================
                // NOMBRE DE RESULTATS
                // ==============================================

                return Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 15,
                        vertical: 4,
                      ),
                      child: Align(
                        alignment:
                            Alignment.centerLeft,
                        child: Text(
                          "${reservationsFiltrees.length} réservation(s)",
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    // ==========================================
                    // LISTE
                    // ==========================================

                    Expanded(
                      child:
                          ListView.builder(
                        padding:
                            const EdgeInsets
                                .only(
                          top: 4,
                          bottom: 20,
                        ),
                        itemCount:
                            reservationsFiltrees
                                .length,
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          return _carteReservation(
                            context,
                            reservationsFiltrees[
                                index],
                            commerceName,
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
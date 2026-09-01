import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/business_item.dart';
import '../../models/reservation.dart';
import '../../repository/reservation_repository.dart';
import '../../services/reservation_firestore_service.dart';

class AddReservationPage extends StatefulWidget {
  final BusinessItem item;
  final String commerceId;

  const AddReservationPage({
    super.key,
    required this.item,
    required this.commerceId,
  });

  @override
  State<AddReservationPage> createState() => _AddReservationPageState();
}

class _AddReservationPageState extends State<AddReservationPage> {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final commentController = TextEditingController();

  // ==========================================================
  // DATE / HEURE
  // ==========================================================

  DateTime? reservationDate;
  TimeOfDay? reservationTime;

  // ==========================================================
  // ENREGISTREMENT AUDIO
  // ==========================================================

  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isRecording = false;
  bool _hasVoiceNote = false;

  String? _voiceNotePath;

  // ==========================================================
  // BASE64 NOTE VOCALE
  // ==========================================================

  String? _voiceNoteBase64;

  String _voiceNoteMimeType = "audio/mp4";

  // ==========================================================
  // LECTURE AUDIO
  // ==========================================================

  bool _isPlaying = false;

  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  // ==========================================================
  // DURÉE ENREGISTREMENT
  // ==========================================================

  Duration _recordDuration = Duration.zero;

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    commentController.dispose();

    _audioRecorder.dispose();
    _audioPlayer.dispose();

    super.dispose();
  }

  // ==========================================================
  // IMAGE SERVICE
  // ==========================================================

  String _obtenirImageService() {
    final image = widget.item.image.trim();

    if (image.isNotEmpty) {
      return image;
    }

    if (widget.item.imageBytes != null &&
        widget.item.imageBytes!.isNotEmpty) {
      try {
        return base64Encode(widget.item.imageBytes!);
      } catch (e) {
        debugPrint("ERREUR CONVERSION IMAGE : $e");
      }
    }

    return "";
  }

  // ==========================================================
  // AFFICHAGE IMAGE
  // ==========================================================

  Widget construireImageService({
    required double height,
  }) {
    String image = _obtenirImageService().trim();

    if (image.isEmpty) {
      return _imageErreur(height);
    }

    // ----------------------------------------------------------
    // IMAGE BYTES
    // ----------------------------------------------------------

    if (widget.item.imageBytes != null &&
        widget.item.imageBytes!.isNotEmpty &&
        widget.item.image.trim().isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.memory(
          widget.item.imageBytes!,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _imageErreur(height);
          },
        ),
      );
    }

    // ----------------------------------------------------------
    // DATA URI
    // ----------------------------------------------------------

    if (image.startsWith("data:image")) {
      try {
        final base64Part = image.split(",").last;
        final bytes = base64Decode(base64Part);

        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.memory(
            bytes,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return _imageErreur(height);
            },
          ),
        );
      } catch (e) {
        debugPrint("ERREUR DATA URI IMAGE : $e");
        return _imageErreur(height);
      }
    }

    // ----------------------------------------------------------
    // BASE64
    // ----------------------------------------------------------

    try {
      final bytes = base64Decode(image);

      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.memory(
          bytes,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _imageErreur(height);
          },
        ),
      );
    } catch (_) {}

    // ----------------------------------------------------------
    // URL
    // ----------------------------------------------------------

    if (image.startsWith("http://") ||
        image.startsWith("https://")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          image,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (
            context,
            child,
            loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }

            return Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (_, __, ___) {
            return _imageErreur(height);
          },
        ),
      );
    }

    return _imageErreur(height);
  }

  // ==========================================================
  // IMAGE ERREUR
  // ==========================================================

  Widget _imageErreur(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 55,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text(
            "Image indisponible",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CHOISIR DATE
  // ==========================================================

  Future<void> choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() {
        reservationDate = date;
      });
    }
  }

  // ==========================================================
  // CHOISIR HEURE
  // ==========================================================

  Future<void> choisirHeure() async {
    final heure = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );

    if (heure != null) {
      setState(() {
        reservationTime = heure;
      });
    }
  }

  // ==========================================================
  // COMMENCER ENREGISTREMENT
  // ==========================================================

  Future<void> commencerEnregistrement() async {
    try {
      await _audioPlayer.stop();

      if (mounted) {
        setState(() {
          _isPlaying = false;
          _audioPosition = Duration.zero;
          _audioDuration = Duration.zero;
        });
      }

      final hasPermission =
          await _audioRecorder.hasPermission();

      if (!hasPermission) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "L'autorisation du microphone est nécessaire.",
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      if (_isRecording) {
        return;
      }

      final directory = Directory.systemTemp;

      final filePath =
          "${directory.path}/reservation_${DateTime.now().millisecondsSinceEpoch}.m4a";

      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 32000,
        sampleRate: 16000,
        numChannels: 1,
      );

      await _audioRecorder.start(
        config,
        path: filePath,
      );

      if (!mounted) return;

      setState(() {
        _isRecording = true;
        _hasVoiceNote = false;
        _voiceNotePath = filePath;
        _voiceNoteBase64 = null;
        _recordDuration = Duration.zero;
        _isPlaying = false;
        _audioPosition = Duration.zero;
        _audioDuration = Duration.zero;
      });
    } catch (e) {
      debugPrint(
        "ERREUR DEMARRAGE AUDIO : $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de démarrer l'enregistrement : $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // ARRETER ENREGISTREMENT
  // ==========================================================

  Future<void> arreterEnregistrement() async {
    try {
      final path = await _audioRecorder.stop();

      if (!mounted) return;

      if (path == null || path.isEmpty) {
        setState(() {
          _isRecording = false;
          _hasVoiceNote = false;
          _voiceNotePath = null;
          _voiceNoteBase64 = null;
        });

        return;
      }

      final file = File(path);

      if (!await file.exists()) {
        setState(() {
          _isRecording = false;
          _hasVoiceNote = false;
          _voiceNotePath = null;
          _voiceNoteBase64 = null;
        });

        return;
      }

      final Uint8List audioBytes =
          await file.readAsBytes();

      if (audioBytes.isEmpty) {
        setState(() {
          _isRecording = false;
          _hasVoiceNote = false;
          _voiceNotePath = null;
          _voiceNoteBase64 = null;
        });

        return;
      }

      final String base64Audio =
          base64Encode(audioBytes);

      const int tailleMaximumBase64 = 700000;

      if (base64Audio.length >
          tailleMaximumBase64) {
        setState(() {
          _isRecording = false;
          _hasVoiceNote = false;
          _voiceNotePath = null;
          _voiceNoteBase64 = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "La note vocale est trop longue. "
              "Veuillez enregistrer un message plus court.",
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      setState(() {
        _isRecording = false;
        _voiceNotePath = path;
        _voiceNoteBase64 = base64Audio;
        _hasVoiceNote = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Note vocale enregistrée. Vous pouvez maintenant l'écouter.",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint(
        "ERREUR ARRET AUDIO : $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors de l'arrêt de l'enregistrement : $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // LIRE NOTE VOCALE
  // ==========================================================

  Future<void> lireNoteVocale() async {
    if (!_hasVoiceNote ||
        _voiceNotePath == null ||
        _voiceNotePath!.isEmpty) {
      return;
    }

    try {
      final file = File(_voiceNotePath!);

      if (!await file.exists()) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Le fichier audio est introuvable.",
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      if (_isPlaying) {
        await _audioPlayer.pause();

        if (!mounted) return;

        setState(() {
          _isPlaying = false;
        });

        return;
      }

      if (_audioDuration != Duration.zero &&
          _audioPosition >= _audioDuration) {
        await _audioPlayer.seek(Duration.zero);

        if (!mounted) return;

        setState(() {
          _audioPosition = Duration.zero;
        });
      }

      await _audioPlayer.play(
        DeviceFileSource(_voiceNotePath!),
      );

      if (!mounted) return;

      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint(
        "ERREUR LECTURE AUDIO : $e",
      );

      if (!mounted) return;

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
  // ARRETER LECTURE
  // ==========================================================

  Future<void> arreterLectureAudio() async {
    try {
      await _audioPlayer.stop();

      if (!mounted) return;

      setState(() {
        _isPlaying = false;
        _audioPosition = Duration.zero;
      });
    } catch (e) {
      debugPrint(
        "ERREUR ARRET LECTURE AUDIO : $e",
      );
    }
  }

  // ==========================================================
  // RECOMMENCER AUDIO
  // ==========================================================

  Future<void> recommencerLectureAudio() async {
    if (!_hasVoiceNote ||
        _voiceNotePath == null ||
        _voiceNotePath!.isEmpty) {
      return;
    }

    try {
      await _audioPlayer.stop();

      await _audioPlayer.play(
        DeviceFileSource(_voiceNotePath!),
      );

      if (!mounted) return;

      setState(() {
        _isPlaying = true;
        _audioPosition = Duration.zero;
      });
    } catch (e) {
      debugPrint(
        "ERREUR RELECTURE AUDIO : $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de relire la note vocale : $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // SUPPRIMER NOTE VOCALE
  // ==========================================================

  Future<void> supprimerNoteVocale() async {
    try {
      await _audioPlayer.stop();

      if (!mounted) return;

      setState(() {
        _hasVoiceNote = false;
        _voiceNotePath = null;
        _voiceNoteBase64 = null;
        _recordDuration = Duration.zero;
        _isPlaying = false;
        _audioPosition = Duration.zero;
        _audioDuration = Duration.zero;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Note vocale supprimée. Vous pouvez en enregistrer une nouvelle.",
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        "ERREUR SUPPRESSION AUDIO : $e",
      );
    }
  }

  // ==========================================================
  // FORMATAGE DUREE
  // ==========================================================

  String formaterDuree(Duration duration) {
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

  Widget construireSectionNoteVocale() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.mic,
                  color: Colors.deepPurple,
                ),
                SizedBox(width: 8),
                Text(
                  "Note vocale",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              "Vous pouvez laisser un message vocal au commerçant.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 15),

            if (_isRecording)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.mic,
                      color: Colors.red,
                      size: 35,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Enregistrement en cours...",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: arreterEnregistrement,
                        icon: const Icon(Icons.stop),
                        label: const Text("Arrêter"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_hasVoiceNote)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.audiotrack,
                          color: Colors.green,
                          size: 35,
                        ),

                        const SizedBox(width: 10),

                        const Expanded(
                          child: Text(
                            "Note vocale enregistrée",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: supprimerNoteVocale,
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          tooltip: "Supprimer",
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: lireNoteVocale,
                            icon: Icon(
                              _isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            label: Text(
                              _isPlaying
                                  ? "Pause"
                                  : "Écouter",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        IconButton(
                          onPressed:
                              recommencerLectureAudio,
                          icon: const Icon(
                            Icons.replay,
                            color: Colors.deepPurple,
                          ),
                          tooltip:
                              "Réécouter depuis le début",
                        ),

                        IconButton(
                          onPressed:
                              arreterLectureAudio,
                          icon: const Icon(
                            Icons.stop,
                            color: Colors.red,
                          ),
                          tooltip: "Arrêter",
                        ),
                      ],
                    ),

                    StreamBuilder<Duration>(
                      stream:
                          _audioPlayer.onPositionChanged,
                      builder: (
                        context,
                        snapshot,
                      ) {
                        final position =
                            snapshot.data ??
                                Duration.zero;

                        if (_audioDuration ==
                            Duration.zero) {
                          return const SizedBox.shrink();
                        }

                        final maxValue =
                            _audioDuration
                                .inMilliseconds
                                .toDouble();

                        final currentValue =
                            position
                                .inMilliseconds
                                .toDouble()
                                .clamp(
                                  0.0,
                                  maxValue,
                                );

                        return Column(
                          children: [
                            Slider(
                              min: 0,
                              max: maxValue > 0
                                  ? maxValue
                                  : 1,
                              value: currentValue,
                              onChanged:
                                  (value) async {
                                await _audioPlayer
                                    .seek(
                                  Duration(
                                    milliseconds:
                                        value.toInt(),
                                  ),
                                );
                              },
                            ),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text(
                                  formaterDuree(
                                    position,
                                  ),
                                  style:
                                      const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  formaterDuree(
                                    _audioDuration,
                                  ),
                                  style:
                                      const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "🎧 Écoutez votre message avant de confirmer.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: commencerEnregistrement,
                  icon: const Icon(Icons.mic),
                  label: const Text(
                    "Enregistrer une note vocale",
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // INITIALISATION AUDIO
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _audioPlayer.onDurationChanged.listen(
      (duration) {
        if (!mounted) return;

        setState(() {
          _audioDuration = duration;
        });
      },
    );

    _audioPlayer.onPositionChanged.listen(
      (position) {
        if (!mounted) return;

        setState(() {
          _audioPosition = position;
        });
      },
    );

    _audioPlayer.onPlayerComplete.listen(
      (_) {
        if (!mounted) return;

        setState(() {
          _isPlaying = false;
          _audioPosition = _audioDuration;
        });
      },
    );
  }

  // ==========================================================
  // PREPARER NOTE VOCALE BASE64
  // ==========================================================

  Future<String?> _preparerNoteVocaleBase64() async {
    if (!_hasVoiceNote ||
        _voiceNotePath == null ||
        _voiceNotePath!.isEmpty) {
      return null;
    }

    try {
      final file = File(_voiceNotePath!);

      if (!await file.exists()) {
        return null;
      }

      final Uint8List audioBytes =
          await file.readAsBytes();

      if (audioBytes.isEmpty) {
        return null;
      }

      final String audioBase64 =
          base64Encode(audioBytes);

      const int tailleMaximumBase64 =
          700000;

      if (audioBase64.length >
          tailleMaximumBase64) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "La note vocale est trop longue. "
                "Veuillez enregistrer un message plus court.",
              ),
              backgroundColor: Colors.red,
            ),
          );
        }

        return null;
      }

      _voiceNoteBase64 = audioBase64;

      return audioBase64;
    } catch (e) {
      debugPrint(
        "ERREUR CONVERSION AUDIO BASE64 : $e",
      );

      return null;
    }
  }

  // ==========================================================
  // ENREGISTRER RESERVATION
  // ==========================================================

  void enregistrerReservation() {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        reservationDate == null ||
        reservationTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs obligatoires.",
          ),
        ),
      );

      return;
    }

    final date = DateTime(
      reservationDate!.year,
      reservationDate!.month,
      reservationDate!.day,
      reservationTime!.hour,
      reservationTime!.minute,
    );

    if (!ReservationRepository.isSlotAvailable(date)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ce créneau est déjà réservé.",
          ),
        ),
      );

      return;
    }

    afficherConfirmation(date);
  }

  // ==========================================================
  // RECUPERER WHATSAPP COMMERÇANT
  // ==========================================================

  Future<String?> _recupererWhatsappCommercant() async {
    try {
      debugPrint(
        "Recherche WhatsApp du commerce : "
        "${widget.commerceId}",
      );

      final commerceDoc =
          await FirebaseFirestore.instance
              .collection("commerces")
              .doc(widget.commerceId)
              .get();

      if (!commerceDoc.exists) {
        debugPrint(
          "COMMERCE INTROUVABLE : "
          "${widget.commerceId}",
        );

        return null;
      }

      final data = commerceDoc.data();

      if (data == null) {
        return null;
      }

      final whatsapp =
          data["whatsapp"]?.toString().trim() ?? "";

      debugPrint(
        "WHATSAPP COMMERÇANT : $whatsapp",
      );

      if (whatsapp.isEmpty) {
        return null;
      }

      return whatsapp;
    } catch (e) {
      debugPrint(
        "ERREUR RECUPERATION WHATSAPP : $e",
      );

      return null;
    }
  }

  // ==========================================================
  // NETTOYER NUMERO WHATSAPP
  // ==========================================================

  String _nettoyerNumeroWhatsapp(String numero) {
    String resultat = numero.trim();

    resultat = resultat.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );

    if (resultat.startsWith("+")) {
      resultat = resultat.substring(1);
    }

    // Côte d'Ivoire :
    // 0700000000 -> 225700000000
    // 0500000000 -> 225500000000
    // 0100000000 -> 225100000000

    if (resultat.startsWith("0")) {
      resultat = "225${resultat.substring(1)}";
    }

    if (resultat.startsWith("225")) {
      return resultat;
    }

    return resultat;
  }

  // ==========================================================
  // ENVOYER MESSAGE WHATSAPP
  // ==========================================================

  Future<void> _envoyerMessageWhatsapp(
    DateTime date,
  ) async {
    try {
      final whatsapp =
          await _recupererWhatsappCommercant();

      if (whatsapp == null ||
          whatsapp.isEmpty) {
        debugPrint(
          "AUCUN NUMERO WHATSAPP COMMERCANT.",
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "La réservation est enregistrée, "
              "mais aucun numéro WhatsApp du commerçant "
              "n'a été trouvé.",
            ),
            backgroundColor: Colors.orange,
          ),
        );

        return;
      }

      final numero =
          _nettoyerNumeroWhatsapp(whatsapp);

      final nom =
          nameController.text.trim();

      final telephone =
          phoneController.text.trim();

      final commentaire =
          commentController.text.trim();

      final dateFormatee =
          "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";

      final heureFormatee =
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";

      String message =
          "Bonjour,\n\n"
          "Je viens d'effectuer une réservation.\n\n"
          "💇 Service : ${widget.item.name}\n"
          "👤 Nom : $nom\n"
          "📞 Téléphone : $telephone\n"
          "📅 Date : $dateFormatee\n"
          "🕒 Heure : $heureFormatee";

      if (commentaire.isNotEmpty) {
        message +=
            "\n💬 Commentaire : $commentaire";
      }

      if (_hasVoiceNote) {
        message +=
            "\n🎤 Une note vocale a également "
            "été jointe à ma réservation.";
      }

      message +=
          "\n\nMerci.";

      final encodedMessage =
          Uri.encodeComponent(message);

      final whatsappUri = Uri.parse(
        "https://wa.me/$numero?text=$encodedMessage",
      );

      debugPrint(
        "OUVERTURE WHATSAPP : $whatsappUri",
      );

      final launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Impossible d'ouvrir WhatsApp.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint(
        "ERREUR WHATSAPP : $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible d'ouvrir WhatsApp : $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // ENREGISTREMENT FINAL FIRESTORE
  // ==========================================================

  Future<void> enregistrerReservationFinale(
    DateTime date,
  ) async {
    try {
      final String imageService =
          _obtenirImageService();

      String? voiceNoteBase64;

      if (_hasVoiceNote) {
        if (!mounted) return;

        await _audioPlayer.stop();

        setState(() {
          _isPlaying = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Préparation de votre note vocale...",
            ),
            duration: Duration(seconds: 2),
          ),
        );

        voiceNoteBase64 =
            await _preparerNoteVocaleBase64();

        if (_hasVoiceNote &&
            (voiceNoteBase64 == null ||
                voiceNoteBase64.isEmpty)) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Impossible de préparer la note vocale.",
              ),
              backgroundColor: Colors.red,
            ),
          );

          return;
        }
      }

      final Map<String, dynamic> reservation = {
        "commerceId": widget.commerceId,

        "clientName":
            nameController.text.trim(),

        "phone":
            phoneController.text.trim(),

        "serviceId":
            widget.item.id,

        "serviceName":
            widget.item.name,

        "serviceImage":
            imageService,

        "serviceImageBase64":
            imageService,

        "reservationDate":
            Timestamp.fromDate(date),

        "comment":
            commentController.text.trim(),

        "status":
            "En attente",

        "createdAt":
            Timestamp.now(),

        "updatedAt":
            Timestamp.now(),

        "hasVoiceNote":
            voiceNoteBase64 != null &&
                voiceNoteBase64.isNotEmpty,

        "voiceNoteBase64":
            voiceNoteBase64,

        "voiceNoteMimeType":
            _voiceNoteMimeType,
      };

      await ReservationFirestoreService
          .ajouterReservation(
        reservation,
      );

      debugPrint(
        "RESERVATION ENREGISTREE AVEC SUCCES.",
      );

      if (!mounted) return;

      // ========================================================
      // DIALOGUE DE CONFIRMATION
      // ========================================================

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Center(
              child: Text(
                "✅",
                style: TextStyle(
                  fontSize: 50,
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Réservation envoyée !",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Votre demande a bien été transmise.",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                if (voiceNoteBase64 != null &&
                    voiceNoteBase64.isNotEmpty)
                  const Text(
                    "🎤 Votre note vocale a également été envoyée.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 10),

                const Text(
                  "Nous vous contacterons rapidement "
                  "pour confirmer votre rendez-vous.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    "Fermer",
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      // ========================================================
      // OUVRIR WHATSAPP APRES ENREGISTREMENT
      // ========================================================

      await _envoyerMessageWhatsapp(date);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      debugPrint(
        "ERREUR ENREGISTREMENT RESERVATION : $e",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors de l'enregistrement : $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // CONFIRMATION
  // ==========================================================

  Future<void> afficherConfirmation(
    DateTime date,
  ) async {
    final validation =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Confirmer votre réservation",
          ),

          content: SizedBox(
            width: 330,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context)
                            .size
                            .height *
                        0.65,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Text(
                      "Merci de vérifier les informations ci-dessous.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: 300,
                      height: 180,
                      child:
                          construireImageService(
                        height: 180,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      "💇 Service : ${widget.item.name}",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "👤 Nom : ${nameController.text.trim()}",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "📞 Téléphone : ${phoneController.text.trim()}",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "📅 Date : "
                      "${date.day.toString().padLeft(2, '0')}/"
                      "${date.month.toString().padLeft(2, '0')}/"
                      "${date.year}",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "🕒 Heure : "
                      "${date.hour.toString().padLeft(2, '0')}:"
                      "${date.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    if (commentController
                        .text
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        "💬 ${commentController.text.trim()}",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],

                    if (_hasVoiceNote) ...[
                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(10),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.green.shade50,
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.mic,
                                  color:
                                      Colors.green,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Note vocale prête à être envoyée.",
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

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Expanded(
                                  child:
                                      ElevatedButton
                                          .icon(
                                    onPressed:
                                        lireNoteVocale,
                                    icon: Icon(
                                      _isPlaying
                                          ? Icons.pause
                                          : Icons
                                              .play_arrow,
                                    ),
                                    label: Text(
                                      _isPlaying
                                          ? "Pause"
                                          : "Écouter",
                                    ),
                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          Colors
                                              .deepPurple,
                                      foregroundColor:
                                          Colors.white,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                IconButton(
                                  onPressed:
                                      recommencerLectureAudio,
                                  icon:
                                      const Icon(
                                    Icons.replay,
                                    color: Colors
                                        .deepPurple,
                                  ),
                                  tooltip:
                                      "Réécouter",
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "🎧 Vérifiez votre note vocale avant de valider.",
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                "Modifier",
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                "Valider",
              ),
            ),
          ],
        );
      },
    );

    if (validation == true) {
      await enregistrerReservationFinale(date);
    }
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
        title: Text(
          widget.item.name,
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ====================================================
          // PHOTO
          // ====================================================

          construireImageService(
            height: 220,
          ),

          const SizedBox(height: 20),

          // ====================================================
          // NOM
          // ====================================================

          TextField(
            controller: nameController,
            decoration:
                const InputDecoration(
              labelText: "Nom du client",
              
              hintText:
                      'Ex : Aboubacar Bamba',

              prefixIcon:
                  Icon(Icons.person),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          // ====================================================
          // TELEPHONE
          // ====================================================

          TextField(
            controller: phoneController,
            keyboardType:
                TextInputType.phone,
            decoration:
                const InputDecoration(
              labelText: "Numéro de téléphone",

              hintText:
                      'Ex : +2250700000000',
              prefixIcon:
                  Icon(Icons.phone),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          // ====================================================
          // DATE
          // ====================================================

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: choisirDate,
              icon: const Icon(
                Icons.calendar_month,
              ),
              label: Text(
                reservationDate == null
                    ? "Choisir une date"
                    : "${reservationDate!.day}/"
                      "${reservationDate!.month}/"
                      "${reservationDate!.year}",
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ====================================================
          // HEURE
          // ====================================================

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: escolherHeureSafe,
              icon: const Icon(
                Icons.access_time,
              ),
              label: Text(
                reservationTime == null
                    ? "Choisir une heure"
                    : "${reservationTime!.hour.toString().padLeft(2, '0')}:"
                      "${reservationTime!.minute.toString().padLeft(2, '0')}",
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ====================================================
          // COMMENTAIRE
          // ====================================================

          TextField(
            controller: commentController,
            maxLines: 3,
            decoration:
                const InputDecoration(
              labelText: "Commentaire",
              prefixIcon:
                  Icon(Icons.comment),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          // ====================================================
          // NOTE VOCALE
          // ====================================================

          construireSectionNoteVocale(),

          const SizedBox(height: 30),

          // ====================================================
          // BOUTON RESERVATION
          // ====================================================

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed:
                  _isRecording
                      ? null
                      : enregistrerReservation,
              icon: const Icon(
                Icons.event_available,
              ),
              label: const Text(
                "Confirmer la réservation",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECURITE POUR LE BOUTON HEURE
  // ==========================================================

  void escolherHeureSafe() {
    choisirHeure();
  }
}
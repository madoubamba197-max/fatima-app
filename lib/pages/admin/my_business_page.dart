import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_storage/application_manager.dart';

class MyBusinessPage extends StatefulWidget {
  const MyBusinessPage({super.key});

  @override
  State<MyBusinessPage> createState() => _MyBusinessPageState();
}

class _MyBusinessPageState extends State<MyBusinessPage> {
  final ImagePicker picker = ImagePicker();

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final telephoneController = TextEditingController();
  final whatsappController = TextEditingController();
  final adresseController = TextEditingController();

  // ==========================================================
  // ETATS
  // ==========================================================

  bool enregistrement = false;

  bool uploadingLogo = false;
  bool uploadingCover = false;
  bool uploadingGallery = false;

  // Permet d'éviter de réinitialiser les champs à chaque
  // mise à jour de Firestore.
  bool champsInitialises = false;

  // ==========================================================
  // INITIALISATION
  // ==========================================================

  @override
  void initState() {
    super.initState();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    telephoneController.dispose();
    whatsappController.dispose();
    adresseController.dispose();

    super.dispose();
  }

  // ==========================================================
  // ENREGISTRER INFORMATIONS
  // ==========================================================

  Future<void> enregistrerInformations() async {
    try {
      final app =
          ApplicationManager.getCurrentApplication();

      if (app == null) {
        return;
      }

      setState(() {
        enregistrement = true;
      });

      await FirebaseFirestore.instance
          .collection("commerces")
          .doc(app.commerceId)
          .update({
        "phone": telephoneController.text.trim(),
        "whatsapp": whatsappController.text.trim(),
        "address": adresseController.text.trim(),
      });

      if (!mounted) return;

      setState(() {
        enregistrement = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Informations enregistrées avec succès.",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        enregistrement = false;
      });

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
  // LOGO
  // ==========================================================

  Future<void> choisirLogo() async {
  try {
    final app =
        ApplicationManager.getCurrentApplication();

    if (app == null) return;

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 45,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image == null) return;

    setState(() {
      uploadingLogo = true;
    });

    final Uint8List bytes =
        await image.readAsBytes();

    final imageBase64 =
        base64Encode(bytes);

    await FirebaseFirestore.instance
        .collection("commerces")
        .doc(app.commerceId)
        .update({
      "logo": imageBase64,
    });

    if (!mounted) return;

    setState(() {
      uploadingLogo = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Logo enregistré avec succès.",
        ),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    setState(() {
      uploadingLogo = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Erreur lors de l'enregistrement du logo : $e",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  // ==========================================================
  // COUVERTURE
  // ==========================================================

  Future<void> choisirCouverture() async {
  try {
    final app =
        ApplicationManager.getCurrentApplication();

    if (app == null) return;

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 45,
      maxWidth: 1200,
      maxHeight: 800,
    );

    if (image == null) return;

    setState(() {
      uploadingCover = true;
    });

    final Uint8List bytes =
        await image.readAsBytes();

    final imageBase64 =
        base64Encode(bytes);

    await FirebaseFirestore.instance
        .collection("commerces")
        .doc(app.commerceId)
        .update({
      "coverImage": imageBase64,
    });

    if (!mounted) return;

    setState(() {
      uploadingCover = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Photo de couverture enregistrée.",
        ),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    setState(() {
      uploadingCover = false;
    });

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
  // AJOUT GALERIE
  // ==========================================================

  Future<void> ajouterPhotoGalerie() async {
  try {
    final app =
        ApplicationManager.getCurrentApplication();

    if (app == null) return;

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 45,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image == null) return;

    setState(() {
      uploadingGallery = true;
    });

    final Uint8List bytes =
        await image.readAsBytes();

    final imageBase64 =
        base64Encode(bytes);

    await FirebaseFirestore.instance
        .collection("commerces")
        .doc(app.commerceId)
        .update({
      "gallery": FieldValue.arrayUnion([
        imageBase64,
      ]),
    });

    if (!mounted) return;

    setState(() {
      uploadingGallery = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Photo ajoutée à la galerie.",
        ),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    setState(() {
      uploadingGallery = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Erreur lors de l'ajout : $e",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  // ==========================================================
  // SUPPRESSION GALERIE
  // ==========================================================

  Future<void> supprimerPhotoGalerie(
  String imageBase64,
) async {
  try {
    final app =
        ApplicationManager.getCurrentApplication();

    if (app == null) return;

    final confirmation =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Supprimer la photo ?",
          ),
          content: const Text(
            "Cette photo sera supprimée de votre galerie.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );

    if (confirmation != true) {
      return;
    }

    await FirebaseFirestore.instance
        .collection("commerces")
        .doc(app.commerceId)
        .update({
      "gallery": FieldValue.arrayRemove([
        imageBase64,
      ]),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Photo supprimée.",
        ),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Erreur lors de la suppression : $e",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  // ==========================================================
  // AFFICHER IMAGE BASE64
  // ==========================================================

  Widget afficherImageBase64(String image) {
    try {
      final bytes = base64Decode(image);

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return const Icon(
        Icons.broken_image,
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final app =
        ApplicationManager.getCurrentApplication();

    if (app == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Commerce introuvable",
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("commerces")
          .doc(app.commerceId)
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Mon commerce"),
            ),
            body: Center(
              child: Text(
                "Erreur : ${snapshot.error}",
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Commerce introuvable.",
              ),
            ),
          );
        }

        final data =
            snapshot.data!.data()
                as Map<String, dynamic>;

        final String logo =
            data["logo"]?.toString() ?? "";

        final String coverImage =
            data["coverImage"]?.toString() ?? "";

        final List<String> gallery =
            data["gallery"] is List
                ? List<String>.from(
                    data["gallery"].map(
                      (e) => e.toString(),
                    ),
                  )
                : [];

        // ======================================================
        // INITIALISER LES CHAMPS UNE SEULE FOIS
        // ======================================================

        if (!champsInitialises) {
          telephoneController.text =
              data["phone"]?.toString() ?? "";

          whatsappController.text =
              data["whatsapp"]?.toString() ?? "";

          adresseController.text =
              data["address"]?.toString() ?? "";

          champsInitialises = true;
        }

        // ======================================================
        // AFFICHAGE
        // ======================================================

        return Scaffold(
          appBar: AppBar(
            title: const Text("Mon commerce"),
          ),

          body: ListView(
            padding: const EdgeInsets.all(20),

            children: [

              // =================================================
              // LOGO
              // =================================================

              const Text(
                "Logo",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [

                    CircleAvatar(
  radius: 60,
  backgroundColor: Colors.grey.shade300,

  child: logo.isNotEmpty
      ? ClipOval(
          child: SizedBox(
            width: 120,
            height: 120,
            child: afficherImageBase64(logo),
          ),
        )
      : const Icon(
          Icons.store,
          size: 60,
        ),
),

                    GestureDetector(
                      onTap: uploadingLogo
                          ? null
                          : choisirLogo,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            Colors.orange,
                        child: uploadingLogo
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // COUVERTURE
              // =================================================

              const Text(
                "Photo de couverture",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 10),

              Stack(
                alignment: Alignment.bottomRight,
                children: [

                  Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: coverImage.isNotEmpty
    ? ClipRRect(
        borderRadius:
            BorderRadius.circular(15),
        child: SizedBox(
          width: double.infinity,
          height: 170,
          child: afficherImageBase64(
            coverImage,
          ),
        ),
      )
    : const Center(
        child: Icon(
          Icons.image,
          size: 60,
        ),
      ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: uploadingCover
                          ? null
                          : choisirCouverture,
                      child: CircleAvatar(
                        backgroundColor:
                            Colors.orange,
                        child: uploadingCover
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // =================================================
              // GALERIE
              // =================================================

              const Text(
                "Galerie",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection:
                      Axis.horizontal,
                  itemCount:
                      gallery.length + 1,
                  itemBuilder:
                      (context, index) {

                    if (index == gallery.length) {
                      return GestureDetector(
                        onTap: uploadingGallery
                            ? null
                            : ajouterPhotoGalerie,
                        child: Container(
                          width: 100,
                          margin:
                              const EdgeInsets.only(
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(15),
                            color:
                                Colors.orange.shade100,
                          ),
                          child: uploadingGallery
                              ? const Center(
                                  child:
                                      CircularProgressIndicator(),
                                )
                              : const Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                ),
                        ),
                      );
                    }

                    final image = gallery[index];

                    return GestureDetector(
                      onLongPress: () {
                        supprimerPhotoGalerie(image);
                      },
                      child: Container(
                        width: 100,
                        margin:
                            const EdgeInsets.only(
                          right: 10,
                        ),
                        child: ClipRRect(
  borderRadius:
      BorderRadius.circular(15),
  child: afficherImageBase64(image),
),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // TELEPHONE
              // =================================================

              TextField(
                controller: telephoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Téléphone",
                  prefixIcon:
                      Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // =================================================
              // WHATSAPP
              // =================================================

              TextField(
                controller: whatsappController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "WhatsApp",
                  prefixIcon:
                      Icon(Icons.message),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              // =================================================
              // ADRESSE
              // =================================================

              TextField(
                controller: adresseController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Adresse",
                  prefixIcon:
                      Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              // =================================================
              // BOUTON ENREGISTRER
              // =================================================

              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: enregistrement
                      ? null
                      : enregistrerInformations,

                  icon: enregistrement
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.save,
                        ),

                  label: Text(
                    enregistrement
                        ? "Enregistrement..."
                        : "Enregistrer",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
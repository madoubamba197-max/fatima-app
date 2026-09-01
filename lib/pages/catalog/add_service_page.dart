import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_storage/application_manager.dart';

class AddServicePage extends StatefulWidget {
  final String? commerceId;
  final String? serviceId;
  final Map<String, dynamic>? serviceData;

  const AddServicePage({
    super.key,
    this.commerceId,
    this.serviceId,
    this.serviceData,
  });

  bool get isModification =>
      serviceId != null && serviceData != null;

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();
  final durationController = TextEditingController();

  Uint8List? selectedImageBytes;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.isModification) {
      final data = widget.serviceData!;

      nameController.text =
          data["name"]?.toString() ?? "";

      descriptionController.text =
          data["description"]?.toString() ?? "";

      priceController.text =
          data["price"]?.toString() ?? "";

      categoryController.text =
          data["category"]?.toString() ?? "";

      durationController.text =
          data["duration"]?.toString() ?? "";
    }
  }

  // ============================================================
  // CHOISIR UNE PHOTO
  // ============================================================

  Future<void> choisirImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,

      // Compression pour limiter la taille du document Firestore
      imageQuality: 45,

      // Réduit également les dimensions de la photo
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();

    setState(() {
      selectedImageBytes = bytes;
    });
  }

  // ============================================================
  // ENREGISTREMENT
  // ============================================================

  Future<void> enregistrerService() async {
    final app =
        ApplicationManager.getCurrentApplication();

    if (app == null) {
      return;
    }

    // ==========================================================
    // VALIDATION
    // ==========================================================

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez saisir le nom du service.",
          ),
        ),
      );

      return;
    }

    final prix =
        int.tryParse(priceController.text) ?? 0;

    final duree =
        int.tryParse(durationController.text) ?? 0;

    try {
      // ========================================================
      // IMAGE
      // ========================================================

      String imageBase64 =
          widget.serviceData?["image"]?.toString() ?? "";

      // Si une nouvelle photo est choisie
      if (selectedImageBytes != null) {
        imageBase64 =
            base64Encode(selectedImageBytes!);
      }

      // ========================================================
      // MODIFICATION
      // ========================================================

      if (widget.isModification) {
        await FirebaseFirestore.instance
            .collection("commerces")
            .doc(app.commerceId)
            .collection("services")
            .doc(widget.serviceId)
            .update({
          "name": nameController.text.trim(),
          "description":
              descriptionController.text.trim(),
          "price": prix,
          "category":
              categoryController.text.trim(),
          "duration": duree,
          "image": imageBase64,
          "updatedAt": Timestamp.now(),
        });

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Service modifié avec succès.",
            ),
          ),
        );

        Navigator.pop(context);

        return;
      }

      // ========================================================
      // CREATION
      // ========================================================

      if (selectedImageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Veuillez choisir une photo.",
            ),
          ),
        );

        return;
      }

      await FirebaseFirestore.instance
          .collection("commerces")
          .doc(app.commerceId)
          .collection("services")
          .add({
        "name": nameController.text.trim(),
        "description":
            descriptionController.text.trim(),
        "price": prix,
        "category":
            categoryController.text.trim(),
        "duration": duree,
        "image": imageBase64,
        "createdAt": Timestamp.now(),
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Service et photo enregistrés avec succès.",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors de l'enregistrement : $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // AFFICHAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final modification =
        widget.isModification;

    final imageExistante =
        widget.serviceData?["image"]?.toString() ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          modification
              ? "Modifier le service"
              : "Ajouter un service",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(
          children: [
            TextField(
              controller: nameController,

              decoration: const InputDecoration(
                labelText: "Nom",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  descriptionController,

              maxLines: 2,

              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: priceController,

              keyboardType:
                  TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Prix",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  categoryController,

              decoration: const InputDecoration(
                labelText: "Catégorie",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  durationController,

              keyboardType:
                  TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Durée (minutes)",
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // PHOTO
            // ==================================================

            GestureDetector(
              onTap: choisirImage,

              child: Container(
                height: 180,

                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),

                  borderRadius:
                      BorderRadius.circular(12),
                ),

                child:
                    selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),

                            child: Image.memory(
                              selectedImageBytes!,
                              fit: BoxFit.cover,
                              width:
                                  double.infinity,
                            ),
                          )
                        : modification &&
                                imageExistante
                                    .isNotEmpty
                            ? _afficherImageExistante(
                                imageExistante,
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,

                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 50,
                                    ),

                                    SizedBox(
                                      height: 10,
                                    ),

                                    Text(
                                      "Choisir une photo",
                                    ),
                                  ],
                                ),
                              ),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // BOUTON
            // ==================================================

            SizedBox(
              height: 50,

              child: ElevatedButton(
                onPressed:
                    enregistrerService,

                child: Text(
                  modification
                      ? "Mettre à jour"
                      : "Enregistrer",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AFFICHER IMAGE BASE64
  // ============================================================

  Widget _afficherImageExistante(
    String image,
  ) {
    try {
      final bytes =
          base64Decode(image);

      return ClipRRect(
        borderRadius:
            BorderRadius.circular(12),

        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } catch (e) {
      return const Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.grey,
            ),

            SizedBox(height: 10),

            Text(
              "Image indisponible",
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    categoryController.dispose();
    durationController.dispose();

    super.dispose();
  }
}
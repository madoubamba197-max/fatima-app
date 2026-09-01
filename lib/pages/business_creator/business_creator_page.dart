import 'package:flutter/material.dart';
import '../../models/business_creation.dart';
import '../../core/app_builder/app_builder.dart';

class BusinessCreatorPage extends StatefulWidget {
  const BusinessCreatorPage({super.key});

  @override
  State<BusinessCreatorPage> createState() =>
      _BusinessCreatorPageState();
}

class _BusinessCreatorPageState
    extends State<BusinessCreatorPage> {

  final nameController = TextEditingController();
  final sloganController = TextEditingController();
  final phoneController = TextEditingController();
  final whatsappController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Créer une entreprise"),
      ),

      body: ListView(

        padding: const EdgeInsets.all(20),

        children: [

          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Nom de l'entreprise",
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: sloganController,
            decoration: const InputDecoration(
              labelText: "Slogan",
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: "Téléphone",
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: whatsappController,
            decoration: const InputDecoration(
              labelText: "WhatsApp",
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: "Adresse",
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(

            onPressed: () {

  final business = BusinessCreation(

    name: nameController.text,

    slogan: sloganController.text,

    phone: phoneController.text,

    whatsapp: whatsappController.text,

    address: addressController.text,

    currency: "FCFA",

    color: Colors.purple,

  );


  AppBuilder.createBusiness(
    business,
  );


  ScaffoldMessenger.of(context).showSnackBar(

    const SnackBar(
      content: Text(
        "Entreprise créée avec succès",
      ),
    ),

  );

},

            child: const Text(
              "Continuer",
            ),

          )

        ],

      ),

    );

  }

}
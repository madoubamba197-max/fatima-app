import 'package:flutter/material.dart';

import '../../config/business_type.dart';
import '../../models/business_creation.dart';
import '../../models/business_modules.dart';
import '../../core/app_builder/app_builder.dart';
import '../../core/generator/app_generator.dart';
import '../../models/created_application.dart';
import '../../core/app_storage/application_manager.dart';
import '../../core/catalog/default_catalog.dart';
import '../../core/app_storage/commerce_id_generator.dart';
import '../../models/commerce.dart';
import '../../core/app_storage/commerce_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppCreatorPage extends StatefulWidget {

  final CreatedApplication? application;

  const AppCreatorPage({
    super.key,
    this.application,
  });

  @override
  State<AppCreatorPage> createState() =>
      _AppCreatorPageState();
}



class _AppCreatorPageState
    extends State<AppCreatorPage> {


  BusinessType selectedType =
      BusinessType.restaurant;


  final nameController =
      TextEditingController();


  final sloganController =
      TextEditingController();


  final phoneController =
      TextEditingController();


  final whatsappController =
      TextEditingController();


  final addressController =
      TextEditingController();

  final proprietaireController = TextEditingController();

  final villeController = TextEditingController();

  final adminController =
    TextEditingController();

  final passwordController =
    TextEditingController();



  Color selectedColor =
      Colors.orange;

  void chargerSloganParDefaut(BusinessType type) {
  switch (type) {
    case BusinessType.restaurant:
      sloganController.text = "Des saveurs qui rassemblent";
      break;

    case BusinessType.salon:
      sloganController.text = "Votre beauté, notre passion";
      break;

    case BusinessType.hotel:
      sloganController.text = "Votre confort avant tout";
      break;

    case BusinessType.garage:
      sloganController.text = "Votre véhicule entre de bonnes mains";
      break;

    case BusinessType.boutique:
      sloganController.text = "Votre boutique de confiance";
      break;

    case BusinessType.pharmacie:
      sloganController.text = "Votre santé, notre priorité";
      break;

    case BusinessType.cabinetMedical:
      sloganController.text = "Votre santé entre de bonnes mains";
      break;

    case BusinessType.supermarche:
      sloganController.text = "Tout près de vous, chaque jour";
      break;

    case BusinessType.ecole:
      sloganController.text = "Former aujourd'hui, réussir demain";
      break;

    case BusinessType.autre:
      sloganController.text = "";
      break;
  }
}

  @override
void initState() {

  super.initState();


  if (widget.application != null) {

    final app = widget.application!;


    selectedType = app.type;


    nameController.text = app.name;

    sloganController.text = app.slogan;

    phoneController.text = app.phone;

    whatsappController.text = app.whatsapp;

    addressController.text = app.address;

    proprietaireController.text = app.proprietaire;

    villeController.text = app.ville;

    adminController.text = app.adminUsername;

    passwordController.text = app.adminPassword;


  } else {

    chargerSloganParDefaut(selectedType);

  }

}

  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "Créer une application",
        ),

      ),



      body: ListView(


        padding: const EdgeInsets.all(20),


        children: [


          DropdownButtonFormField<BusinessType>(


            value: selectedType,


            decoration: const InputDecoration(

              labelText: "Type de commerce",

            ),


            items: BusinessType.values.map((type){


              return DropdownMenuItem(


                value: type,


                child: Text(
                  type.name,
                ),


              );


            }).toList(),



            onChanged: (value) {
  setState(() {
    selectedType = value!;
    chargerSloganParDefaut(value);
  });
},


          ),



          const SizedBox(height:20),



          TextField(

            controller: nameController,

            decoration: const InputDecoration(

              labelText: "Nom de l'entreprise",

            ),

          ),



          const SizedBox(height:15),



          TextField(

            controller: sloganController,

            decoration: const InputDecoration(

              labelText: "Slogan",

            ),

          ),



          const SizedBox(height:15),



          TextField(

            controller: phoneController,

            decoration: const InputDecoration(

              labelText: "Téléphone",

            ),

          ),



          const SizedBox(height:15),



          TextField(

            controller: whatsappController,

            decoration: const InputDecoration(

              labelText: "WhatsApp",

            ),

          ),



          const SizedBox(height:15),



          TextField(

            controller: addressController,

            decoration: const InputDecoration(

              labelText: "Adresse",

            ),

          ),


          const SizedBox(height: 15),

TextField(
  controller: proprietaireController,
  decoration: const InputDecoration(
    labelText: "Nom du propriétaire",
  ),
),

const SizedBox(height: 15),

TextField(
  controller: villeController,
  decoration: const InputDecoration(
    labelText: "Ville",
  ),
),

          const SizedBox(height: 15),

TextField(

  controller: adminController,

  decoration: const InputDecoration(

    labelText: "Identifiant administrateur",

  ),

),

const SizedBox(height: 15),

TextField(

  controller: passwordController,

  obscureText: true,

  decoration: const InputDecoration(

    labelText: "Mot de passe administrateur",

  ),

),



          const SizedBox(height:30),



          ElevatedButton(


            onPressed: () async {


              final business =
              BusinessCreation(


                name: nameController.text,


                slogan: sloganController.text,


                phone: phoneController.text,


                whatsapp: whatsappController.text,


                address: addressController.text,


                currency: "FCFA",


                color: selectedColor,


                modules:
                const BusinessModules(

                  booking: true,

                  gallery: true,

                  whatsapp: true,

                  location: true,

                  admin: true,

                ),


              );



              AppGenerator.generate(
                business,
              );

              if (widget.application == null) {


  // MODE CREATION

  ApplicationManager.addApplication(

  CreatedApplication(

    commerceId:
CommerceIdGenerator.generate(selectedType),

    name: business.name,

    slogan: business.slogan,

    proprietaire: proprietaireController.text,

    phone: business.phone,

    whatsapp: business.whatsapp,

    ville: villeController.text,

    address: business.address,

    verified: false,

    online: true,

    rating: 0,

    reviews: 0,

    logo: "",

    coverImage: "",

    gallery: [],

    latitude: 0,

    longitude: 0,

    type: selectedType,

    createdAt: DateTime.now(),

    items: DefaultCatalog.get(selectedType),

    adminUsername: adminController.text,

    adminPassword: passwordController.text,

    abonnementActif: true,

    expirationAbonnement:
        DateTime.now().add(
      const Duration(days: 30),
    ),

  ),

);


await FirebaseFirestore.instance
    .collection("commerces")
    .add({

  "name": business.name,
  "slogan": business.slogan,
  "proprietaire": proprietaireController.text,
  "phone": business.phone,
  "whatsapp": business.whatsapp,
  "ville": villeController.text,
  "address": business.address,
  "type": selectedType.name,

  "online": true,
  "abonnementActif": true,

  "rating": 0.0,
  "reviews": 0,

  "adminUsername": adminController.text,
  "adminPassword": passwordController.text,

  "createdAt": Timestamp.now(),

});


} else {

  // ==============================
  // MODE MODIFICATION
  // ==============================

  final app = widget.application!;

  // Mise à jour de l'objet local
  app.name = business.name;
  app.slogan = business.slogan;
  app.phone = business.phone;
  app.whatsapp = business.whatsapp;
  app.address = business.address;
  app.proprietaire = proprietaireController.text;
  app.ville = villeController.text;
  app.type = selectedType;
  app.adminUsername = adminController.text;
  app.adminPassword = passwordController.text;

  // ==============================
  // MISE À JOUR FIRESTORE
  // ==============================

  await FirebaseFirestore.instance
      .collection("commerces")
      .doc(app.commerceId)
      .update({

    "name": business.name,
    "slogan": business.slogan,
    "proprietaire":
        proprietaireController.text,
    "phone": business.phone,
    "whatsapp": business.whatsapp,
    "ville": villeController.text,
    "address": business.address,
    "type": selectedType.name,

    "adminUsername":
        adminController.text,

    "adminPassword":
        passwordController.text,

  });

}

              if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      widget.application == null
          ? "Application créée avec succès"
          : "Application modifiée avec succès",
    ),
  ),
);

            },


           child: Text(

  widget.application == null
      ? "Créer l'application"
      : "Mettre à jour l'application",

),


          ),


        ],


      ),


    );


  }

  @override
void dispose() {

  nameController.dispose();

  sloganController.dispose();

  phoneController.dispose();

  whatsappController.dispose();

  addressController.dispose();

  adminController.dispose();

  passwordController.dispose();

  super.dispose();

}

}
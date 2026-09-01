import 'package:flutter/material.dart';

import '../models/business_profile.dart';


class BusinessProfiles {


  static const BusinessProfile restaurant = BusinessProfile(

    name: "Restaurant Tanoh",

    slogan: "Le goût de la tradition",

    phone: "+225 XX XX XX XX",

    whatsapp: "225XXXXXXXXX",

    address: "San Pedro",

    logo: "assets/images/restaurant.png",

    color: Colors.orange,

    currency: "FCFA",

  );



  static const BusinessProfile salon = BusinessProfile(

    name: "Fatima Beauty",

    slogan: "Votre beauté, notre passion",

    phone: "+225 XX XX XX XX",

    whatsapp: "225XXXXXXXXX",

    address: "Côte d'Ivoire",

    logo: "assets/images/salon.png",

    color: Colors.purple,

    currency: "FCFA",

  );



  static const BusinessProfile hotel = BusinessProfile(

    name: "Hôtel Bellevue",

    slogan: "Votre confort avant tout",

    phone: "+225 XX XX XX XX",

    whatsapp: "225XXXXXXXXX",

    address: "Abidjan",

    logo: "assets/images/hotel.png",

    color: Colors.blue,

    currency: "FCFA",

  );



  static const BusinessProfile garage = BusinessProfile(

    name: "Auto Plus Garage",

    slogan: "Votre véhicule entre de bonnes mains",

    phone: "+225 XX XX XX XX",

    whatsapp: "225XXXXXXXXX",

    address: "San Pedro",

    logo: "assets/images/garage.png",

    color: Colors.red,

    currency: "FCFA",

  );


  static BusinessProfile boutique = BusinessProfile(
  name: "Ma Boutique",
  slogan: "Vos produits au meilleur prix",
  phone: "",
  whatsapp: "",
  address: "",
  logo: "",
  color: Colors.purple,
  currency: "FCFA",
);


}
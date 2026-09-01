import 'package:flutter/material.dart';

import '../models/business_creation.dart';
import '../models/business_modules.dart';
import 'business_type.dart';


class BusinessPresets {


  static BusinessCreation salon() {

    return BusinessCreation(

      name: "Mon Salon",

      slogan: "La beauté avant tout",

      phone: "+225000000000",

      whatsapp: "225000000000",

      address: "Votre adresse",

      currency: "FCFA",

      color: Colors.purple,


      modules: const BusinessModules(

        booking: true,

        gallery: true,

        whatsapp: true,

        location: true,

        payment: false,

        admin: true,

      ),

    );

  }



  static BusinessCreation restaurant() {

    return BusinessCreation(

      name: "Mon Restaurant",

      slogan: "Les meilleurs plats",

      phone: "+225000000000",

      whatsapp: "225000000000",

      address: "Votre adresse",

      currency: "FCFA",

      color: Colors.orange,


      modules: const BusinessModules(

        booking: false,

        gallery: true,

        whatsapp: true,

        location: true,

        payment: true,

        admin: true,

      ),

    );

  }



  static BusinessCreation hotel() {

    return BusinessCreation(

      name: "Mon Hôtel",

      slogan: "Votre confort",

      phone: "+225000000000",

      whatsapp: "225000000000",

      address: "Votre adresse",

      currency: "FCFA",

      color: Colors.blue,


      modules: const BusinessModules(

        booking: true,

        gallery: true,

        whatsapp: true,

        location: true,

        payment: true,

        admin: true,

      ),

    );

  }


}
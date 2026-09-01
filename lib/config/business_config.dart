import 'package:flutter/material.dart';

import 'business_type.dart';
import 'business_manager.dart';
import 'business_profiles.dart';
import '../models/business_profile.dart';


class BusinessConfig {


  // Type actuel sélectionné

  static BusinessType get type {

    return BusinessManager.currentType;

  }



  // Profil actif

  static BusinessProfile get profile {


    switch(type) {


      case BusinessType.restaurant:

        return BusinessProfiles.restaurant;


      case BusinessType.salon:

        return BusinessProfiles.salon;


      case BusinessType.hotel:

        return BusinessProfiles.hotel;


      case BusinessType.garage:

        return BusinessProfiles.garage;


      case BusinessType.boutique:
        return BusinessProfiles.restaurant;


      default:

        return BusinessProfiles.restaurant;


    }


  }



  // Informations dynamiques


  static String get name {

    return profile.name;

  }


  static String get slogan {

    return profile.slogan;

  }


  static String get phone {

    return profile.phone;

  }


  static String get whatsapp {

    return profile.whatsapp;

  }


  static String get address {

    return profile.address;

  }


  static String get logo {

    return profile.logo;

  }


  static Color get primaryColor {

    return profile.color;

  }


  static String get currency {

    return profile.currency;

  }


  static Color get backgroundColor {

  return Colors.grey.shade100;

}



  // Modules


  static const bool enableBooking = true;

  static const bool enableGallery = true;

  static const bool enablePayment = true;

  static const bool enableWhatsapp = true;

  static const bool enableLocation = true;

  static const bool enableAdmin = true;


}
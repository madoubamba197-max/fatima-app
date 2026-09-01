import 'package:flutter/material.dart';

import '../config/business_config.dart';
import '../config/business_type.dart';

import '../modules/restaurant/pages/restaurant_home_page.dart';
import '../modules/restaurant/navigation/restaurant_navigation.dart';
import '../modules/salon/navigation/salon_navigation.dart';

class ModuleLoader {

  static Widget getHomePage() {

    switch (BusinessConfig.type) {

      case BusinessType.restaurant:
        return const RestaurantNavigation();

      case BusinessType.salon:
  return const SalonNavigation();

      case BusinessType.hotel:
        return const Center(
          child: Text("Accueil Hôtel"),
        );

      case BusinessType.garage:
        return const Center(
          child: Text("Accueil Garage"),
        );

      case BusinessType.boutique:
        return const Center(
          child: Text("Accueil Boutique"),
        );

      default:
        return const Center(
          child: Text("Business inconnu"),
        );

    }

  }

}
import 'package:flutter/material.dart';

import '../../models/business_creation.dart';

class AppBuilder {

  static BusinessCreation? currentBusiness;

  static void createBusiness(
    BusinessCreation business,
  ) {

    currentBusiness = business;

  }

  static bool get isConfigured {

    return currentBusiness != null;

  }

}
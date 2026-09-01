import '../../models/business_creation.dart';
import '../app_builder/app_builder.dart';

class AppGenerator {


  static void generate(
    BusinessCreation business,
  ) {


    // Enregistre la configuration du client

    AppBuilder.createBusiness(
      business,
    );


    print(
      "Application générée pour : ${business.name}",
    );


  }


}
import 'package:flutter/material.dart';

import '../../config/business_manager.dart';
import '../../config/business_type.dart';
import '../navigation/main_navigation.dart';
import '../../config/business_presets.dart';
import '../../core/app_builder/app_builder.dart';

class BusinessSelectorPage extends StatelessWidget {
  const BusinessSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Template"),
      ),

      body: ListView(

        padding: const EdgeInsets.all(20),

        children: [

          _businessTile(
            context,
            "🍽 Restaurant",
            BusinessType.restaurant,
          ),

          _businessTile(
            context,
            "💇 Salon",
            BusinessType.salon,
          ),

          _businessTile(
            context,
            "🏨 Hôtel",
            BusinessType.hotel,
          ),

          _businessTile(
            context,
            "🔧 Garage",
            BusinessType.garage,
          ),

          _businessTile(
            context,
            "🛒 Boutique",
            BusinessType.boutique,
          ),

        ],

      ),
    );
  }

  Widget _businessTile(
      BuildContext context,
      String title,
      BusinessType type,
      ) {

    return Card(

      margin: const EdgeInsets.only(bottom: 15),

      child: ListTile(

        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        trailing: const Icon(Icons.arrow_forward_ios),

     onTap: () {

  BusinessManager.changeBusiness(type);


  switch(type) {


    case BusinessType.salon:

      AppBuilder.createBusiness(
        BusinessPresets.salon(),
      );

      break;


    case BusinessType.restaurant:

      AppBuilder.createBusiness(
        BusinessPresets.restaurant(),
      );

      break;


    case BusinessType.hotel:

      AppBuilder.createBusiness(
        BusinessPresets.hotel(),
      );

      break;


    default:

      break;

  }



  Navigator.pushReplacement(
    context,

    MaterialPageRoute(
      builder: (_) => const MainNavigation(),
    ),

  );


},

      ),

    );

  }

}
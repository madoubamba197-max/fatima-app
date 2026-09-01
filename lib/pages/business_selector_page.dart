import 'package:flutter/material.dart';

import '../config/business_type.dart';
import '../config/business_config.dart';
import 'business_home_page.dart';
import '../config/business_manager.dart';

class BusinessSelectorPage extends StatelessWidget {

  const BusinessSelectorPage({super.key});


  @override
  Widget build(BuildContext context) {


    final List<Map<String, dynamic>> businesses = [

      {
        "type": BusinessType.restaurant,
        "name": "Restaurant",
        "icon": Icons.restaurant,
      },

      {
        "type": BusinessType.salon,
        "name": "Salon de beauté",
        "icon": Icons.content_cut,
      },

      {
        "type": BusinessType.hotel,
        "name": "Hôtel",
        "icon": Icons.hotel,
      },

      {
        "type": BusinessType.garage,
        "name": "Garage",
        "icon": Icons.car_repair,
      },

      {
        "type": BusinessType.boutique,
        "name": "Boutique",
        "icon": Icons.shopping_bag,
      },

    ];


    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Choisir un business",
        ),

      ),


      body: ListView.builder(

        padding: const EdgeInsets.all(20),

        itemCount: businesses.length,


        itemBuilder: (context,index){


          final business = businesses[index];


          return Card(

            child: ListTile(

              leading: Icon(
                business["icon"],
                size: 35,
                color: BusinessConfig.primaryColor,
              ),


              title: Text(
                business["name"],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),


              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),


             onTap: () {

  BusinessManager.changeBusiness(
      business["type"]
  );


  Navigator.push(


    context,

    MaterialPageRoute(

      builder: (_) =>
      const BusinessHomePage(),

    ),

  );

},

            ),

          );


        },

      ),

    );


  }

}
import 'package:flutter/material.dart';

import '../models/business_item.dart';
import '../config/business_config.dart';
import '../config/business_type.dart';


class BusinessDetailPage extends StatelessWidget {


  final BusinessItem item;


  const BusinessDetailPage({

    super.key,

    required this.item,

  });



  String get actionText {


    switch(BusinessConfig.type){


      case BusinessType.restaurant:

        return "Commander";


      case BusinessType.salon:

        return "Prendre rendez-vous";


      case BusinessType.hotel:

        return "Réserver une chambre";


      case BusinessType.garage:

        return "Réserver intervention";


      default:

        return "Continuer";

    }

  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title: Text(item.name),

        backgroundColor: BusinessConfig.primaryColor,

        foregroundColor: Colors.white,

      ),



      body: Padding(

        padding: const EdgeInsets.all(20),


        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,


          children: [


            Container(

              height: 220,

              width: double.infinity,

              color: Colors.grey.shade300,


              child: const Icon(

                Icons.image,

                size: 80,

              ),

            ),



            const SizedBox(height:20),



            Text(

              item.name,

              style: const TextStyle(

                fontSize:28,

                fontWeight: FontWeight.bold,

              ),

            ),



            const SizedBox(height:10),



            Text(

              item.description,

              style: const TextStyle(

                fontSize:18,

              ),

            ),



            const SizedBox(height:20),



            Text(

              "Catégorie : ${item.category}",

              style: const TextStyle(

                fontSize:16,

              ),

            ),



            const SizedBox(height:10),



            Text(

              "Prix : ${item.price} ${BusinessConfig.currency}",

              style: const TextStyle(

                fontSize:20,

                fontWeight: FontWeight.bold,

              ),

            ),



            const Spacer(),



            SizedBox(

              width:double.infinity,


              child: ElevatedButton(


                style: ElevatedButton.styleFrom(

                  backgroundColor:

                  BusinessConfig.primaryColor,

                  foregroundColor:

                  Colors.white,

                  padding:

                  const EdgeInsets.all(15),

                ),


                onPressed: (){


                  ScaffoldMessenger.of(context)

                  .showSnackBar(

                    SnackBar(

                      content: Text(actionText),

                    ),

                  );


                },


                child: Text(

                  actionText,

                  style: const TextStyle(

                    fontSize:18,

                  ),

                ),


              ),

            )

          ],

        ),

      ),

    );

  }

}
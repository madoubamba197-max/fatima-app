import 'package:flutter/material.dart';

import '../config/business_config.dart';
import '../repository/business_repository.dart';


class NewOperationPage extends StatefulWidget {

  const NewOperationPage({super.key});


  @override
  State<NewOperationPage> createState() =>
      _NewOperationPageState();

}



class _NewOperationPageState
    extends State<NewOperationPage> {


  final clientController =
      TextEditingController();


  String? selectedItem;


  @override
  Widget build(BuildContext context) {


    final items =
        BusinessRepository.getItems();



    return Scaffold(


      appBar: AppBar(

        title: Text(
          "Nouvelle opération",
        ),

        backgroundColor:
            BusinessConfig.primaryColor,

      ),



      body: Padding(

        padding:
            const EdgeInsets.all(20),


        child: Column(

          children: [


            TextField(

              controller:
                  clientController,


              decoration:
                  const InputDecoration(

                labelText:
                    "Nom du client",

                border:
                    OutlineInputBorder(),

              ),

            ),



            const SizedBox(height:20),



            DropdownButtonFormField<String>(


              decoration:
                  const InputDecoration(

                labelText:
                    "Choisir service / produit",

                border:
                    OutlineInputBorder(),

              ),



              value:
                  selectedItem,



              items:
                  items.map((item){


                return DropdownMenuItem(


                  value:
                      item.name,


                  child:
                      Text(item.name),


                );


              }).toList(),



              onChanged:(value){


                setState(() {

                  selectedItem =
                      value;

                });


              },


            ),



            const SizedBox(height:30),



            SizedBox(

              width:
                  double.infinity,


              child:
              ElevatedButton(


                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  BusinessConfig.primaryColor,

                  foregroundColor:
                  Colors.white,

                ),



                onPressed:(){


                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    const SnackBar(

                      content:
                      Text(
                        "Opération enregistrée",

                      ),

                    ),

                  );


                },


                child:
                const Text(
                  "Enregistrer",
                ),


              ),

            )



          ],

        ),

      ),

    );


  }

}
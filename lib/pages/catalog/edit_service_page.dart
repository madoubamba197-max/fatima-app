import 'package:flutter/material.dart';

import '../../models/business_item.dart';
import '../../core/app_storage/application_manager.dart';


class EditServicePage extends StatefulWidget {

  final BusinessItem item;
  final int index;


  const EditServicePage({
    super.key,
    required this.item,
    required this.index,
  });


  @override
  State<EditServicePage> createState() =>
      _EditServicePageState();

}



class _EditServicePageState extends State<EditServicePage> {


  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController categoryController;
  late TextEditingController durationController;



  @override
  void initState() {

    super.initState();


    nameController =
        TextEditingController(
          text: widget.item.name,
        );


    descriptionController =
        TextEditingController(
          text: widget.item.description,
        );


    priceController =
        TextEditingController(
          text: widget.item.price.toString(),
        );


    categoryController =
        TextEditingController(
          text: widget.item.category,
        );


    durationController =
        TextEditingController(
          text: widget.item.duration.inMinutes.toString(),
        );

  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "Modifier le service",
        ),

      ),


      body: Padding(

        padding: const EdgeInsets.all(20),


        child: ListView(

          children: [


            TextField(

              controller: nameController,

              decoration: const InputDecoration(
                labelText: "Nom",
              ),

            ),


            TextField(

              controller: descriptionController,

              decoration: const InputDecoration(
                labelText: "Description",
              ),

            ),


            TextField(

              controller: priceController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Prix",
              ),

            ),


            TextField(

              controller: categoryController,

              decoration: const InputDecoration(
                labelText: "Catégorie",
              ),

            ),


            TextField(

              controller: durationController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: "Durée en minutes",
              ),

            ),


            const SizedBox(height:30),



            ElevatedButton(

              onPressed: () {


                final app =
                    ApplicationManager
                    .getCurrentApplication();


                if(app == null) return;



                app.items[widget.index] = BusinessItem(


                  id: widget.item.id,


                  name: nameController.text,


                  description:
                  descriptionController.text,


                  price:
                  int.tryParse(
                    priceController.text,
                  ) ?? 0,


                  image:
                  widget.item.image,


                  category:
                  categoryController.text,


                  duration:
                  Duration(
                    minutes:
                    int.tryParse(
                      durationController.text,
                    ) ?? 0,
                  ),


                );


                Navigator.pop(context);


              },


              child: const Text(
                "Enregistrer",
              ),

            )


          ],

        ),

      ),

    );

  }

}
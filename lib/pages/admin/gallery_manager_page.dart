import 'package:flutter/material.dart';

import '../../core/current_business.dart';

class GalleryManagerPage extends StatefulWidget {
  const GalleryManagerPage({super.key});

  @override
  State<GalleryManagerPage> createState() =>
      _GalleryManagerPageState();
}

class _GalleryManagerPageState
    extends State<GalleryManagerPage> {

  @override
  Widget build(BuildContext context) {

    final commerce = CurrentBusiness.app!;

    return Scaffold(

      appBar: AppBar(

        title: const Text("Ma galerie"),

      ),

      floatingActionButton: FloatingActionButton(

        onPressed: () {

          ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(

              content: Text(
                "Le choix des photos sera connecté ensuite.",
              ),

            ),

          );

        },

        child: const Icon(Icons.add_a_photo),

      ),

      body: commerce.gallery.isEmpty

          ? const Center(

              child: Text(

                "Aucune photo",

                style: TextStyle(fontSize: 20),

              ),

            )

          : GridView.builder(

              padding: const EdgeInsets.all(15),

              gridDelegate:

                  const SliverGridDelegateWithFixedCrossAxisCount(

                crossAxisCount: 2,

                crossAxisSpacing: 10,

                mainAxisSpacing: 10,

              ),

              itemCount: commerce.gallery.length,

              itemBuilder: (context, index) {

                return Stack(

                  children: [

                    Container(

                      decoration: BoxDecoration(

                        borderRadius:

                            BorderRadius.circular(15),

                        color: Colors.grey.shade300,

                      ),

                      child: const Center(

                        child: Icon(

                          Icons.image,

                          size: 60,

                        ),

                      ),

                    ),

                    Positioned(

                      top: 5,

                      right: 5,

                      child: CircleAvatar(

                        radius: 18,

                        backgroundColor: Colors.red,

                        child: IconButton(

                          padding: EdgeInsets.zero,

                          icon: const Icon(

                            Icons.delete,

                            color: Colors.white,

                            size: 18,

                          ),

                          onPressed: () {

                            setState(() {

                              commerce.gallery.removeAt(index);

                            });

                          },

                        ),

                      ),

                    ),

                  ],

                );

              },

            ),

    );

  }

}
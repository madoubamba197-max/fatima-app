import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../config/business_config.dart';
import '../../models/business_item.dart';
import '../reservation/add_reservation_page.dart';
import 'add_service_page.dart';

class CatalogPage extends StatefulWidget {

  final bool adminMode;

  final String commerceId;

  const CatalogPage({

    super.key,

    required this.commerceId,

    this.adminMode = false,

  });

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Catalogue"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("commerces")
            .doc(widget.commerceId)
            .collection("services")
            .orderBy("createdAt")
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );

          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(

              child: Text(

                "Aucun service disponible",

                style: TextStyle(
                  fontSize: 20,
                ),

              ),

            );

          }

          final documents = snapshot.data!.docs;

final services = documents
    .map(
      (doc) => BusinessItem.fromFirestore(
        doc.id,
        doc.data() as Map<String, dynamic>,
      ),
    )
    .toList();

          return GridView.builder(

  padding: const EdgeInsets.all(15),

  itemCount: services.length,

  gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(

    crossAxisCount: 2,

    crossAxisSpacing: 15,

    mainAxisSpacing: 15,

    childAspectRatio: 0.35,

  ),

  itemBuilder: (context, index) {

    final item = services[index];

    debugPrint("SERVICE : ${item.name}");
    debugPrint("IMAGE URL : ${item.image}");

    final doc = documents[index];

    final data =
     doc.data() as Map<String, dynamic>;

    return Card(

      elevation: 6,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Expanded(
  flex: 7,
  child: item.imageBytes != null
      ? Image.memory(
          item.imageBytes!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            );
          },
        )
      : item.image.startsWith("http")
          ? Image.network(
              item.image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            )
          : Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
),


          Expanded(

            flex: 5,

            child: Padding(

              padding: const EdgeInsets.all(10),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    item.name,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),


                  Text(
                    item.category,
                  ),


                  Text(
                    "${item.price} ${BusinessConfig.currency}",
                  ),


                  Text(
                    "Durée : ${item.duration.inMinutes} min",
                  ),


                  const Spacer(),

                  
    if (widget.adminMode) ...[

  SizedBox(
    width: double.infinity,
    height: 38,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        minimumSize: Size.zero,
      ),

      icon: const Icon(
        Icons.edit,
        size: 17,
      ),

      label: const Text(
        "Modifier",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),

      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddServicePage(
              commerceId: widget.commerceId,
              serviceId: item.id,
              serviceData: data,
            ),
          ),
        );
      },
    ),
  ),

  const SizedBox(height: 6),

  SizedBox(
    width: double.infinity,
    height: 38,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,

        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),

        minimumSize: Size.zero,
      ),

      icon: const Icon(
        Icons.delete,
        size: 17,
      ),

      label: const Text(
        "Supprimer",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),

      onPressed: () async {
        final confirmer =
            await showDialog<bool>(
          context: context,

          builder: (context) {
            return AlertDialog(
              title: const Text(
                "Supprimer le service",
              ),

              content: Text(
                "Voulez-vous vraiment "
                "supprimer « ${item.name} » ?",
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },

                  child: const Text(
                    "Annuler",
                  ),
                ),

                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },

                  child: const Text(
                    "Supprimer",
                  ),
                ),
              ],
            );
          },
        );

        if (confirmer != true) {
          return;
        }

        try {

          await FirebaseFirestore.instance
              .collection("commerces")
              .doc(widget.commerceId)
              .collection("services")
              .doc(item.id)
              .delete();

          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "Service supprimé avec succès.",
              ),
            ),
          );

        } catch (e) {

          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                "Erreur lors de la suppression : $e",
              ),
            ),
          );
        }
      },
    ),
  ),

  const SizedBox(height: 8),
],

const SizedBox(height: 10),


                  if (!widget.adminMode)

                    SizedBox(

                      width:
                          double.infinity,

                      child:
                          ElevatedButton(

                        onPressed: () {

                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder: (_) =>
                                  AddReservationPage(
  commerceId: widget.commerceId,
  item: item,
)

                            ),

                          );

                        },

                        child:
                            const Text(
                              "Réserver",
                            ),

                      ),

                    ),


                ],

              ),

            ),

          ),

        ],

      ),

    );

  },

);

},

),

    
      
      floatingActionButton:

          widget.adminMode

              ? FloatingActionButton(

                  backgroundColor:
                      BusinessConfig.primaryColor,

                  child: const Icon(
                    Icons.add,
                  ),

                  onPressed: () async {


                    await Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const AddServicePage(),

                      ),

                    );


                  },

                )

              : null,

               );

    

  }

}
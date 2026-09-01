import 'package:flutter/material.dart';

import '../../core/current_business.dart';

class LogoManagerPage extends StatefulWidget {
  const LogoManagerPage({super.key});

  @override
  State<LogoManagerPage> createState() => _LogoManagerPageState();
}

class _LogoManagerPageState extends State<LogoManagerPage> {

  @override
  Widget build(BuildContext context) {

    final commerce = CurrentBusiness.app!;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Mon logo"),
      ),

      body: Center(

  child: GestureDetector(

    onTap: () {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Le choix d'image sera ajouté à l'étape suivante.",
          ),

        ),

      );

    },

    child: Stack(

      alignment: Alignment.bottomRight,

      children: [

        CircleAvatar(

          radius: 80,

          backgroundColor: Colors.grey.shade300,

          child: commerce.logo.isEmpty

              ? const Icon(

                  Icons.store,

                  size: 80,

                )

              : ClipOval(

                  child: Image.network(

                    commerce.logo,

                    width: 160,

                    height: 160,

                    fit: BoxFit.cover,

                  ),

                ),

        ),

        Container(

          decoration: BoxDecoration(

            color: Colors.orange,

            borderRadius: BorderRadius.circular(30),

          ),

          padding: const EdgeInsets.all(8),

          child: const Icon(

            Icons.camera_alt,

            color: Colors.white,

            size: 22,

          ),

        ),

      ],

    ),

  ),

),

    );

  }

}
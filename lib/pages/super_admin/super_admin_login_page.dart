import 'package:flutter/material.dart';

import '../creator/creator_home_page.dart';

class SuperAdminLoginPage extends StatefulWidget {
  const SuperAdminLoginPage({super.key});

  @override
  State<SuperAdminLoginPage> createState() =>
      _SuperAdminLoginPageState();
}

class _SuperAdminLoginPageState
    extends State<SuperAdminLoginPage> {

  final idController = TextEditingController();

  final passwordController = TextEditingController();

  bool cacher = true;

  void connexion() {

    if (idController.text.trim() == "mariabou" &&
        passwordController.text == "0431") {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) => const CreatorHomePage(),

        ),

      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Identifiant ou mot de passe incorrect",
          ),

        ),

      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Connexion Super Admin"),

      ),

      body: Center(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(25),

          child: Column(

            children: [

              const Icon(

                Icons.admin_panel_settings,

                size: 90,

                color: Colors.orange,

              ),

              const SizedBox(height: 30),

              TextField(

                controller: idController,

                decoration: const InputDecoration(

                  labelText: "Identifiant",

                  prefixIcon: Icon(Icons.person),

                ),

              ),

              const SizedBox(height: 20),

              TextField(

                controller: passwordController,

                obscureText: cacher,

                decoration: InputDecoration(

                  labelText: "Mot de passe",

                  prefixIcon: const Icon(Icons.lock),

                  suffixIcon: IconButton(

                    icon: Icon(

                      cacher
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),

                    onPressed: () {

                      setState(() {

                        cacher = !cacher;

                      });

                    },

                  ),

                ),

              ),

              const SizedBox(height: 35),

              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton(

                  onPressed: connexion,

                  child: const Text(

                    "Connexion",

                    style: TextStyle(fontSize: 20),

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}
import 'package:flutter/material.dart';
import '../../core/auth/admin_session.dart';
import '../../core/app_storage/application_manager.dart';
import 'admin_dashboard_page.dart';
import '../../services/admin_auth_service.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Connexion administrateur"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 30),

            TextField(

              controller: usernameController,

              decoration: const InputDecoration(

                labelText: "Identifiant",

                border: OutlineInputBorder(),

                prefixIcon: Icon(Icons.person),

              ),

            ),

            const SizedBox(height: 20),

            TextField(

              controller: passwordController,

              obscureText: true,

              decoration: const InputDecoration(

                labelText: "Mot de passe",

                border: OutlineInputBorder(),

                prefixIcon: Icon(Icons.lock),

              ),

            ),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

           onPressed: () async {

  final commerce = await AdminAuthService.login(

    usernameController.text.trim(),

    passwordController.text.trim(),

  );

  if (commerce == null) {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text(
          "Identifiant ou mot de passe incorrect",
        ),

      ),

    );

    return;

  }

  ApplicationManager.setCurrentApplication(commerce);

  AdminSession.login();

  Navigator.pushReplacement(

    context,

    MaterialPageRoute(

      builder: (_) => const AdminDashboardPage(),

    ),

  );

},

                child: const Text("Se connecter"),

              ),

            ),

          ],

        ),

      ),

    );

  }

}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'config/business_config.dart';
import 'theme/app_theme.dart';

import 'firebase_options.dart';
import 'pages/welcome/welcome_page.dart';


// ==========================================================
// NOTIFICATION EN ARRIÈRE-PLAN
// ==========================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint("======================================");
  debugPrint("NOTIFICATION EN ARRIÈRE-PLAN");
  debugPrint("ID : ${message.messageId}");
  debugPrint("TITRE : ${message.notification?.title}");
  debugPrint("MESSAGE : ${message.notification?.body}");
  debugPrint("DATA : ${message.data}");
  debugPrint("======================================");
}


// ==========================================================
// MAIN
// ==========================================================

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ========================================================
  // FCM BACKGROUND HANDLER
  // ========================================================

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  runApp(
    const BusinessApp(),
  );
}


// ==========================================================
// APPLICATION
// ==========================================================

class BusinessApp extends StatelessWidget {

  const BusinessApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: BusinessConfig.name,

      theme: AppTheme.lightTheme,

      home: const WelcomePage(),
    );
  }
}


// ==========================================================
// HOME PAGE
// ==========================================================

class HomePage extends StatelessWidget {

  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor:
            BusinessConfig.primaryColor,

        title:
            Text(
          BusinessConfig.name,
        ),
      ),

      body:
          Center(

        child:
            Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Text(

              BusinessConfig.slogan,

              style:
                  const TextStyle(
                fontSize: 22,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(

              "Type : ${BusinessConfig.type}",

              style:
                  const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
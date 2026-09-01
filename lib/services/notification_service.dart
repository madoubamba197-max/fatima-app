import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ==========================================================
  // HANDLER NOTIFICATION EN ARRIÈRE-PLAN
  // ==========================================================

  @pragma('vm:entry-point')
  static Future<void> backgroundHandler(
    RemoteMessage message,
  ) async {
    try {
      await Firebase.initializeApp();

      debugPrint("======================================");
      debugPrint("NOTIFICATION EN ARRIÈRE-PLAN");
      debugPrint("ID : ${message.messageId}");
      debugPrint("TITRE : ${message.notification?.title}");
      debugPrint("MESSAGE : ${message.notification?.body}");
      debugPrint("DATA : ${message.data}");
      debugPrint("======================================");
    } catch (e) {
      debugPrint(
        "ERREUR HANDLER ARRIÈRE-PLAN : $e",
      );
    }
  }

  // ==========================================================
  // INITIALISATION
  // ==========================================================

  static Future<void> initialiser({
    required String commerceId,
  }) async {
    try {
      debugPrint("======================================");
      debugPrint("INITIALISATION NOTIFICATIONS");
      debugPrint("COMMERCE : $commerceId");
      debugPrint("======================================");

      // ------------------------------------------------------
      // DEMANDE D'AUTORISATION
      // ------------------------------------------------------

      final settings =
          await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        "AUTORISATION NOTIFICATION : "
        "${settings.authorizationStatus}",
      );

      // ------------------------------------------------------
      // TOKEN FCM
      // ------------------------------------------------------

      final token =
          await _messaging.getToken();

      if (token == null ||
          token.trim().isEmpty) {
        debugPrint(
          "ERREUR : token FCM introuvable.",
        );

        return;
      }

      debugPrint("======================================");
      debugPrint("TOKEN FCM :");
      debugPrint(token);
      debugPrint("======================================");

      // ------------------------------------------------------
      // ENREGISTREMENT FIRESTORE
      // ------------------------------------------------------

      await _enregistrerToken(
        commerceId: commerceId,
        token: token,
      );

      // ------------------------------------------------------
      // TOKEN MODIFIÉ
      // ------------------------------------------------------

      FirebaseMessaging.instance.onTokenRefresh.listen(
        (newToken) async {
          try {
            debugPrint(
              "NOUVEAU TOKEN FCM : $newToken",
            );

            await _enregistrerToken(
              commerceId: commerceId,
              token: newToken,
            );

          } catch (e) {
            debugPrint(
              "ERREUR NOUVEAU TOKEN : $e",
            );
          }
        },
      );

      // ------------------------------------------------------
      // MESSAGE AU PREMIER PLAN
      // ------------------------------------------------------

      FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) {
          debugPrint("======================================");
          debugPrint("NOTIFICATION REÇUE AU PREMIER PLAN");
          debugPrint(
            "ID : ${message.messageId}",
          );
          debugPrint(
            "TITRE : ${message.notification?.title}",
          );
          debugPrint(
            "MESSAGE : ${message.notification?.body}",
          );
          debugPrint(
            "DATA : ${message.data}",
          );
          debugPrint("======================================");
        },
      );

      // ------------------------------------------------------
      // UTILISATEUR APPUIE SUR NOTIFICATION
      // ------------------------------------------------------

      FirebaseMessaging.onMessageOpenedApp.listen(
        (RemoteMessage message) {
          debugPrint("======================================");
          debugPrint(
            "NOTIFICATION OUVERTE PAR L'UTILISATEUR",
          );
          debugPrint(
            "DATA : ${message.data}",
          );
          debugPrint("======================================");
        },
      );

      // ------------------------------------------------------
      // APPLICATION LANCÉE APRÈS UN CLIC
      // ------------------------------------------------------

      final initialMessage =
          await _messaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint("======================================");
        debugPrint(
          "APPLICATION OUVERTE PAR NOTIFICATION",
        );
        debugPrint(
          "DATA : ${initialMessage.data}",
        );
        debugPrint("======================================");
      }

    } catch (e) {
      debugPrint(
        "ERREUR INITIALISATION NOTIFICATIONS : $e",
      );
    }
  }

  // ==========================================================
  // ENREGISTRER TOKEN
  // ==========================================================

  static Future<void> _enregistrerToken({
    required String commerceId,
    required String token,
  }) async {

    await _firestore
        .collection("commerces")
        .doc(commerceId)
        .collection("fcmTokens")
        .doc(token)
        .set({
      "token": token,
      "updatedAt":
          FieldValue.serverTimestamp(),
      "platform":
          defaultTargetPlatform.name,
    });

    debugPrint(
      "TOKEN FCM ENREGISTRÉ DANS FIRESTORE.",
    );
  }
}
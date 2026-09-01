import 'package:url_launcher/url_launcher.dart';

class ContactService {

  static Future<void> appeler(String telephone) async {

    final Uri uri = Uri(
      scheme: "tel",
      path: telephone,
    );

    await launchUrl(uri);

  }

  static Future<void> envoyerSMS(

      String telephone,
      String message,

      ) async {

    final Uri uri = Uri(

      scheme: "sms",

      path: telephone,

      queryParameters: {

        "body": message,

      },

    );

    await launchUrl(uri);

  }

  static Future<void> envoyerWhatsapp(

      String telephone,
      String message,

      ) async {

    telephone = telephone.replaceAll(" ", "");

    // Côte d'Ivoire
    if (telephone.startsWith("0")) {
      telephone = "225${telephone.substring(1)}";
    }

    final Uri uri = Uri.parse(

      "https://wa.me/$telephone?text=${Uri.encodeComponent(message)}",

    );

    await launchUrl(

      uri,

      mode: LaunchMode.externalApplication,

    );

  }

}
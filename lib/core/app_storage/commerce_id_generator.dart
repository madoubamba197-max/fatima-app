import '../../config/business_type.dart';
import 'application_manager.dart';

class CommerceIdGenerator {

  static String generate(BusinessType type) {

    String prefix;

    switch (type) {

      case BusinessType.restaurant:
        prefix = "RESTO";
        break;

      case BusinessType.salon:
        prefix = "SALON";
        break;

      case BusinessType.hotel:
        prefix = "HOTEL";
        break;

      case BusinessType.garage:
        prefix = "GARAGE";
        break;

      case BusinessType.boutique:
        prefix = "BOUTIQUE";
        break;

      case BusinessType.pharmacie:
        prefix = "PHARMA";
        break;

      case BusinessType.cabinetMedical:
        prefix = "CAB";
        break;

      case BusinessType.supermarche:
        prefix = "SUPER";
        break;

      case BusinessType.ecole:
        prefix = "ECOLE";
        break;

      case BusinessType.autre:
        prefix = "AUTRE";
        break;
    }

    int compteur = ApplicationManager.getAll()
        .where((e) => e.type == type)
        .length + 1;

    return "$prefix${compteur.toString().padLeft(4, '0')}";
  }
}
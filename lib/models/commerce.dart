import '../config/business_type.dart';
import 'business_item.dart';


class Commerce {


  final String id;


  String name;

  String slogan;


  String phone;

  String whatsapp;

  String address;


  BusinessType type;


  // Gestion visibilité FATIMA

  bool active;


  // Abonnement

  DateTime subscriptionStart;

  DateTime subscriptionEnd;


  // Présentation

  String logo;

  String coverImage;


  List<String> gallery;


  List<BusinessItem> items;


  // Statistiques

  double rating;

  int reviews;


  Commerce({

    required this.id,

    required this.name,

    required this.slogan,

    required this.phone,

    required this.whatsapp,

    required this.address,

    required this.type,

    required this.active,

    required this.subscriptionStart,

    required this.subscriptionEnd,

    required this.logo,

    required this.coverImage,

    required this.gallery,

    required this.items,

    required this.rating,

    required this.reviews,

  });


  // Vérifier si le commerce est visible

  bool get isVisible {


    final maintenant = DateTime.now();


    return active &&
        maintenant.isBefore(subscriptionEnd);


  }


}
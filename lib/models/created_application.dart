import '../config/business_type.dart';
import 'business_item.dart';

class CreatedApplication {

  // Identifiant unique du commerce
  final String commerceId;

  // Informations générales
  String name;
  String slogan;
  String proprietaire;

  String phone;
  String whatsapp;

  String ville;
  String address;

  // Géolocalisation
  double latitude;
  double longitude;

  bool verified;

  bool online;

  double rating;

  int reviews;

  String logo;

  String coverImage;

  // Galerie photos du commerce
  List<String> gallery;

  // Type de commerce
  BusinessType type;

  // Dates
  final DateTime createdAt;

  // Administrateur
  String adminUsername;
  String adminPassword;

  // Abonnement
  bool abonnementActif;
  DateTime expirationAbonnement;

  // Catalogue
  final List<BusinessItem> items;

  CreatedApplication({

    required this.commerceId,

    required this.name,
    required this.slogan,
    required this.proprietaire,

    required this.phone,
    required this.whatsapp,

    required this.ville,
    required this.address,

    this.latitude = 0,
    this.longitude = 0,

    required this.verified,

    required this.online,

    required this.rating,

    required this.reviews,

    required this.logo,

    required this.coverImage,

    required this.gallery,

    required this.type,

    required this.createdAt,

    required this.items,

    required this.adminUsername,
    required this.adminPassword,

    this.abonnementActif = true,

    required this.expirationAbonnement,
  });

}
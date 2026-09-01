import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCommerce {
  final String id;

  final String name;
  final String slogan;
  final String proprietaire;
  final String phone;
  final String whatsapp;
  final String ville;
  final String address;
  final String type;

  final String adminUsername;
  final String adminPassword;

  final bool abonnementActif;
  final bool online;

  FirestoreCommerce({
    required this.id,
    required this.name,
    required this.slogan,
    required this.proprietaire,
    required this.phone,
    required this.whatsapp,
    required this.ville,
    required this.address,
    required this.type,
    required this.adminUsername,
    required this.adminPassword,
    required this.abonnementActif,
    required this.online,
  });

  factory FirestoreCommerce.fromFirestore(
      DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FirestoreCommerce(
      id: doc.id,
      name: data["name"] ?? "",
      slogan: data["slogan"] ?? "",
      proprietaire: data["proprietaire"] ?? "",
      phone: data["phone"] ?? "",
      whatsapp: data["whatsapp"] ?? "",
      ville: data["ville"] ?? "",
      address: data["address"] ?? "",
      type: data["type"] ?? "",
      adminUsername: data["adminUsername"] ?? "",
      adminPassword: data["adminPassword"] ?? "",
      abonnementActif: data["abonnementActif"] ?? false,
      online: data["online"] ?? false,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/created_application.dart';
import '../models/business_item.dart';
import '../config/business_type.dart';

class AdminAuthService {
  static Future<CreatedApplication?> login(
      String username,
      String password,
      ) async {

    final result = await FirebaseFirestore.instance
        .collection("commerces")
        .where("adminUsername", isEqualTo: username)
        .where("adminPassword", isEqualTo: password)
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }

    final doc = result.docs.first;

    final data = doc.data();

    return CreatedApplication(
      commerceId: doc.id,
      name: data["name"] ?? "",
      slogan: data["slogan"] ?? "",
      proprietaire: data["proprietaire"] ?? "",
      phone: data["phone"] ?? "",
      whatsapp: data["whatsapp"] ?? "",
      ville: data["ville"] ?? "",
      address: data["address"] ?? "",
      verified: data["verified"] ?? false,
      online: data["online"] ?? true,
      rating: (data["rating"] ?? 0).toDouble(),
      reviews: data["reviews"] ?? 0,
      logo: data["logo"] ?? "",
      coverImage: data["coverImage"] ?? "",
      gallery: [],
      latitude: 0,
      longitude: 0,
      type: BusinessType.values.firstWhere(
        (e) => e.name == data["type"],
        orElse: () => BusinessType.autre,
      ),
      createdAt: DateTime.now(),
      items: <BusinessItem>[],
      adminUsername: data["adminUsername"] ?? "",
      adminPassword: data["adminPassword"] ?? "",
      abonnementActif: true,
      expirationAbonnement: DateTime.now(),
    );
  }
}
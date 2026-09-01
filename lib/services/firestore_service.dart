import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {


  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;


  static Stream<QuerySnapshot> getCommerces() {

    return _db
        .collection("commerces")
        .snapshots();

  }


  static Future<void> deleteCommerce(
      String id
  ) async {

    await _db
        .collection("commerces")
        .doc(id)
        .delete();

  }


  static Stream<QuerySnapshot> getServices(
      String commerceId
  ) {

    return _db
        .collection("commerces")
        .doc(commerceId)
        .collection("services")
        .snapshots();

  }


}
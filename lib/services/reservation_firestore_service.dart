import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationFirestoreService {

  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  static Future<void> ajouterReservation(
      Map<String, dynamic> reservation) async {

    await _db
        .collection("reservations")
        .add(reservation);
  }

}
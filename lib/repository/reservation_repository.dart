import '../models/reservation.dart';

class ReservationRepository {
  static final List<Reservation> reservations = [];

  // ==========================================================
  // AJOUTER UNE RÉSERVATION EN MÉMOIRE
  // ==========================================================

  static void addReservation(Reservation reservation) {
    reservations.add(reservation);
  }

  // ==========================================================
  // VÉRIFIER SI UN CRÉNEAU EST DISPONIBLE
  // ==========================================================

  static bool isSlotAvailable(DateTime date) {
    return !reservations.any((reservation) {
      return reservation.reservationDate.year == date.year &&
          reservation.reservationDate.month == date.month &&
          reservation.reservationDate.day == date.day &&
          reservation.reservationDate.hour == date.hour &&
          reservation.reservationDate.minute == date.minute;
    });
  }

  // ==========================================================
  // NOMBRE DE RÉSERVATIONS EN ATTENTE
  // ==========================================================

  static int pendingCount() {
    return reservations
        .where(
          (r) => r.status == "En attente",
        )
        .length;
  }

  // ==========================================================
  // RÉSERVATIONS D'UN COMMERCE
  // ==========================================================

  static List<Reservation> getReservationsForCommerce(
    String commerceId,
  ) {
    return reservations
        .where(
          (r) => r.commerceId == commerceId,
        )
        .toList();
  }
}
class Reservation {
  // ==========================================================
  // IDENTIFIANT DE LA RESERVATION
  // ==========================================================

  final String id;

  // ==========================================================
  // COMMERCE
  // ==========================================================

  final String commerceId;

  // ==========================================================
  // INFORMATIONS CLIENT
  // ==========================================================

  final String clientName;

  final String phone;

  // ==========================================================
  // ARTICLE / SERVICE RESERVE
  // ==========================================================

  final String serviceId;

  final String serviceName;

  final String serviceImage;

  // ==========================================================
  // DATE DE RESERVATION
  // ==========================================================

  final DateTime reservationDate;

  // ==========================================================
  // COMMENTAIRE
  // ==========================================================

  final String comment;

  // ==========================================================
  // STATUT
  // ==========================================================

  String status;

  // ==========================================================
  // DATE DE CREATION
  // ==========================================================

  final DateTime? createdAt;

  // ==========================================================
  // CONSTRUCTEUR
  // ==========================================================

  Reservation({
    required this.id,
    required this.commerceId,
    required this.clientName,
    required this.phone,

    required this.serviceId,
    required this.serviceName,
    required this.serviceImage,

    required this.reservationDate,

    required this.comment,

    this.status = "En attente",

    this.createdAt,
  });
}
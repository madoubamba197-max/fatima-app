import 'business_type.dart';

class BusinessFeatures {

  final bool booking;
  final bool payment;
  final bool gallery;
  final bool delivery;

  const BusinessFeatures({

    required this.booking,
    required this.payment,
    required this.gallery,
    required this.delivery,

  });


  factory BusinessFeatures.fromType(
      BusinessType type) {

    switch(type) {


      case BusinessType.restaurant:

        return const BusinessFeatures(
          booking: false,
          payment: true,
          gallery: true,
          delivery: true,
        );


      case BusinessType.salon:

        return const BusinessFeatures(
          booking: true,
          payment: true,
          gallery: true,
          delivery: false,
        );


      case BusinessType.hotel:

        return const BusinessFeatures(
          booking: true,
          payment: true,
          gallery: true,
          delivery: false,
        );


      case BusinessType.garage:

        return const BusinessFeatures(
          booking: true,
          payment: true,
          gallery: false,
          delivery: false,
        );


      default:

        return const BusinessFeatures(
          booking: false,
          payment: false,
          gallery: true,
          delivery: false,
        );

    }

  }

}
import '../config/business_config.dart';
import '../config/business_type.dart';

class BusinessBuilder {

  static bool get isRestaurant =>
      BusinessConfig.type == BusinessType.restaurant;

  static bool get isSalon =>
      BusinessConfig.type == BusinessType.salon;

  static bool get isHotel =>
      BusinessConfig.type == BusinessType.hotel;

  static bool get isGarage =>
      BusinessConfig.type == BusinessType.garage;

  static bool get isBoutique =>
      BusinessConfig.type == BusinessType.boutique;
}
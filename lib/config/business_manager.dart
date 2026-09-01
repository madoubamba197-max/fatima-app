import 'business_type.dart';


class BusinessManager {


  static BusinessType currentType =
    BusinessType.salon;



  static void changeBusiness(
      BusinessType type
      ){

    currentType = type;

  }


}
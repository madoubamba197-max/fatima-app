import '../models/business_item.dart';
import '../core/app_storage/application_manager.dart';
import '../models/business_item.dart';

class BusinessRepository {

  static List<BusinessItem> getItems() {

  final app =
      ApplicationManager.getCurrentApplication();


  if (app != null) {

    return app.items;

  }


  return [];

}

  static List<BusinessItem> restaurantItems() {

    return [

      BusinessItem(
        id: "1",
        name: "Poulet braisé",
        description: "Poulet braisé avec alloco",
        price: 3500,
        image: "assets/images/poulet.jpg",
        category: "Plats",
        duration: const Duration(minutes: 30),
      ),

      BusinessItem(
        id: "2",
        name: "Poisson braisé",
        description: "Poisson braisé",
        price: 5000,
        image: "assets/images/poisson.jpg",
        category: "Plats",
        duration: const Duration(minutes: 25),
      ),
      
    ];
  }

  static List<BusinessItem> salonItems() {

    return [

      BusinessItem(
        id: "1",
        name: "Tresses",
        description: "Tresses africaines",
        price: 15000,
        image: "assets/images/banner1.jpg",
        category: "Coiffure",
        duration: const Duration(hours: 3),
      ),

    ];
  }

  static List<BusinessItem> hotelItems() {

    return [

      BusinessItem(
        id: "1",
        name: "Chambre Standard",
        description: "Lit double",
        price: 35000,
        image: "assets/images/chambre.jpg",
        category: "Chambres",
        duration: const Duration(days: 1),
      ),

    ];
  }

  static List<BusinessItem> garageItems() {

    return [

      BusinessItem(
        id: "1",
        name: "Vidange",
        description: "Huile + filtre",
        price: 25000,
        image: "assets/images/garage.jpg",
        category: "Entretien",
        duration: const Duration(hours: 1),
      ),

    ];
  }

}
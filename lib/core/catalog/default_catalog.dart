import '../../config/business_type.dart';
import '../../models/business_item.dart';


class DefaultCatalog {


  static List<BusinessItem> get(
      BusinessType type
      ) {


    switch(type) {


      case BusinessType.salon:

        return [

          BusinessItem(
            id: "1",
            name: "Tresses africaines",
            description: "Coiffure traditionnelle",
            price: 15000,
            image: "assets/images/banner1.jpg",
            category: "Coiffure",
            duration: const Duration(hours: 3),
          ),


          BusinessItem(
            id: "2",
            name: "Perruque",
            description: "Pose de perruque",
            price: 25000,
            image: "assets/images/banner2.jpg",
            category: "Coiffure",
            duration: const Duration(hours: 2),
          ),


          BusinessItem(
            id: "3",
            name: "Maquillage",
            description: "Maquillage beauté",
            price: 10000,
            image: "assets/images/banner3.jpg",
            category: "Beauté",
            duration: const Duration(hours: 1),
          ),

        ];



      case BusinessType.restaurant:

        return [

          BusinessItem(
            id: "1",
            name: "Poulet braisé",
            description: "Poulet braisé avec accompagnement",
            price: 3500,
            image: "assets/images/poulet.jpg",
            category: "Plats",
            duration: const Duration(minutes: 30),
          ),

        ];



      case BusinessType.garage:

        return [

          BusinessItem(
            id: "1",
            name: "Vidange",
            description: "Huile et filtre",
            price: 25000,
            image: "assets/images/garage.jpg",
            category: "Entretien",
            duration: const Duration(hours: 1),
          ),

        ];


      case BusinessType.hotel:

        return [

          BusinessItem(
            id: "1",
            name: "Chambre Standard",
            description: "Chambre confortable",
            price: 35000,
            image: "assets/images/chambre.jpg",
            category: "Chambres",
            duration: const Duration(days: 1),
          ),

        ];


      default:

        return [];

    }

  }


}
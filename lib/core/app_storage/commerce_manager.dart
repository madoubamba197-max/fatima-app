import '../../models/commerce.dart';


class CommerceManager {


  static final List<Commerce> commerces = [];


  static Commerce? currentCommerce;



  // Ajouter un commerce

  static void addCommerce(
      Commerce commerce
      ) {

    commerces.add(commerce);

  }



  // Ouvrir un commerce

  static void openCommerce(
      Commerce commerce
      ) {

    currentCommerce = commerce;

  }



  // Commerce actuel

  static Commerce? getCurrentCommerce() {

    return currentCommerce;

  }



  // Tous les commerces

  static List<Commerce> getAll() {

    return commerces;

  }



  // Commerces visibles pour les clients

  static List<Commerce> getActiveCommerces() {


    return commerces
        .where((commerce) => commerce.isVisible)
        .toList();


  }



  // Supprimer

  static void removeCommerce(
      Commerce commerce
      ) {

    commerces.remove(commerce);

  }


}
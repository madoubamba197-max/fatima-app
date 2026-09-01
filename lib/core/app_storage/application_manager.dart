import '../../models/created_application.dart';


class ApplicationManager {


  static final List<CreatedApplication> applications = [];

  static CreatedApplication? currentApplication;

  static List<CreatedApplication> getActiveCommerces() {

  return applications.where((app) {

    return app.online &&
           app.abonnementActif &&
           DateTime.now()
             .isBefore(app.expirationAbonnement);

  }).toList();

}



  // Ajouter une application

  static void addApplication(
      CreatedApplication application
      ) {

    applications.add(application);

  }

  static void openApplication(
    CreatedApplication application
) {

  currentApplication = application;

}

static void setCurrentApplication(
  CreatedApplication application,
) {
  currentApplication = application;
}

static CreatedApplication? getCurrentApplication() {

  return currentApplication;

}



  // Récupérer toutes les applications

  static List<CreatedApplication> getAll() {

    return applications;

  }



  // Supprimer une application

  static void removeApplication(
      CreatedApplication application
      ) {

    applications.remove(application);

  }



}